{
  inputs,
  config,
  ...
}:
let
  meta = import ./meta.nix;
in
{
  imports = [
    inputs.disko.nixosModules.disko
    "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
    ./disk.nix
    "${inputs.hektor-nix}/modules"
  ];

  inherit (meta) host;

  hardware.facter.reportPath = ./facter.json;
  home-manager.users.${config.host.username} = import ../../home/hosts/vm;

  "ai-tools".enable = true;
  anki.enable = true;
  audio.enable = true;
  bootloader.enable = true;
  desktop.x.enable = true;
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
  taskwarrior.enable = true;

  disko = {
    devices.disk.main = {
      device = "/dev/vda";
      imageName = "nixos-vm";
      imageSize = "32G";
    };
  };

  virtualisation.vmVariantWithDisko = {
    virtualisation = {
      cores = 8;
      memorySize = 16384;
      qemu.options = [
        "-enable-kvm"
        "-cpu host"
        "-nographic"
      ];
    };
  };

  services = {
    qemuGuest.enable = true;
    spice-vdagentd.enable = true;
  };
}
