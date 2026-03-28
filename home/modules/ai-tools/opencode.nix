{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.ai-tools.opencode;
in
{
  options.ai-tools.opencode = {
    enable = lib.mkEnableOption "opencode";
    openrouter.enable = lib.mkEnableOption "openrouter provider for opencode";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.opencode ];

    home.file.".config/opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      permission = {
        external_directory = {
          "/run/secrets/" = "deny";
          "~/.config/sops/age/keys.txt" = "deny";
          "~/.ssh/id_rsa" = "deny";
          "~/.ssh/id_ed25519" = "deny";
          "~/.ssh/id_ecdsa" = "deny";
          "~/.ssh/id_dsa" = "deny";
          "/etc/ssh/ssh_host_rsa_key" = "deny";
          "/etc/ssh/ssh_host_ed25519_key" = "deny";
          "/etc/ssh/ssh_host_ecdsa_key" = "deny";
          "/etc/ssh/ssh_host_dsa_key" = "deny";
        };
        command = {
          sops = "deny";
        };
      };
      plugin = [ "@mohak34/opencode-notifier@latest" ];
    };
  };
}
