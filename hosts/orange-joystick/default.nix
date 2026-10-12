{
  config,
  inputs,
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
    journald.storage = "volatile";
    openssh = {
      enable = true;
      settings.PasswordAuthentication = true;
    };
    joystickd = {
      enable = true;
      package = inputs.ender3-microscope.packages.aarch64-linux.joystickd;
      configPath = ./joystick-config.json;
    };
  };

  users.users.thibault = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "exhibit";
  };

  system.stateVersion = "25.05";
}
