config: {
  imports = [
    ./hypr.nix
    ./hyprland.nix
    ./hyprlock.nix
    ./ashell.nix
#   ./hyprpanel.nix
#   ./waybar.nix
#   ./wlogout.nix
#   ./swaync.nix  # swaync enabled via ashell.nix; swayosd skipped (ashell has built-in OSD)
  ];
}
