{
  description = "System config for all my NixOS systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    rust-overlay.url = "github:oxalica/rust-overlay";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    led-matrix-sysinfo.url = "github:sethechosenone/led-matrix-sysinfo";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, nixos-hardware, stylix, led-matrix-sysinfo, lanzaboote, sops-nix, ... }:
    let
      system = "x86_64-linux";
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
            lanzaboote.nixosModules.lanzaboote
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
            led-matrix-sysinfo.nixosModules.led-matrix-sysinfo
            ./modules
            ./hosts/SA-Framework16
          ];
        };
        SA-PowerTower = lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self inputs;
          };
          modules = [
            nixos-hardware.nixosModules.gigabyte-b650
            home-manager.nixosModules.home-manager
            stylix.nixosModules.stylix
            lanzaboote.nixosModules.lanzaboote
            ./modules
            ./hosts/SA-PowerTower
          ];
        };
        SA-RaspberryPi4 = lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit self inputs;
          };
          modules = [
            (nixpkgs + "/nixos/modules/installer/sd-card/sd-image-aarch64.nix")
            stylix.nixosModules.stylix # for neovim
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            ./modules/shell
            ./modules/nixos/style
            ./hosts/SA-RaspberryPi4
          ];
        };
        installer = lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self inputs;
          };
          modules = [
            stylix.nixosModules.stylix
            (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
            home-manager.nixosModules.home-manager
            ./hosts/live
            ./modules/shell
            ./modules/nixos/style
          ];
        };
      };
      packages.${system}.installer = self.nixosConfigurations.installer.config.system.build.isoImage;
      packages.aarch64-linux.sd-image = self.nixosConfigurations.SA-RaspberryPi4.config.system.build.sdImage;
    };
}
