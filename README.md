# ❄️ NixOS flake

![nix](https://img.shields.io/badge/nix-blue?logo=nixos&logoColor=%234d6fb7&labelColor=%23fff&color=%234d6fb7&link=https%3A%2F%2Fnixos.org%2F)
![neovim](https://img.shields.io/badge/neovim-flat?logo=neovim&logoColor=%23408040&labelColor=%23fff&color=%2380C040)

## hosts

### NixOS

```
nixos-rebuild switch --flake .#<hostname>
```

### virtual machines

```
nix build -L '.#nixosConfigurations.vm.config.system.build.vmWithDisko'
./result/bin/disko-vm
```

## upstream

Shared modules and dotfiles come from
[`hektor/nix`](https://github.com/hektor/nix) as a flake input. To pick up
changes:

```
nix flake lock --update-input hektor-nix
```
