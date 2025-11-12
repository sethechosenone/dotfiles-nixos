{ config, lib, pkgs, ... }: {
  boot.loader.generic-extlinux-compatible.enable = true;
  nix.settings.trusted-users = [ "root" "seth" ];
  virtualisation = {
    docker.enable = true;
    oci-containers = {
      backend = "docker";
      containers = {
        pihole = {
          autoStart = true;
          image = "pihole/pihole:latest";
          ports = [ "0.0.0.0:53:53/tcp" "0.0.0.0:53:53/udp" "0.0.0.0:8080:80/tcp" ];
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
      allowedTCPPorts = [ 22 53 8080 ]; # SSH, DNS, Pi-hole web interface
      allowedUDPPorts = [ 53 ]; # DNS
    };
  };
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  environment.systemPackages = with pkgs; [
    eza
    bat
  ];
}