{ ... }: {
  services.hardware = {
    deepcool-digital-linux.enable = true;
    openrgb.enable = true;
  };
  systemd.tmpfiles.rules = [
    "f /dev/shm/looking-glass 0660 seth qemu-libvirtd -"
  ];
}
