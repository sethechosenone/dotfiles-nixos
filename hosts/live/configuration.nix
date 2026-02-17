{ pkgs, lib, ... }: {
  nixpkgs = {
    overlays =
      [ (final: prev: { sudo = prev.sudo.override { withInsults = true; }; }) ];
    config.allowUnfree = true;
  };
  nix.settings = {
    trusted-users = [ "root" "nixos" ];
    experimental-features = [ "nix-command" "flakes" ];
  };
  users.users = {
    nixos.shell = pkgs.zsh;
    root.shell = pkgs.zsh;
  };
  home-manager = {
    users = {
      nixos = import ./home.nix;
      root = import ./home.nix;
    };
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "hm-backup";
  };
  boot = {
    kernel.sysctl."kernel.sysrq" = 1;
    kernelParams = [ "drm.panic_screen=qr_code" ];
  };
  console = {
    packages = [ pkgs.powerline-fonts ];
    font = "ter-powerline-v24b";
    useXkbConfig = true;
    earlySetup = true;
  };
  systemd.services.reload-systemd-vconsole-setup.serviceConfig.ExecStart =
    lib.mkForce (pkgs.writeShellScript "reset-console" ''
      until test -c /dev/dri/card1; do sleep 1; done
      ${pkgs.systemd}/lib/systemd/systemd-vconsole-setup
    '');
  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    direnv.enable = true;
  };
  environment.systemPackages = with pkgs; [
    sl
    sbctl
    binwalk
    file
  ];
}
