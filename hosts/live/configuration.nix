{ pkgs, ... }: {
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
  ];
}
