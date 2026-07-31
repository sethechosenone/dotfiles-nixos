{ pkgs, lib, ... }: {
  boot = {
    loader.generic-extlinux-compatible.enable = true;
    kernel.sysctl."net.ipv4.ip_forward" = 1;
  };
  nix.settings = {
    trusted-users = [ "root" "seth" ];
    experimental-features = [ "nix-command" "flakes"];
  };
  nixpkgs = {
    overlays =
      [ (final: prev: { sudo = prev.sudo.override { withInsults = true; }; }) ];
    config.allowUnfree = true;
  };
  virtualisation = {
    docker = {
      enable = true;
      daemon.settings.insecure-registries = [ "192.168.1.100:5000" ];
    };
    oci-containers = {
      backend = "docker";
      containers = {
        pihole = {
          autoStart = true;
          image = "pihole/pihole:latest";
          extraOptions = [ "--network=host" ];
          environment.WEB_PORT = "8081";
        };
        theinfinitewebsite = {
          autoStart = true;
          image = "192.168.40.100:5000/infinitewebsite:latest";
          environmentFiles = [ "/run/secrets/theinfinitewebsite_env" ];
          extraOptions = [
            "--cap-drop=ALL"
            "--security-opt=no-new-privileges"
            "--read-only"
            "--pids-limit=100"
          ];
        };
      };
    };
  };
  console = {
    packages = [ pkgs.powerline-fonts ];
    earlySetup = true;
    font = "ter-powerline-v24b";
    keyMap = lib.mkDefault "us";
  };
  security = {
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };
    pam.enableFscrypt = true;
    protectKernelImage = true;
    sudo.execWheelOnly = true;
  };
  users.users = {
    seth = {
      isNormalUser = true;
      initialPassword = "change-me-after-install!"; # change this after first login!
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
      ]; # Enable 'sudo' for the user.
      packages = with pkgs; [
        tree
        dconf
        nixpkgs-fmt
        nmap
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH9xlfU47R64W8FucsZ+kRq4nTmptXXomUkz4bFJyBE8 seth@SA-Framework16"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPNh0st4w3qchaLTrRHKdI5W2omWKZ+9nUNBgO9e69E4 seth@SA-PowerTower"
      ];
      shell = pkgs.zsh;
    };
    root.shell = pkgs.zsh;
  };
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "hm-backup";
    users = {
      seth = import ./home.nix;
      root = import ./home.nix;
    };
  };
  networking = {
    hostName = "SA-RaspberryPi4";
    useDHCP = false;
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "192.168.1.100";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.1" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 53 1025 1143 ];
      allowedUDPPorts = [ 53 ];
    };
    wireguard.interfaces.wg0 = {
      ips = [ "10.0.0.2/24" ];
      listenPort = 51280;
      privateKeyFile = "/root/wireguard-private.key";
      peers = [{
        publicKey = "JpallhuDYWJzuwMG7gDk0BOy0kayLeIR06Rch8e9EmI=";
        endpoint = "150.136.168.118:51820";
        allowedIPs = [ "10.0.0.0/24" ];
        persistentKeepalive = 25;
      }];
      postSetup = ''
        # ALLOW only trusted personal devices (whitelist)
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -s 10.0.0.3 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -s 10.0.0.4 -j ACCEPT
        # BLOCK everything else from WireGuard (Oracle + any rogue peers)
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j DROP
        # ALLOW all outbound traffic to VPN
        ${pkgs.iptables}/bin/iptables -A FORWARD -o wg0 -j ACCEPT
        # NAT for LAN access
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -s 10.0.0.3 -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -s 10.0.0.4 -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j DROP || true
        ${pkgs.iptables}/bin/iptables -D FORWARD -o wg0 -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE || true
      '';
    };
  };
  systemd.services.docker-firewall = {
    description = "Docker container firewall rules";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.iptables ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Wait for Docker to be fully ready
      sleep 2
      # Clean up old rules
      # Flush DOCKER-USER chain
      iptables -F DOCKER-USER 2>/dev/null || true
      # Remove any existing docker0 INPUT rules
      while iptables -D INPUT -i docker0 -j DROP 2>/dev/null; do :; done
      while iptables -D INPUT -i docker0 -p tcp --dport 53 -j ACCEPT 2>/dev/null; do :; done
      while iptables -D INPUT -i docker0 -p udp --dport 53 -j ACCEPT 2>/dev/null; do :; done
      # FORWARD chain rules (via DOCKER-USER) - for traffic to other devices
      # Allow DNS to LAN (before blocking LAN access)
      iptables -A DOCKER-USER -p udp -s 172.17.0.0/16 -d 192.168.1.0/24 --dport 53 -j ACCEPT
      iptables -A DOCKER-USER -p tcp -s 172.17.0.0/16 -d 192.168.1.0/24 --dport 53 -j ACCEPT
      # Block Docker containers from accessing other LAN services
      iptables -A DOCKER-USER -s 172.17.0.0/16 -d 192.168.1.0/24 -j DROP
      # Allow Docker containers to internet
      iptables -A DOCKER-USER -s 172.17.0.0/16 -j ACCEPT
      # Return to main chain
      iptables -A DOCKER-USER -j RETURN
      # INPUT chain rules - for traffic to the host itself
      # Drop everything from containers to host (executed first, ends up last)
      iptables -I INPUT -i docker0 -j DROP
      # Allow DNS from containers to host (executed after, ends up before DROP)
      iptables -I INPUT -i docker0 -p tcp --dport 53 -j ACCEPT
      iptables -I INPUT -i docker0 -p udp --dport 53 -j ACCEPT
    '';
  };
  system.stateVersion = "25.11";
  sops = {
    defaultSopsFile = ./secrets/environment.yaml;
    age.keyFile = "/var/lib/sops-nix/keys.txt";
    secrets = {
      theinfinitewebsite_env = {
        mode = "0400";
        owner = "root";
      };
      vaultwarden = {
        mode = "400";
        owner = "vaultwarden";
      };
      cloudflare-token = {
        mode = "400";
        owner = "root";
      };
    };
  };
  environment.systemPackages = with pkgs; [
    sl
    eza
    bat
    kitty.terminfo
    wireguard-tools
    pass
  ];
}
