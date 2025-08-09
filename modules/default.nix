{ self, inputs, config, ... }: {
  imports = [
    ./nixos
    ./shell
  ];
  home-manager = {
    extraSpecialArgs = { inherit self inputs; };
    useUserPackages = true;
    useGlobalPkgs = true;
    users.seth = import ./home;
    backupFileExtension = "hm-backup";
    sharedModules = [
      inputs.nixcord.homeModules.nixcord
    ];
  };
}