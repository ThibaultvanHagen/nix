{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.dconf;
  terminal = "kitty";
  browser = config.browser.primary;
  font = "${config.stylix.fonts.monospace.name} ${toString config.stylix.fonts.sizes.applications}";
in
{
  options.my.dconf = {
    enable = lib.mkEnableOption "dconf";
  };

  config = lib.mkIf cfg.enable {
    dconf.settings = {
      "org/gnome/desktop/background" = {
        color-shading-type = "solid";
        picture-options = "zoom";
        picture-uri = "none";
        picture-uri-dark = "none";
        primary-color = "#555555";
        secondary-color = "#555555";
        show-desktop-icons = false;
      };

      "org/gnome/desktop/default-applications/office/calendar" = {
        exec = "${browser} https://calendar.proton.me";
        needs-term = false;
      };

      "org/gnome/desktop/default-applications/office/tasks" = {
        exec = "task";
        needs-term = true;
      };

      "org/gnome/desktop/default-applications/terminal" = {
        exec = terminal;
        exec-arg = "";
      };

      "org/gnome/desktop/input-sources" = {
        xkb-options = [ "caps:none" ];
      };

      "org/gnome/desktop/interface" = {
        clock-format = "24h";
        clock-show-weekday = true;
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
        # font-name = font;
        locate-pointer = true;
        monospace-font-name = font;
      };

      "org/gnome/desktop/wm/keybindings" = {
        close = [ "<Shift><Super>Delete" ];
        minimize = [ "<Super>h" ];
        move-to-monitor-down = [ "<Super><Shift>Down" ];
        move-to-monitor-left = [ "<Super><Shift>Left" ];
        move-to-monitor-right = [ "<Super><Shift>Right" ];
        move-to-monitor-up = [ "<Super><Shift>Up" ];
        move-to-workspace-1 = [ "<Super><Shift>a" ];
        move-to-workspace-2 = [ "<Super><Shift>s" ];
        move-to-workspace-3 = [ "<Super><Shift>d" ];
        move-to-workspace-4 = [ "<Super><Shift>f" ];
        move-to-workspace-5 = [ "<Super><Shift>g" ];
        switch-applications = [ "<Super>j" ];
        switch-applications-backward = [ "<Super>k" ];
        switch-to-workspace-1 = [ "<Super>a" ];
        switch-to-workspace-2 = [ "<Super>s" ];
        switch-to-workspace-3 = [ "<Super>d" ];
        switch-to-workspace-4 = [ "<Super>f" ];
        switch-to-workspace-5 = [ "<Super>g" ];
      };

      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 5;
        workspace-names = [
          "sh"
          "www"
          "dev"
          "info"
          "etc"
        ];
      };

      "org/gnome/mutter" = {
        center-new-windows = true;
        dynamic-workspaces = false;
      };

      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-schedule-automatic = true;
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "Print";
        command = "flameshot gui";
        name = "flameshot";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        binding = "<Super>Return";
        command = terminal;
        name = "Kitty";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        binding = "<Super><Shift>m";
        command = "${terminal} --class=whisper-float -o remember_window_size=no -o initial_window_width=800 -o initial_window_height=300 whisper-realtime";
        name = "Whisper Voice to Text";
      };

      "org/gnome/settings-daemon/plugins/power" = {
        power-button-action = "suspend";
      };

      "org/gnome/shell/app-switcher" = {
        current-workspace-only = true;
      };

      "org/gnome/shell/keybindings" = {
        toggle-application-view = [ "<Super>p" ];
        toggle-quick-settings = [ ];
      };
    };

    home.packages = with pkgs; [ dconf2nix ];
  };
}
