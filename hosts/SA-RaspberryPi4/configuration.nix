{ pkgs, ... }: {
  boot.loader.generic-extlinux-compatible.enable = true;
  nix.settings.trusted-users = [ "root" "seth" ];
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
    };
  };
  system.stateVersion = "25.11";
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
    eza
    bat
    kitty.terminfo
  ];
}
