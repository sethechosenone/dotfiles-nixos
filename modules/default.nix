{ self, inputs, ... }: {
  imports = [
    ./nixos
    ./shell
  ];
  home-manager = {
    extraSpecialArgs = { inherit self inputs; };
    useUserPackages = true;
    useGlobalPkgs = true;
    users = {
      seth = import ./home;
      root = {
        imports = [ home/programs/neovim.nix ];
        home.stateVersion = "23.11";
        programs = {
          eza.enable = true;
          bat.enable = true;
          direnv.enable = true;
        };
      };
    };
    backupFileExtension = "hm-backup";
    sharedModules = [
      inputs.nixcord.homeModules.nixcord
    ];
  };
}
