{
  inputs = {
    hektor-nix.url = "github:hektor/nix";
    nixpkgs.follows = "hektor-nix/nixpkgs";
    home-manager.follows = "hektor-nix/home-manager";
    disko.follows = "hektor-nix/disko";
    nixos-hardware.follows = "hektor-nix/nixos-hardware";
    sops-nix.follows = "hektor-nix/sops-nix";
    stylix.follows = "hektor-nix/stylix";
    firefox-addons.follows = "hektor-nix/firefox-addons";
    git-hooks.follows = "hektor-nix/git-hooks";
    nvim = {
      url = "github:hektor/nix?dir=dots/.config/nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      hektor-nix,
      git-hooks,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      inherit (inputs.nixpkgs) lib;
      myUtils = import "${hektor-nix}/utils" { inherit lib; };
      hostDirNames = myUtils.dirNames ./hosts;
      system = "x86_64-linux";
      dotsPath = "${hektor-nix}/dots";
      gitHooks = import ./git-hooks.nix {
        inherit nixpkgs git-hooks system;
        src = ./.;
      };
    in
    {
      nixosConfigurations = lib.genAttrs hostDirNames (
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
      );

      checks.${system} = gitHooks.checks;
      formatter.${system} = gitHooks.formatter;
      devShells.${system} = gitHooks.devShells;

      packages.${system} = import ./pkgs {
        pkgs = import nixpkgs { inherit system; };
      };
    };
}
