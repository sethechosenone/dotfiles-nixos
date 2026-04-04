{ pkgs, ... }: {
  virtualisation.libvirtd.hooks.qemu."win11-gaming" = pkgs.writeShellScript "win11-gaming" ''
    VM_NAME="$1"
    OPERATION="$2"
    SUB_OPERATION="$3"
    if [ "$VM_NAME" != "win11-gaming" ]; then
      exit 0
    fi
    if [ "$OPERATION" == "prepare" ] && [ "$SUB_OPERATION" == "begin" ]; then
      set -ex
      ${pkgs.util-linux}/bin/umount /mnt/games1
      ${pkgs.util-linux}/bin/umount /mnt/games2 || true
      ${pkgs.systemd}/bin/systemctl stop display-manager.service
      ${pkgs.procps}/bin/pkill -f Hyprland || true
      ${pkgs.procps}/bin/pkill -9 -f Xwayland || true
      ${pkgs.systemd}/bin/systemctl stop deepcool-digital-linux
      ${pkgs.systemd}/bin/systemctl stop openrgb
      ${pkgs.systemd}/bin/systemctl stop openrgb-effects
      sleep 3
      ${pkgs.kmod}/bin/modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia
      sleep 2
      ${pkgs.kmod}/bin/modprobe vfio vfio_pci vfio_iommu_type1
      ${pkgs.systemd}/bin/systemctl start display-manager.service
      TIMEOUT=120
      ELAPSED=0
      while [ ! -S /run/user/1000/pipewire-0 ]; do
        if [ $ELAPSED -ge $TIMEOUT ]; then
          echo "Timed out waiting for PipeWire socket" >&2
          break
        fi
        sleep 1
        ELAPSED=$((ELAPSED + 1))
      done
      sleep 2
    elif [ "$OPERATION" == "release" ] && [ "$SUB_OPERATION" == "end" ]; then
      set -ex
      ${pkgs.systemd}/bin/systemctl stop display-manager.service
      ${pkgs.procps}/bin/pkill -f Hyprland || true
      ${pkgs.procps}/bin/pkill -f Xwayland || true
      sleep 3
      ${pkgs.kmod}/bin/modprobe -r vfio_pci vfio_iommu_type1 vfio
      sleep 2
      ${pkgs.kmod}/bin/modprobe nvidia nvidia_modeset nvidia_uvm
      ${pkgs.kmod}/bin/modprobe nvidia_drm
      ${pkgs.systemd}/bin/systemctl start display-manager.service || true
      ${pkgs.systemd}/bin/systemctl start deepcool-digital-linux || true
      ${pkgs.systemd}/bin/systemctl start openrgb || true
      ${pkgs.systemd}/bin/systemctl start openrgb-effects || true
      ${pkgs.util-linux}/bin/mount /mnt/games1
      ${pkgs.util-linux}/bin/mount /mnt/games2
    fi
  '';
}
