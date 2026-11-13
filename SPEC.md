# Approved direction and implementation boundary

## Settled

Dimarch is an MIT personal x86_64 Arch USB installer, initially Macmini7,1.
English Gum interface, complete review before mutation, maintenance shell, fail
fast and local secret-excluding logs, content-versioned stage success markers.
Manual local builds, checks and tagged GitHub releases; **no CI**. archiso's
installed releng profile is copied at build time. The build-host workflow remains
a discovery item; an x86_64 Arch host/VM is the supported technical prerequisite.

The selected packages (including the official Proton VPN GTK app), rice and bindings are documented in README and `packages/`
with installed configs under `config/`. The final user correction is
**Super+Ctrl+L lock**, preserving complete Super+H/J/K/L focus navigation.
Wallpaper replaces the initially proposed solid background; #111111 is fallback.

## Live-install contract (blocked in this initial implementation)

Fresh: replace macOS main data/system area but preserve identifiable Apple
recovery and EFI files. Dual boot: macOS only, existing unallocated extents only,
interactive size, no APFS/NTFS/filesystem shrinking. Abort is always possible.
Unsupported hardware requires typed FORCE before any writes. Show disk
model/serial/layout and require the target device plus ERASE. Verify network,
mirrors, package availability and synchronized clock before any disk mutation.

GPT, EFI/systemd-boot, preserved small Apple ESP with sufficiently sized separate
boot/XBOOTLDR area where required; fallback EFI path, rEFInd recovery notes only.
Current + LTS kernels/headers, detected Intel/Broadcom drivers, firmware/microcode.
LUKS2 optional, ext4, zram, SSD trim, no hibernation. Generate and confirm a second
recovery key without placing secrets in logs/state/repository. Safely copy live
NetworkManager profile root-only. Prompt username, hostname, password, locale,
timezone and keymap. Wheel with password-required sudo, root login locked.
Fresh core/hardware/boot/desktop required; tools/dev/media/config optional.
Show complete plan, safely unmount and prompt reboot on success.

These flows are not approximated using unchecked partition commands. They stop
explicitly without disk writes until tested GPT/APFS/ESP/XBOOTLDR planning,
encryption/recovery and safe resume/cleanup exist. Consequently this initial ISO
cannot yet deliver the approved USB-to-installed-desktop experience.

## Existing Arch contract (implemented, Arch validation pending)

No disk/bootloader changes; select non-base modules. Add packages, never remove.
Timestamp-backup managed config paths before symlinking. Prompt optional Git
identity; no SSH key generation, no gh auth. Preserve credentials and base policy.
Report manual Neovim config/1Password/SSH/gh/Pi tasks. Runtime downloads as user.
System upgrades manual; no unattended timers. No AUR helper, containers, personal
apps, printing/scanning, backups, telemetry or other agents.
