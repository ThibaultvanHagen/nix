{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nix-secrets = {
    #   url = "git+ssh://git@github.com/hektor/nix-secrets?shallow=1&ref=main";
    #   flake = false;
    # };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hecuba-services = {
      url = "git+ssh://git@github.com/hektor/hecuba-services?shallow=1&ref=main";
      flake = false;
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvim = {
      url = "path:./dots/.config/nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      git-hooks,
      home-manager,
      nixgl,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      inherit (inputs.nixpkgs) lib;
      myUtils = import ./utils { inherit lib; };
      hostDirNames = myUtils.dirNames ./hosts;
      system = "x86_64-linux";
      dotsPath = ./dots;
      gitHooks = import ./git-hooks.nix {
        inherit nixpkgs git-hooks system;
        src = ./.;
      };
    in
    {
      nixosConfigurations =
        (lib.genAttrs hostDirNames (
          host:
          nixpkgs.lib.nixosSystem {
            modules = [
              ./hosts/${host}
              {
                nixpkgs.hostPlatform = (myUtils.hostMeta ./hosts/${host}).system;
                host.name = host;
              }
            ];
            specialArgs = {
              inherit
                inputs
                outputs
                dotsPath
                myUtils
                ;
            };
          }
        ))
        // {
          sd-image-orange-pi-aarch64 = nixpkgs.lib.nixosSystem {
            modules = [
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              ./images/sd-image-orange-pi-aarch64.nix
              {
                nixpkgs.buildPlatform = "x86_64-linux";
                nixpkgs.hostPlatform = "aarch64-linux";
              }
            ];
            specialArgs = {
              inherit
                inputs
                outputs
                dotsPath
                myUtils
                ;
            };
          };
          sd-image-raspberry-pi-aarch64 = nixpkgs.lib.nixosSystem {
            modules = [
              "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
              ./images/sd-image-raspberry-pi-aarch64.nix
              {
                nixpkgs.buildPlatform = "x86_64-linux";
                nixpkgs.hostPlatform = "aarch64-linux";
              }
            ];
            specialArgs = {
              inherit
                inputs
                outputs
                dotsPath
                myUtils
                ;
            };
          };
        };

      homeConfigurations = {
        work = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ nixgl.overlay ];
          };
          modules = [ ./home/hosts/work ];
          extraSpecialArgs = {
            osConfig = null;
            inherit
              inputs
              outputs
              dotsPath
              myUtils
              ;
          };
        };
      };

      apps.${system}.colmena = inputs.colmena.apps.${system}.default // {
        meta.description = "colmena";
      };

      colmenaHive = import ./deploy/colmena.nix {
        inherit
          self
          inputs
          ;
      };

      deploy = import ./deploy/deploy-rs.nix {
        inherit
          self
          inputs
          ;
      };

      checks.${system} = gitHooks.checks // inputs.deploy-rs.lib.${system}.deployChecks self.deploy;
      formatter.${system} = gitHooks.formatter;
      devShells.${system} = gitHooks.devShells;

      legacyPackages.${system} = {
        sd-image-orange-pi-aarch64 =
          self.nixosConfigurations.sd-image-orange-pi-aarch64.config.system.build.sdImage;
        sd-image-raspberry-pi-aarch64 =
          self.nixosConfigurations.sd-image-raspberry-pi-aarch64.config.system.build.sdImage;
      };
    };
}
