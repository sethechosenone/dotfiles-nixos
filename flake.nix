{
  description = "System config for all my NixOS systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "home-manager";
    }
    stylix = {
      url = "github:danth/stylix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, stylix, ... } @ inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        SA-Framework13 = lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self inputs;
          };
          modules = [
            nixos-hardware.nixosModules.framework-13th-gen-intel
            home-manager.nixosModules.home-manager
            stylix.nixosModules.stylix
            ./modules
            ./hosts/SA-Framework13
          ];
        };
        SA-Framework16 = lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self inputs;
          };
          modules = [
            nixos-hardware.nixosModules.framework-16-7040-amd
            home-manager.nixosModules.home-manager
            stylix.nixosModules.stylix
            ./modules
            ./hosts/SA-Framework16
          ];
        };
      };
    };
}
