{ pkgs, ... }: {
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        vhostUserPackages = with pkgs; [ virtiofsd ];
        swtpm.enable = true;
      };
    };
    docker = { 
      enable = true;
      daemon.settings.insecure-registries = [ "192.168.1.100:5000" ];
    };
  };
  programs.virt-manager.enable = true;
}
