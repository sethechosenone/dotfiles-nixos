{ pkgs, lib, ... }: {
  boot = {
    loader.generic-extlinux-compatible.enable = true;
    kernelPackages = pkgs.linuxPackages_rpi02w;
    kernelModules = [ "g_cdc" ];
    kernelParams = [];
  };
  hardware.firmware = [ pkgs.raspberrypiWirelessFirmware ];
  sdImage = {
    compressImage = false;
    extraFirmwareConfig = {
      dtoverlay = "dwc2,dr_mode=peripheral";
      gpu_mem = 16;
      core_freq = 250;
    };
  };
  nix.settings = {
    trusted-users = [ "root" "seth" ];
    experimental-features = [ "nix-command" "flakes" ];
  };
  nixpkgs = {
    overlays = [
      (final: prev: { sudo = prev.sudo.override { withInsults = true; }; })
      (final: prev: { makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; }); })
    ];
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
  networking = {
    hostName = "SA-RaspberryPiZero2W";
    interfaces.usb0.ipv4.addresses = [{
      address = "192.168.7.2";
      prefixLength = 24;
    }];
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };
  console = {
    packages = [ pkgs.powerline-fonts ];
    earlySetup = true;
    font = "ter-powerline-v24b";
    keyMap = lib.mkDefault "us";
  };
  services.openssh.enable = true;
  systemd.services."serial-getty@ttyGS0" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Environment = "TERM=xterm-256color";
      Restart = "always";
    };
  };
  hardware.deviceTree = {
    enable = true;
    filter = "*rpi-zero-2*.dtb";
    overlays = [{
      name = "dwc2-otg";
      dtsText = ''
        /dts-v1/;
        /plugin/;
        / {
          compatible = "brcm,bcm2837";
          fragment@0 {
            target-path = "/soc/usb@7e980000";
            __overlay__ {
              compatible = "brcm,bcm2835-usb";
              dr_mode = "peripheral";
            };
          };
        };
      '';
    }];
  };
  environment.systemPackages = with pkgs; [
    sl
    eza
    bat
    kitty.terminfo
  ];
  system.stateVersion = "26.05";
}
