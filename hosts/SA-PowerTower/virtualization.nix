{ pkgs, ... }: {
  virtualisation.libvirtd.hooks.qemu.win11-gaming = ''
    #!${pkgs.bash}/bin/bash
    OPERATION="$2"
    SUB_OPERATION="$3"
    if [ "$OPERATION" == "prepare" ] && [ "$SUB_OPERATION" == "begin" ]; then
      umount /mnt/games1
      umount /mnt/games2
      ${pkgs.kmod}/bin/modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia
      sleep 2
      ${pkgs.kmod}/bin/modprobe vfio vfio_pci vfio_iommu_type1
    elif [ "$OPERATION" == "release" ] && [ "$SUB_OPERATION" == "end" ]; then
      ${pkgs.kmod}/bin/modprobe -r vfio_pci vfio_iommu_type1 vfio
      sleep 2
      ${pkgs.kmod}/bin/modprobe nvidia nvidia_modeset nvidia_drm nvidia_uvm
      mount /mnt/games1
      mount /mnt/games2
    fi
  '';
}
