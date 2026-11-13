# Dimarch

A personal, interactive Arch setup: i3/Xorg, Dim Sum Darker, and selected tools.
Plain Bash, official Arch packages, no compositor, no CI, no automatic updates.
MIT licensed; image/theme notices are in [assets/README.md](assets/README.md).

## Current status — read before using

**Initial implementation, not an installation-ready distribution.** Existing-Arch
configuration and local ISO tooling are implemented, but have not been run on Arch
or the target Mac. The live ISO reaches the installer; **both fresh-install and
side-by-side disk-writing branches intentionally stop without changing disks**.
They are blocked until Apple partition/boot preservation and encryption recovery
can be tested. Do not erase macOS expecting this version to finish installation.

The supported target is the 2014 Mac mini A1347 **Macmini7,1**. Other hardware
requires a typed `FORCE` acknowledgement in configure mode. This does not imply
that its drivers are supported. VM boot testing only checks the installer menu.

## Existing Arch configuration

Start with a working x86_64 Arch installation, internet, synchronized clock, and
an existing normal user with an owned, non-symlink home under `/home`:

```sh
sudo pacman -Syu --needed gum jq git
# Review the checkout before granting it root privileges.
sudo ./bin/dimarch
```

The UI selects the user and desktop/tools/dev/media/config groups (config requires desktop), prompts for
optional Git identity, previews packages/services, and asks for confirmation.
Preflight performs a **full `pacman -Syu`**; partial Arch upgrades are never used.
It validates selected packages against the configured official repositories.
No partitions, bootloader, passwords, wheel policy, root-login policy or drivers
are changed in this mode. No package is uninstalled.

Desktop enables LightDM, NetworkManager, BlueZ, timesync, fstrim and UFW for next
boot, writes zram settings, and immediately enables deny-incoming/allow-outgoing
UFW. **Existing UFW exception rules are retained**, not silently deleted. Review
`sudo ufw status verbose`. Conflicting display/network/time managers cause the
stage to stop; resolve them explicitly and rerun. Do not use over an SSH-only
connection without first reviewing the firewall implications.

Configs replace only selected managed paths, with backups under
`~/.local/state/dimarch/backups/`. Entire managed directories (e.g. `~/.config/i3`)
are backed up, not merged. Root-owned, read-only-to-users copies in `/usr/local/share/dimarch/` keep
symlinks valid after moving the checkout. Selected config deployment sets the
user's shell to Zsh. Existing Neovim configuration is **not** touched.
System config backups live under `/var/lib/dimarch/system-backup.*`.

Stages fail fast and get a success marker only after completion, keyed by user
and release-content hash in `/var/lib/dimarch`. On rerun, skip completed stages or
explicitly reapply them. A failed stage can have partially applied packages or
configs: **resuming is not rollback**. Logs are mode 600 under `/var/log/dimarch`;
there is no tracing, prompt capture, credential collection or upload. Runtime
downloads log their normal output; review logs before sharing them.

`~/dimarch-post-install.txt` lists follow-up tasks: retrieve Neovim config, install
1Password, configure SSH agent/keys, authenticate `gh` and Pi, and set up backups.
GitHub credentials and private Pi settings are never copied into this project.

## Selected setup

- Xorg + i3, LightDM GTK greeter, Ghostty, Rofi, Dunst, i3lock/xss-lock.
- One-pixel square borders, four-pixel gaps, top bar; JetBrains Mono Nerd Font.
- Bar: workspaces, focused title (polled every five seconds), network, volume, time.
- Dim Sum Darker for terminal/UI; Adwaita Dark for GTK; supplied Met wallpaper.
- PipeWire/WirePlumber, NetworkManager applet, Blueman, Pavucontrol, Proton VPN GTK app (login manually).
- GNOME Keyring (secrets only), Polkit agent; 1Password remains manual.
- Native Zsh, completion, suggestions/highlighting, fzf, zoxide; manual `zj` picker.
- Core CLI and applications are listed explicitly in `packages/`.
- Chromium only; Yazi and Thunar; Zathura/MuPDF, mpv, imv.
- Dev: Arch Bun/NVM/pyenv/rustup, Node LTS, stable Python/Rust, Pi via Bun registry.
  Downloads/builds run as the selected user **after pacman**, not through root
  curl-to-shell. Failures stop the stage; Python compilation can take a while.
  Toolchain/Pi updates are separate from `sudo pacman -Syu`.

### Keys and idle

| Binding | Action |
| --- | --- |
| Super+Enter | Ghostty (ordinary shell) |
| Super+D | Rofi |
| Super+H/J/K/L or arrows | Focus |
| Super+Shift+H/J/K/L or arrows | Move |
| Super+1…9 / Super+Shift+1…9 | Switch / move to workspace |
| **Super+Ctrl+L** | Lock (resolved with user to preserve HJKL focus) |
| Super+Shift+E | Confirmed power menu |
| Print / Shift+Print | Full / region capture, saved and copied |

Screenshots go to `~/Pictures/Screenshots`. X11 screensaver/xss-lock locks after 10 minutes, DPMS blanks
at 15, and `dimarch-idle` suspends after 30 minutes. No hibernation, autologin or onboarding wizard.

## Local validation and ISO build (no CI)

On macOS: `make lint test` (Bash, ShellCheck required; `zsh -n config/zshrc` also
checks Zsh syntax). Tests never mount, partition, format or use block devices.

ISO build/boot requires **x86_64 Arch Linux**, root for archiso, and several GiB
of free disk space. No macOS/ARM cross-build support is claimed. An x86_64 Arch
VM under QEMU/UTM on Apple Silicon is a candidate to discover, not a validated
workflow. On that Arch host:

```sh
sudo pacman -Syu --needed archiso rsync shellcheck make qemu-desktop edk2-ovmf
make lint test
make build       # sudo, retains /var/tmp/dimarch-build.* for inspection
make boot        # QEMU UEFI, NO guest/host disk attached; manually confirm menu
make check       # lint + pure tests + build + interactive boot smoke check
```

Build copies the **installed** `/usr/share/archiso/configs/releng`, adds packages
and the release checkout, and overlays root tty1 startup. Releng is not vendored.
The ISO uses NetworkManager rather than networkd/iwd and includes Broadcom `wl`
for the live kernel. Use `nmtui` from the maintenance shell to connect Wi-Fi.
Embedded scripts are used unchanged, never silently fetched from `main`.
`out/` contains the ISO and `SHA256SUMS`; build work is not automatically deleted.
QEMU smoke verification is explicitly human-confirmed, not an automated claim.

For a manual tagged release, run checks, inspect the ISO and its
`arch/pkglist.x86_64.txt` manifest, copy that manifest beside the ISO, tag the
reviewed source locally and upload ISO/checksum/manifest/release notes manually.
No scripts commit, tag or publish. Include this version's blocked-install warning.
Verify wallpaper provenance/redistribution terms before public asset/ISO release.

## Next manual checks

1. Build on a disposable x86_64 Arch VM; inspect tty1 startup, network service
   conflicts, Broadcom module availability, and the package manifest.
2. Boot the diskless QEMU smoke test. Confirm installer and maintenance exit;
   confirm live install modes stop with the precise safety message.
3. In a separate, snapshotted installed Arch VM, run existing-Arch mode. Test
   backup/symlink restoration, service-conflict refusal, interrupted-stage rerun,
   toolchain downloads and manual report. Check `i3 -C -c config/i3/config`, Rofi,
   Ghostty and Zellij config parsing on Arch before desktop login.
4. Log into LightDM/i3; check PAM keyring unlock, portals, polkit, title/volume bar,
   screenshots, clipboard, Wi-Fi, suspend/resume and lock-before-sleep.
5. On Macmini7,1 inventory `lspci -nnk`/`lsusb` and test live Wi-Fi/Ethernet,
   graphics and Bluetooth. No target-machine install is supported yet.

## Required before enabling live disk installation

See [SPEC.md](SPEC.md). In particular, implement and fixture-test GPT/APFS/Apple
recovery identification, disk model/serial/layout review and typed device+ERASE,
interactive free-extent allocation, ESP preservation plus adequately sized
XBOOTLDR, both kernel boot entries, LUKS2 passphrase/recovery verification, safe
mount/secret cleanup, region/user prompts, root lock/wheel sudo, root-only live
Wi-Fi profile transfer, and resumable disk identity checks. Validate fresh and
dual boot on disposable GPT images before adding any disk-writing commands.
No filesystem shrinking is in scope.
