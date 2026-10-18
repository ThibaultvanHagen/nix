# ❄️ NixOS flake

![nix](https://img.shields.io/badge/nix-blue?logo=nixos&logoColor=%234d6fb7&labelColor=%23fff&color=%234d6fb7&link=https%3A%2F%2Fnixos.org%2F)
![neovim](https://img.shields.io/badge/neovim-flat?logo=neovim&logoColor=%23408040&labelColor=%23fff&color=%2380C040)

## hosts

### NixOS

```
nixos-rebuild switch --flake .#thibault-laptop
```

## upstream

shared modules and dotfiles come from [`hektor/nix`](https://github.com/hektor/nix) as a flake input. nixpkgs follows it. to update:

```
nix flake update hektor-nix
```

verify before switching (no sudo needed):

```
nix build .#nixosConfigurations.thibault-laptop.config.system.build.toplevel
```

upstream occasionally renames its custom options — if the build fails with
"the option X does not exist", see `.opencode/skills/nixos-rebuild/SKILL.md`
for the known renames and diagnosis steps.

## private inputs

`ender3-microscope` is a private repo and must be fetched over https
(`git+https://`, not `github:` or `git+ssh://`).
