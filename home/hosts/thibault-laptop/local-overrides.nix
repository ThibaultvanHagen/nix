{ lib, ... }:
{
  # patches on top of "${inputs.hektor-nix}/home/modules" that only apply
  # to this host — not upstreamed since they're either host-specific
  # (keyboard layout) or in-progress (openrouter option isn't wired up yet)

  options.ai-tools.opencode = {
    openrouter.enable = lib.mkEnableOption "openrouter provider for opencode";
  };

  config = {
    home.file.".config/niri/config.kdl".source = lib.mkForce ./niri-config.kdl;

    dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = lib.mkForce [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        binding = "<Super><Shift>m";
        command = "kitty --class=whisper-float -o remember_window_size=no -o initial_window_width=800 -o initial_window_height=300 whisper-realtime";
        name = "Whisper Voice to Text";
      };
    };
  };
}
