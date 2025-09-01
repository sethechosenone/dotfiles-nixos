{ pkgs, config, ... }: {
  services = {
    swaync.enable = true;
    swayosd.enable = true;
  };
}