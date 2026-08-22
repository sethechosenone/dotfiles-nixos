{ pkgs, lib, ... }: {
  virtualisation = {
    vmVariant = {
      virtualisation = {
        cores = 4;
        memorySize = 4096;
        graphics = false;
      };
      networking.hostName = lib.mkForce "SA-VMTest";
      users.users.seth.initialPassword = lib.mkForce "vmtest";
    };
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        package = pkgs.qemu_kvm;
        vhostUserPackages = with pkgs; [ virtiofsd ];
        swtpm.enable = true;
        verbatimConfig = ''
          seccomp_sandbox = 0
          namespaces = []
          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm",
            "/dev/kvmfr0", "/dev/nvme1n1"
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
