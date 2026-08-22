{ pkgs, ...}: {
  programs = {
    hyprland = {
      enable = true; # this will allow us to actually log into a hyprland session
      withUWSM = true;
    };
    zsh.enable = true; # this is also mentioned in the home-manager config, but it yells at you if this does not exist outside of it
    git.enable = true;
    zoom-us.enable = true;
    dconf.enable = true;
    localsend.enable = true;
    gdk-pixbuf.modulePackages = with pkgs; [ librsvg ];
    ghidra.enable = true;
    screen.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
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
