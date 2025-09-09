{ pkgs, lib, config, ... }: {
  imports = [
    ./programs
    ./services
  ];
  home.stateVersion = "23.11";
  gtk.enable = true;
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };
}