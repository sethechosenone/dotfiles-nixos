{ pkgs, ... }: {
  boot.loader.generic-extlinux-compatible.enable = true;
  nix.settings = {
    trusted-users = [ "root" "seth" ];
    experimental-features = [ "nix-command" "flakes" ];
  };
  nixpkgs = {
    overlays = [ (final: prev: { sudo = prev.sudo.override { withInsults = true; }; }) ];
    config.allowUnfree = true;
  };
  security = {
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };
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
  networking.hostName = "SA-RaspberryPiZero2W";
  environment.systemPackages = with pkgs; [
    sl
    eza
    bat
    kitty.terminfo
    wireguard-tools
  ];
}
