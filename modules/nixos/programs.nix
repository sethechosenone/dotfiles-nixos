{ pkgs, ...}: {
  programs = {
    hyprland.enable = true; # this will allow us to actually log into a hyprland session
    zsh.enable = true; # this is also mentioned in the home-manager config, but it yells at you if this does not exist outside of it
    git.enable = true;
    dconf.enable = true;
    gdk-pixbuf.modulePackages = with pkgs; [ librsvg ];
    regreet.enable = true;
    ghidra.enable = true;
    adb.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark-qt;
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
