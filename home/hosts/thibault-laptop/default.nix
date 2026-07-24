{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    "${inputs.hektor-nix}/home/modules"
    ./local-overrides.nix
  ];

  home = {
    stateVersion = "25.05";
    inherit (config.host) username;
    homeDirectory = "/home/${config.host.username}";
  };

  xdg.userDirs = {
    enable = false;
    createDirectories = false;
  };

  modules."3d".printing.enable = true;
  ai-tools = {
    claude-code.enable = true;
    opencode.enable = true;
  };
  anki.enable = false;
  audio.enable = true;
  browser.enable = true;
  browser.primary = "librewolf";
  cloud.hetzner.enable = true;
  comms.signal.enable = true;
  desktop.niri.enable = true;
  devenv.enable = true;
  direnv.enable = true;
  git.enable = true;
  git.github.enable = true;
  k8s.k9s.enable = true;
  keepassxc.enable = true;
  music.enable = true;
  my.yubikey.enable = true;
  nfc.enable = true;
  nvim.enable = true;
  pandoc.enable = true;
  secrets.enable = false;
  shell = {
    enable = true;
    bash.aliases.lang-js = true;
    bash.addBinToPath = true;
  };
  ssh.enable = true;
  deploy.enable = true;
  taskwarrior.enable = false;
  terminal.enable = true;
  reference-manager.enable = true;

  programs = {
    home-manager.enable = true;
  };

  home.packages = import ../packages.nix {
    inherit pkgs;
    inherit config;
  };
}
