#!/usr/bin/env bash
set -euo pipefail
: "${ROOT:?}" "${USER_HOME:?}" "${USER_NAME:?}"
# Keep deployed configs available if the original checkout is moved or on USB.
release=$(find "$ROOT/config" "$ROOT/bin" "$ROOT/assets" -type f -exec sha256sum {} + | sort | sha256sum | cut -c1-16)
store="/usr/local/share/dimarch/$release"
install -d "$store" /usr/local/bin
cp -a "$ROOT/config" "$store/"
chown -R root:root "$store"
chmod -R a+rX,go-w "$store"
install -m 644 "$ROOT/assets/wallpaper.jpg" "$store/wallpaper.jpg"
for file in "$ROOT"/bin/dimarch-{idle,power,screenshot,status,wallpaper}; do install -m 755 "$file" /usr/local/bin/; done
ln -sfn "$store/wallpaper.jpg" /usr/local/share/dimarch/wallpaper.jpg
backup="$USER_HOME/.local/state/dimarch/backups/$(date +%Y%m%d-%H%M%S)-$$"
runuser -u "$USER_NAME" -- mkdir -p "$backup"
link_config() {
    local source=$1 target=$2
    if [[ -L $target && $(readlink "$target") == "$source" ]]; then return; fi
    if [[ -e $target || -L $target ]]; then
        local relative=${target#"$USER_HOME"/}
        runuser -u "$USER_NAME" -- mkdir -p "$backup/$(dirname "$relative")"
        runuser -u "$USER_NAME" -- mv -- "$target" "$backup/$relative"
    fi
    # Create parent dirs as the user, not root (and respect their umask).
    runuser -u "$USER_NAME" -- mkdir -p "$(dirname "$target")"
    runuser -u "$USER_NAME" -- ln -s "$source" "$target"
}
for source in "$store"/config/*; do
    name=$(basename "$source")
    if [[ $name == zshrc ]]; then target="$USER_HOME/.zshrc"; else target="$USER_HOME/.config/$name"; fi
    link_config "$source" "$target"
done
chsh -s /usr/bin/zsh "$USER_NAME"
echo "Config backup: $backup"
