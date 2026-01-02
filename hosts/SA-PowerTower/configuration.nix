{ pkgs }: {
  imports = [ ./hardware-configuration.nix ];
  networking.hostName = "SA-PowerTower";
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  environment.systemPackages = with pkgs; [ 
    looking-glass-client
    openrgb
  ];
}
