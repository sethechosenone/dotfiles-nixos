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
    openrgb-effects = {
      url = "github:sethechosenone/openrgb-effects";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-pi-zero-2.url = "github:plmercereau/nixos-pi-zero-2";
    hyprland = {
      url = "github:hyprwm/Hyprland/v0.54.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprgrass = {
      url = "github:horriblename/hyprgrass/a2643f311851cdb70c8d742e6edde4112c841463";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, nixos-hardware, stylix, led-matrix-sysinfo, sops-nix, openrgb-effects, nixos-pi-zero-2, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        SA-Framework12 = lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit self inputs;
          };
          modules = [
            nixos-hardware.nixosModules.framework-12-13th-gen-intel
            home-manager.nixosModules.home-manager
            stylix.nixosModules.stylix
            ./modules
            ./hosts/SA-Framework12
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
            openrgb-effects.nixosModules.openrgb-effects
            stylix.nixosModules.stylix
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
        SA-RaspberryPiZero2W = lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = {
            inherit self inputs;
          };
          modules = [
            nixos-pi-zero-2.nixosModules.sd-image
            # stylix.nixosModules.stylix # uncomment after initial boot when neovim is re-enabled
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            ./modules/shell
            #./modules/nixos/style
            ./hosts/SA-RaspberryPiZero2W
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
