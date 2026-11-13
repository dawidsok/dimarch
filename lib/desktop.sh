#!/usr/bin/env bash
set -euo pipefail
# Do not silently replace services belonging to an existing installation.
if [[ -L /etc/systemd/system/display-manager.service && $(readlink -f /etc/systemd/system/display-manager.service) != /usr/lib/systemd/system/lightdm.service ]]; then
    echo 'Another display manager is enabled. Disable it explicitly before applying desktop.' >&2; exit 1
fi
for service in systemd-networkd iwd connman chronyd ntpd; do
    if systemctl is-active --quiet "$service.service" || systemctl is-enabled --quiet "$service.service" 2>/dev/null; then
        echo "Conflicting service $service. Resolve it manually before enabling the Dimarch desktop." >&2; exit 1
    fi
done
# Existing system-file conflicts receive backups as well as home config files.
backup=$(mktemp -d /var/lib/dimarch/system-backup.XXXXXXXX)
for path in /etc/lightdm/lightdm.conf.d/50-dimarch.conf /etc/lightdm/lightdm-gtk-greeter.conf /etc/systemd/zram-generator.conf; do
    if [[ -e $path || -L $path ]]; then cp -a --parents "$path" "$backup/"; fi
done
install -d /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/50-dimarch.conf <<'CONF'
[Seat:*]
greeter-session=lightdm-gtk-greeter
user-session=i3
autologin-user=
CONF
cat > /etc/lightdm/lightdm-gtk-greeter.conf <<'CONF'
[greeter]
background=#111111
theme-name=Adwaita-dark
icon-theme-name=Adwaita
font-name=JetBrainsMono Nerd Font 11
CONF
cat > /etc/systemd/zram-generator.conf <<'CONF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
CONF
chmod 644 /etc/lightdm/lightdm.conf.d/50-dimarch.conf /etc/lightdm/lightdm-gtk-greeter.conf /etc/systemd/zram-generator.conf
# Root-owned default firewall files are backed up before UFW changes.
[[ ! -d /etc/ufw ]] || cp -a /etc/ufw "$backup/"
ufw default deny incoming
ufw default allow outgoing
ufw --force enable
systemctl enable NetworkManager.service bluetooth.service lightdm.service systemd-timesyncd.service fstrim.timer ufw.service
# Enable only: don't interrupt the existing network/session. A reboot applies services/zram.
echo "System backups: $backup. Desktop services enabled for next boot. Existing UFW rules were retained; review with ufw status."
