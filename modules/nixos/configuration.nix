# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ lib, pkgs, config, inputs, ... }: {
  nix = {
    package = pkgs.nixVersions.stable;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
      allowed-users = [ "root" "@wheel" ];
      substituters = [ "https://cache.nixos.org" "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      builders-use-substitutes = true;
    };
    buildMachines = [{
      hostName = "arm-builder";
      system = "aarch64-linux";
      sshKey = "/root/.ssh/id_ed25519";
      maxJobs = 4;
      speedFactor = 10;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [];
    }];
    distributedBuilds = true;
    gc = {
      automatic = true;
      dates = [ "0 1 * * 0" ];
    };
  };

  # Automatic monthly system updates for desktop machines
  system.autoUpgrade = let
    desktopHosts = [ "SA-Framework12" "SA-Framework16" "SA-PowerTower" ];
    isDesktop = builtins.elem config.networking.hostName desktopHosts;
  in lib.mkIf isDesktop {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input" "nixpkgs"
      "--update-input" "home-manager"
      "--update-input" "nixos-hardware"
      "--update-input" "stylix"
      "--update-input" "sops-nix"
      "--update-input" "nixcord"
      "--update-input" "firefox-addons"
      "--update-input" "led-matrix-sysinfo"
      "--update-input" "openrgb-effects"
      "--commit-lock-file"
      "-L"
    ];
    dates = "monthly";
    allowReboot = false;
    operation = "switch";
    persistent = true;
  };

  nixpkgs = {
    overlays =
      [ (final: prev: { sudo = prev.sudo.override { withInsults = true; }; }) ];
    config.allowUnfree = true;
  };

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
          comment: Make sure secure boot is disabled before using any EFI utilites! -- Access the UEFI shell for troubleshooting and development
          image_path: boot():/limine/efi/shell/shell.efi
          //Memtest86
          protocol: efi
          comment: Make sure secure boot is disabled before using any EFI utilites! -- Diagnose system memory issues and stress-test RAM modules
          image_path: boot():/limine/efi/memtest86/memtest86.efi
        '';
      };
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl."kernel.sysrq" = 1;
    kernelPackages = pkgs.linuxPackages_6_12;
    kernelParams = [ "drm.panic_screen=qr_code" "init_on_free=1" "init_on_alloc=1" "lockdown=confidentiality"  ];
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
        "wheel"  "video"  "audio"  "networkmanager"
        "lp"  "scanner"  "libvirtd"  "docker"
        "adbusers"  "wireshark"  "kvm"  "tss"  "input"
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
      dmidecode  i2c-tools  zip  unzip  libgtop  tpm2-tools  waypipe  sops  age  tio  jq
    ];
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    };
    etc."hosts".mode = "0644";
  };

  security = {
    tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };
    protectKernelImage = true;
    rtkit.enable = true;
    sudo = {
      package = pkgs.sudo.override { withInsults = true; };
      execWheelOnly = true;
    };
    pam = {
      services = {
        hyprlock.text = ''
          auth sufficient ${pkgs.linux-pam}/lib/security/pam_unix.so try_first_pass likeauth nullok
          auth sufficient ${pkgs.linux-pam}/lib/security/pam_fprintd.so
          auth include login
        '';
        polkit-1.fprintAuth = false; # really wonky with hyprpolkitagent unfortunately :(
        # greetd.fprintAuth = false; # fscrpyt decryption will not take place if fingerprint is used
        fscrypt.fprintAuth = false; # will break passphrase encryption otherwise, learned that the hard way :/
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
