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
        imports = [
          home/programs/neovim.nix
          shell/starship-tty.nix
        ];
        home = {
          stateVersion = "23.11";
          pointerCursor.enable = true; # we're never logging in as root, but this shuts up the warning
        };
        programs = {
          eza.enable = true;
          bat.enable = true;
          direnv.enable = true;
          zsh = {
            enable = true;
            shellAliases = {
              ls = "eza --icons -l";
              edit = "nvim";
            };
          };
        };
      };
    };
    backupFileExtension = "hm-backup";
    sharedModules = [
      inputs.nixcord.homeModules.nixcord
    ];
  };
}
