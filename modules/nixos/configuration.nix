# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }: {
  nix = {
    package = pkgs.nixVersions.stable;
    extraOptions = "experimental-features = nix-command flakes";
  };
  nixpkgs = {
    overlays =
      [ (final: prev: { sudo = prev.sudo.override { withInsults = true; }; }) ];
    config.allowUnfree = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot = {
        enable = lib.mkForce false;
        edk2-uefi-shell.enable = true;
      };
      efi.canTouchEfiVariables = true;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    kernel.sysctl."kernel.sysrq" = 1;
    kernelPackages = pkgs.linuxPackages_latest;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    keyMap = lib.mkDefault "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  hardware = {
    graphics.enable = true;
    bluetooth.enable = true;
    sane = {
      enable = true;
      extraBackends = with pkgs; [ hplipWithPlugin ];
    };
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    printing = {
      enable = true;
      openFirewall = true;
      drivers = with pkgs; [ hplipWithPlugin ];
    };
    blueman.enable = true;
    pipewire = {
      enable = true;
      wireplumber.enable = true;
    };
    gnome.gnome-keyring.enable = true;
    libinput.enable = true;
    fprintd.enable = true;
    fwupd.enable = true;
    greetd.enable = true;
    udev.packages = with pkgs; [ swayosd ];
    tailscale.enable = true;
  };

  environment.sessionVariables = { 
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    seth = {
      isNormalUser = true;
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
      ]; # Enable ‘sudo’ for the user.
      packages = with pkgs; [
        tree
        hyprland-qtutils
        hyprpicker
        hyprshot
        hyprsysteminfo
        dconf
        nixpkgs-fmt
        claude-code
        libreoffice
        nmap
      ];
      shell = pkgs.zsh;
    };
    root.shell = pkgs.zsh;
  };

  programs = {
    hyprland.enable = true; # this will allow us to actually log into a hyprland session
    zsh.enable = true; # this is also mentioned in the home-manager config, but it yells at you if this does not exist outside of it
    git.enable = true;
    dconf.enable = true;
    gdk-pixbuf.modulePackages = with pkgs; [ librsvg ];
    regreet.enable = true;
    ghidra.enable = true;
    adb.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    defaultPackages = with pkgs; [
      rsync
      strace
      python3
      pipx
    ];
    systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      meson
      wayland-protocols
      wayland-utils
      wl-clipboard
      wlroots
      networkmanagerapplet
      pavucontrol
      pamixer
      man-pages
      man-pages-posix
      brightnessctl
      glib
      sl
      sbctl
      file
      usbutils
      swayosd
      mpv
      imv
    ];
  };

  security = {
    rtkit.enable = true;
    sudo.package = pkgs.sudo.override { withInsults = true; };
    pam.services = {
      hyprlock.text = ''
        auth sufficient ${pkgs.linux-pam}/lib/security/pam_unix.so try_first_pass likeauth nullok
        auth sufficient ${pkgs.linux-pam}/lib/security/pam_fprintd.so
        auth include login
      '';
      polkit-1.fprintAuth = false; # really wonky with hyprpolkitagent unfortunately :(
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