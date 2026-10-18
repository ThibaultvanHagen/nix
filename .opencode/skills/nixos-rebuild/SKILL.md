---
name: nixos-rebuild
description: Update flakes and rebuild this NixOS system (hosts thibault-laptop aka astyanax, orange-joystick). Use when the user asks to update, rebuild, upgrade, or switch the system or any system package (e.g. "update signal", "rebuild", "upgrade nixpkgs", "nixos-rebuild").
---

# NixOS rebuild workflow (~/nix)

## Layout facts

- Flake at `~/nix`. Hosts: `thibault-laptop` (THIS machine, hostname on disk is `astyanax`) and `orange-joystick` (aarch64 Orange Pi, fetched input ender3-microscope provides joystickd).
- Almost everything comes from upstream flake input `hektor-nix` (github:hektor/nix); `nixpkgs`, `home-manager`, `diskko`, `stylix`, etc. all `follows` it. Updating `hektor-nix` = updating nixpkgs.
- Host configs set upstream CUSTOM options (`comms.signal.enable`, `desktop.*`, `networking.enable`, `host.role`, ...), NOT raw NixOS options, at the top level of `hosts/<name>/default.nix`.
- This machine's GNOME desktop runs via the `hosts/thibault-laptop/gnome-50-compat.nix` workaround (`desktop.gnome.enable = false`); do not switch to upstream's gnome module without testing the session.

## Update procedure

```bash
cd ~/nix
nix flake update hektor-nix        # brings new nixpkgs (e.g. new signal-desktop)
nix flake update <other-input>     # as needed
# verify BEFORE switching — no sudo needed:
nix build .#nixosConfigurations.thibault-laptop.config.system.build.toplevel
# switch (needs user's sudo password — cannot be run by the agent):
sudo nixos-rebuild switch --flake .#thibault-laptop
```

To check what version an update will bring without rebuilding:
`nix eval github:nixos/nixpkgs/<locked-rev>#<package>.version` (get the rev from `flake.lock`).

## Upstream breakage pattern (seen 2026-10 hektor-nix update)

Upstream periodically renames/moves its custom options; each rename fails the toplevel build with `The option 'X' does not exist ... Did you mean ...`. Fix iteratively: build, fix one rename, repeat. Known renames:

| old | new | where |
| --- | --- | --- |
| `firewall` | `networking.firewall` | host default.nix |
| `hardware.udev.extraRules` | `services.udev.extraRules` | host default.nix |
| `role = "..."` | `host.role = "..."` | meta.nix |
| `dotsPath` specialArg | `paths = { dots, hosts }` | flake.nix specialArgs |
| nvim input dir | `dots/.config/nvim` → `home/modules/nvim/config` | flake.nix inputs |
| `gnome-core` package | removed; use `services.desktopManager.gnome.enable` | gnome-50-compat.nix |

Diagnosis recipe for a new rename: fetch upstream source and grep its modules:

```bash
nix store prefetch-file --unpack --json \
  https://github.com/hektor/nix/archive/<rev>.tar.gz   # rev from flake.lock
# tarball lands as a directory in /nix/store — grep modules/ and hosts/ there
```

Benign deprecation warnings to ignore (upstream modules, not ours): `programs.rofi.font` renamed, `qt.platformTheme.name = "gnome"` → `adwaita`.

## Gotchas

- `ender3-microscope` input must use `git+https://` — the repo is private, so `github:` gets API 404 and `git+ssh://` fails (no SSH keys on this machine). If fetches fail again, fallback: `--override-input ender3-microscope path:/home/h/Projects/ender3-microscope`.
- `sudo` requires an interactive password: have the USER run the final `sudo nixos-rebuild switch` command.
- `result` symlink in ~/nix after `nix build` is gitignored; stale symlinks can be deleted.
- Host name mismatch is intentional: flake host `thibault-laptop`, `hostname` says `astyanax`.
