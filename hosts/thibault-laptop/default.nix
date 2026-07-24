{
  lib,
  inputs,
  config,
  pkgs,
  ...
}:

let
  meta = import ./meta.nix;
in
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    # inputs.nixos-hardware.nixosModules.lenovo-thinkpad-e14-intel-gen7 (not available yet?)
    "${inputs.hektor-nix}/modules"
    (import "${inputs.hektor-nix}/modules/disko/zfs-encrypted-root.nix" {
      inherit lib config;
      device = "/dev/nvme0n1";
    })
  ];

  inherit (meta) host;

  hardware.facter.reportPath = ./facter.json;
  home-manager.users.${config.host.username} = import ../../home/hosts/${config.host.name};

  "ai-tools".enable = true;
  audio.enable = true;
  bluetooth.enable = true;
  bootloader.enable = true;
  desktop.gnome.enable = true;
  git.enable = true;
  keyboard.enable = true;
  localization.enable = true;
  my = {
    fonts.enable = true;
    stylix.enable = true;
    users.enable = true;
  };
  networking.enable = true;
  secrets.enable = false;
  ssh.enable = true;
  storage.enable = true;

  secrets.nixSigningKey.enable = false;
  tailscale.enable = true;
  docker.enable = true;

  firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  nixpkgs.allowedUnfree = [ "bambu-studio" ];

  hardware = {
    cpu.intel.updateMicrocode = true;
    # https://wiki.nixos.org/wiki/Intel_Graphics
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vpl-gpu-rt
        intel-compute-runtime
      ];
    };
  };

  # https://wiki.nixos.org/wiki/Intel_Graphics
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  environment.systemPackages = [
    pkgs.scantailor-universal
    (pkgs.writeShellApplication {
      name = "wol-andromache";
      runtimeInputs = [ pkgs.wakeonlan ];
      text = ''
        wakeonlan ${(import "${inputs.hektor-nix}/hosts/andromache/wol-interfaces.nix").eno1.macAddress}
      '';
    })
  ];

  networking = {
    hostId = "80eef97e";
    useDHCP = false;
    useNetworkd = true;
  };

  systemd.network.networks."40-wlan0" = {
    matchConfig.Name = "wlan0";
    networkConfig.DHCP = "yes";
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services = {
    fwupd.enable = true;
    locate = {
      enable = true;
      package = pkgs.plocate;
    };
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;
      };
    };
  };

  virtualisation.virtualbox.host.enable = true;
  users.users.${config.host.username}.extraGroups = [ "vboxusers" ];
}
