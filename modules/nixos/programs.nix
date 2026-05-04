{ pkgs, inputs, ...}: {
  programs = {
    hyprland = {
      enable = true; # this will allow us to actually log into a hyprland session
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      withUWSM = true;
    };
    zsh.enable = true; # this is also mentioned in the home-manager config, but it yells at you if this does not exist outside of it
    git.enable = true;
    zoom-us.enable = true;
    dconf.enable = true;
    gdk-pixbuf.modulePackages = with pkgs; [ librsvg ];
    regreet = {
      enable = true;
      settings.widget.clock.format = "%a %b %d - %I:%M %p";
    };
    ghidra.enable = true;
    screen.enable = true;
    #wireshark = {
    #  enable = true;
    #  package = pkgs.wireshark;
    #};
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    ssh.extraConfig = ''
      Host arm-builder
        HostName 129.80.42.135
        User opc
        StrictHostKeyChecking accept-new
    '';
  };
}
