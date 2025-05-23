# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

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
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    hostName = "SA-Framework";
    networkmanager.enable = true;
  };

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
  };

  services = {
    printing.enable = true;
    pipewire = {
      enable = true;
      wireplumber.enable = true;
    };
    gnome.gnome-keyring.enable = true;
    libinput.enable = true;
    fprintd.enable = true;
    greetd.enable = true;
  };

  systemd.user = {
    timers."blue-light-filter" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 21:00:00";
        Unit = "blue-light-filter.service";
      };
    };
    services."blue-light-filter" = {
      unitConfig = {
        Description = "Blue light filter service to be used with the corresponding timer";
        PartOf = "graphical-session.target";
        After = "graphical-session.target";
        ConditionEnvironment = "WAYLAND_DISPLAY";
      };
      serviceConfig = {
        Type = "simple";
        RuntimeMaxSec = 32400;
        ExecStart = "${lib.getExe pkgs.hyprsunset}";
        Slice = "session.slice";
        Restart = "on-failure";
      };
    };
  };

  environment.sessionVariables = { NIXOS_OZONE_WL = "1"; };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.seth = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
      "lp"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
      hyprpaper
      hyprpicker
      hyprshot
      lxappearance
      dconf
      discord
      nixpkgs-fmt
    ];
    shell = pkgs.zsh;
  };

  programs = {
    hyprland.enable = true; # this will allow us to actually log into a hyprland session from sddm
    zsh.enable = true; # this is also mentioned in the home-manager config, but it yells at you if this does not exist outside of it
    dconf.enable = true;
    regreet.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
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
    direnv
  ];

  security = {
    rtkit.enable = true;
    sudo.package = pkgs.sudo.override { withInsults = true; };
    pam.services.hyprlock.text = ''
      auth sufficient ${pkgs.linux-pam}/lib/security/pam_unix.so try_first_pass likeauth nullok
      auth sufficient ${pkgs.linux-pam}/lib/security/pam_fprintd.so
      auth include login
    '';
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

