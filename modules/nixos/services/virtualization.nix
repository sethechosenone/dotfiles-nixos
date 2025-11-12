{ pkgs, config, ... }: {
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        vhostUserPackages = with pkgs; [ virtiofsd ];
        swtpm.enable = true;
      };
    };
    docker.enable = true;
  };
  programs.virt-manager.enable = true;
}