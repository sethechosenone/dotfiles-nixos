{ pkgs, ... }: {
  boot = {
    loader.generic-extlinux-compatible.enable = true;
    kernel.sysctl."net.ipv4.ip_forward" = 1;
  };
  nix = {
    settings.trusted-users = [ "root" "seth" ];
    extraOptions = "experimental-features = nix-command flakes";
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
        };
        theinfinitewebsite = {
          autoStart = true;
          image = "192.168.1.100:5000/infinitewebsite:latest";
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
  users.users = {
    seth = {
      isNormalUser = true;
      initialPassword = "nixos"; # Change this after first login!
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
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILbARtxmUmEUaiEOZ50m6eWKbftzndMSxXlapccHI9/m seth@SA-Framework16" ];
      shell = pkgs.zsh;
    };
    root.shell = pkgs.zsh;
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
      allowedTCPPorts = [ 22 53 80 ];
      allowedUDPPorts = [ 53 ];
      extraCommands = ''
        iptables -I DOCKER-USER -s 172.17.0.0/16 -d 192.168.1.0/24 -j DROP
        iptables -I DOCKER-USER -s 172.17.0.0/16 -j ACCEPT
      '';
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
        ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -A FORWARD -o wg0 -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
      '';
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -D FORWARD -o wg0 -j ACCEPT || true
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE || true
      '';
    };
  };
  system.stateVersion = "25.11";
  sops = {
    defaultSopsFile = ./secrets/environment.yaml;
    age.keyFile = "/var/lib/sops-nix/keys.txt";
    secrets.theinfinitewebsite_env = {
      mode = "0400";
      owner = "root";
    };
  };
  services = {
    dockerRegistry = {
      enable = true;
      openFirewall = true;
      listenAddress = "0.0.0.0";
      port = 5000;
      storagePath = "/var/lib/docker-registry";
    };
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    direnv.enable = true;
  };
  environment.systemPackages = with pkgs; [
    sl
    eza
    bat
    kitty.terminfo
    wireguard-tools
  ];
}
