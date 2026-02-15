# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ lib, pkgs, config, ... }: {
  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
      substituters = [ "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      builders-use-substitutes = true;
    };
    buildMachines = [{
      hostName = "arm-builder";
      system = "aarch64-linux";
      maxJobs = 4;
      speedFactor = 10;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [];
    }];
    distributedBuilds = true;
  };
  nixpkgs = {
    overlays =
      [ (final: prev: { sudo = prev.sudo.override { withInsults = true; }; }) ];
    config.allowUnfree = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      limine = {
        enable = true;
        secureBoot.enable = true;
        maxGenerations = 20;
        additionalFiles = {
          "efi/shell/shell.efi" = "${pkgs.edk2-uefi-shell}/shell.efi";
          "efi/memtest86/memtest86.efi" = "${pkgs.memtest86-efi}/BOOTX64.efi";
        };
        extraEntries = ''
          /+Utilities
          //UEFI Shell
          protocol: efi
          comment: Make sure secure boot is disabled! The nix store for the shell can't be signed
          image_path: boot():/limine/efi/shell/shell.efi
          //Memtest86
          protocol: efi
          comment: Test for memory issues
          image_path: boot():/limine/efi/memtest86/memtest86.efi
        '';
      };
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl."kernel.sysrq" = 1;
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "drm.panic_screen=qr_code" ];
  };

  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [ networkmanager-openvpn ];
  };

  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    packages = [ pkgs.powerline-fonts ];
    font = "ter-powerline-v24b";
    keyMap = lib.mkDefault "us";
    useXkbConfig = true; # use xkb.options in tty.
    earlySetup = true;
  };

  hardware = {
    graphics.enable = true;
    bluetooth.enable = true;
    sane = {
      enable = true;
      extraBackends = with pkgs; [ hplipWithPlugin ];
    };
  };
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    seth = {
      isNormalUser = true;
      initialPassword = "change-me-after-install!"; # change this after first login!
      extraGroups = [
        "wheel"
        "video"
        "audio"
        "networkmanager"
        "lp"
        "scanner"
        "libvirtd"
        "docker"
        "adbusers"
        "wireshark"
        "kvm"
      ] ++ lib.optionals (config.networking.hostName == "SA-PowerTower") [
        "i2c"
      ];
      packages = with pkgs; [
        tree
        hyprland-qtutils
        hyprpicker
        hyprsysteminfo
        dconf
        nixpkgs-fmt
        claude-code
        libreoffice
        nmap
        metasploit
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH9xlfU47R64W8FucsZ+kRq4nTmptXXomUkz4bFJyBE8 seth@SA-Framework16"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPNh0st4w3qchaLTrRHKdI5W2omWKZ+9nUNBgO9e69E4 seth@SA-PowerTower"
      ];
    };
    root.shell = pkgs.zsh;
  };
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    defaultPackages = with pkgs; [
      nil
      rsync
      strace
      python3
    ];
    systemPackages = with pkgs; [
      wget  meson  wayland-protocols  wayland-utils  wl-clipboard  wlroots  wf-recorder
      networkmanagerapplet  pavucontrol  pamixer  man-pages  man-pages-posix  brightnessctl
      glib  sl  sbctl  file  usbutils  mpv  imv  ags  ripgrep  whois  dig  nautilus  android-tools
      dmidecode  i2c-tools  zip  unzip  libgtop  tpm2-tools  tpm2-tss
    ];
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    };
    etc."hosts".mode = "0644";
  };

  security = {
    tpm2.enable = true;
    rtkit.enable = true;
    sudo.package = pkgs.sudo.override { withInsults = true; };
    pam = {
      services = {
        hyprlock.text = ''
          auth sufficient ${pkgs.linux-pam}/lib/security/pam_unix.so try_first_pass likeauth nullok
          auth sufficient ${pkgs.linux-pam}/lib/security/pam_fprintd.so
          auth include login
        '';
        polkit-1.fprintAuth = false; # really wonky with hyprpolkitagent unfortunately :(
        greetd.fprintAuth = false; # decryption will not take place if fingerprint is used
        fscrypt.fprintAuth = false;
      };
      enableFscrypt = true;
    };
    polkit.enable = true;
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?

}
