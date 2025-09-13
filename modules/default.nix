{ self, inputs, config, ... }: {
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
        home.stateVersion = "23.11";
        programs = {
          eza.enable = true;
          bat.enable = true;
        };
      };
    };
    backupFileExtension = "hm-backup";
    sharedModules = [
      inputs.nixcord.homeModules.nixcord
    ];
  };
}