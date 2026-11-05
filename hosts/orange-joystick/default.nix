{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  meta = import ./meta.nix;
in
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
    inputs.ender3-microscope.nixosModules.joystickd
    # minimal `host` option declarations — the laptop gets these from
    # hektor-nix/modules, but this appliance host doesn't import that set,
    # so without these the eval fails on `host.name`/`inherit (meta) host`
    {
      options.host = with lib; {
        name = mkOption {
          type = types.str;
          default = "orange-joystick";
        };
        username = mkOption {
          type = types.str;
          default = "thibault";
        };
        admin = mkOption {
          type = types.bool;
          default = true;
        };
      };
    }
  ];

  inherit (meta) host;

  boot = {
    loader.grub.enable = false;
    loader.generic-extlinux-compatible.enable = true;
    kernelParams = [
      "console=ttyS0,115200n8"
      "usbcore.autosuspend=-1"
    ];
  };

  hardware.deviceTree = {
    enable = true;
    name = "allwinner/sun50i-h616-orangepi-zero2.dtb";
  };

  sdImage = {
    compressImage = false;
    firmwareSize = 16;
    firmwarePartitionOffset = 8;
    populateFirmwareCommands = "";
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
    postBuildCommands = ''
      dd if=${pkgs.ubootOrangePiZero2}/u-boot-sunxi-with-spl.bin of=$img bs=1024 seek=8 conv=notrunc
    '';
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [ "nofail" ];
    };
  };

  zramSwap.enable = true;

  networking = {
    hostName = "orange-joystick";
    useDHCP = true;
    firewall.allowedTCPPorts = [ 22 ];
  };

  services = {
    journald.settings.Journal.Storage = "volatile";
    openssh = {
      enable = true;
      settings.PasswordAuthentication = true;
    };
    joystickd = {
      enable = true;
      package = inputs.ender3-microscope.packages.aarch64-linux.joystickd;
      configPath = ./joystick-config.json;
      # real topology via the USB hub (1-1): printer on hub port 4,
      # uno on hub port 2 — names are debug sugar; the daemon's config
      # uses empty ports + auto-detect and does not depend on these
      printerUsbPath = "1-1.4";
      unoUsbPath = "1-1.2";
    };
  };

  users.users.thibault = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "exhibit";
  };

  system.stateVersion = "25.05";
}
