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
      hooks.qemu.win11-gaming = pkgs.writeScript "qemu-hook-win11-gaming" ''
        #!${pkgs.bash}/bin/bash
        OPERATION="$2"
        SUB_OPERATION="$3"
        
        if [ "$OPERATION" == "prepare" ] && [ "$SUB_OPERATION" == "begin" ]; then
          # Start script - unbind GPU
          set -x
          systemctl stop display-manager.service
          sleep 5
          
          for vtcon in /sys/class/vtconsole/vtcon*/bind; do
            [ -f "$vtcon" ] && echo 0 > "$vtcon"
          done
          
          [ -e /sys/bus/platform/drivers/efi-framebuffer/efi-framebuffer.0 ] && \
            echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind
          
          ${pkgs.kmod}/bin/modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia
          sleep 2
          
          ${pkgs.libvirt}/bin/virsh nodedev-detach pci_0000_01_00_0
          ${pkgs.libvirt}/bin/virsh nodedev-detach pci_0000_01_00_1
          
          ${pkgs.kmod}/bin/modprobe vfio vfio_pci vfio_iommu_type1
          
        elif [ "$OPERATION" == "release" ] && [ "$SUB_OPERATION" == "end" ]; then
          # Stop script - rebind GPU
          set -x
          ${pkgs.kmod}/bin/modprobe -r vfio_pci vfio_iommu_type1 vfio
          
          ${pkgs.libvirt}/bin/virsh nodedev-reattach pci_0000_01_00_0
          ${pkgs.libvirt}/bin/virsh nodedev-reattach pci_0000_01_00_1
          sleep 2
          
          ${pkgs.kmod}/bin/modprobe nvidia nvidia_modeset nvidia_drm nvidia_uvm
          
          for vtcon in /sys/class/vtconsole/vtcon*/bind; do
            [ -f "$vtcon" ] && echo 1 > "$vtcon"
          done
          
          [ -e /sys/bus/platform/drivers/efi-framebuffer ] && \
            echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind 2>/dev/null || true
          
          sleep 3
          systemctl start display-manager.service
        fi
      '';
    };
    docker = { 
      enable = true;
      daemon.settings.insecure-registries = [ "192.168.1.100:5000" ];
    };
  };
  programs.virt-manager.enable = true;
}
