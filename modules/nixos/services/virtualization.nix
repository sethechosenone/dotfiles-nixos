{ pkgs, ... }: {
  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        vhostUserPackages = with pkgs; [ virtiofsd ];
        swtpm.enable = true;
        verbatimConfig = ''
          namespaces = []
          user = "root"
          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm",
            "/dev/kvmfr0"
          ]
        '';
      };
    };
    docker = { 
      enable = true;
      daemon.settings.insecure-registries = [ "192.168.1.100:5000" ];
    };
  };
  programs.virt-manager.enable = true;
}
