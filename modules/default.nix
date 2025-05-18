{ config, inputs, ... }: {
  imports = [
    ./nixos
    ./shell
  ];
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    useUserPackages = true;
    useGlobalPkgs = true;
    users.seth = import ./home;
    backupFileExtension = "hm-backup";
  };
}