{
  nixpkgs,
  git-hooks,
  system,
  src,
}:
let
  pkgs = nixpkgs.legacyPackages.${system};

  pre-commit-check = git-hooks.lib.${system}.run {
    inherit src;
    hooks = {
      nixfmt = {
        enable = true;
        package = pkgs.nixfmt;
      };
      statix.enable = true;
      deadnix.enable = true;
    };
  };
in
{
  checks = {
    inherit pre-commit-check;
  };

  formatter =
    let
      inherit (pre-commit-check) config;
      inherit (config) package configFile;
      script = ''
        ${pkgs.lib.getExe package} run --all-files --config ${configFile}
      '';
    in
    pkgs.writeShellScriptBin "pre-commit-run" script;

  devShells = {
    default =
      let
        inherit (pre-commit-check) shellHook enabledPackages;
      in
      pkgs.mkShell {
        inherit shellHook;
        buildInputs = enabledPackages;
      };
  };
}
