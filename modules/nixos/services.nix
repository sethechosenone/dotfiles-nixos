{ pkgs, ... }: {
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
}
