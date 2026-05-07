{ pkgs, ... }: {
  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
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
      pulse.enable = true;
    };
    gnome.gnome-keyring.enable = true;
    libinput.enable = true;
    fprintd.enable = true;
    upower.enable = true;
    gvfs.enable = true;
    fwupd.enable = true;
    greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.cage}/bin/cage -s -d -- ${pkgs.regreet}/bin/regreet";
        user = "greeter";
      };
    };
    udev.packages = with pkgs; [ swayosd ];
    tailscale.enable = true;
    mullvad-vpn.enable = true;
  };
}
