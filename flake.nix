{
  description = "System config for all my NixOS systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    led-matrix-sysinfo.url = "github:sethechosenone/led-matrix-sysinfo";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, nixos-hardware, stylix, led-matrix-sysinfo, lanzaboote, ... }:
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
            inputs.lanzaboote.nixosModules.lanzaboote
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
            lanzaboote.nixosModules.lanzaboote
            led-matrix-sysinfo.nixosModules.default
            ./modules
            ./hosts/SA-Framework16
          ];
        };
        installer = lib.nixosSystem {
          inherit system;
          modules = [
            stylix.nixosModules.stylix
            (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
            ./hosts/live
            ./modules/shell
            ./modules/nixos/style
          ];
        };
      };
      packages.${system}.installer = self.nixosConfigurations.installer.config.system.build.isoImage;
    };
}
