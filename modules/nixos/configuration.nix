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

  hardware.graphics.enable = true;

  services = {
    printing.enable = true;
    pipewire = {
      enable = true;
      wireplumber.enable = true;
    };
    gnome.gnome-keyring.enable = true;
    libinput.enable = true;
    fprintd.enable = true;
    greetd = {
      enable = true;
      settings.default_session.command = ''
        ${pkgs.greetd.wlgreet}/bin/tuigreet \
        --time \
        --asterisks \
        --user-menu \
        --cmd Hyprland
      '';
    };
  };

  environment = {
    etc."greetd/environments".text = "Hyprland";
    sessionVariables = { NIXOS_OZONE_WL = "1"; };
  };

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
    zsh.enable = true; # this is also mentioned in the home-manager config, but it yells at you if this does not exist outside of it
    dconf.enable = true;
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
    greetd.wlgreet
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
    libsForQt5.polkit-kde-agent
    glib
    direnv
    nixfmt-classic
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

