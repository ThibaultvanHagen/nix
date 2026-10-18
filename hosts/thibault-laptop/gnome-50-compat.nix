{
  pkgs,
  ...
}:
{
  # GNOME 50 Wayland setup (hektor-nix desktop.gnome has compatibility issues)
  # In GNOME 50, Wayland is the default session and is automatically enabled
  services = {
    displayManager.gdm.enable = true;
    xserver.enable = true;
    desktopManager.gnome.enable = true;
    power-profiles-daemon.enable = false;
  };

  environment.systemPackages = with pkgs; [
    gnome-shell
    gnome-shell-extensions
  ];
}
