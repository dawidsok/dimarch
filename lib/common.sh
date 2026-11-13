#!/usr/bin/env bash
# Pure helpers: safe to source on non-Arch hosts and in tests.
supported_hardware() { [[ $1 == Macmini7,1 ]]; }
valid_user() { [[ $1 =~ ^[a-z_][a-z0-9_-]{0,30}$ && $1 != root ]]; }
valid_hostname() { [[ ${#1} -le 63 && $1 =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]; }
valid_module() {
    case "$1" in desktop|tools|dev|media|config) return 0 ;; *) return 1 ;; esac
}
read_packages() {
    # Only static package files in the release are accepted, never shell-evaluated.
    sed 's/#.*//; /^[[:space:]]*$/d' "$1"
}
render_plan() {
    printf 'Mode: %s\nUser: %s\nHardware: %s\nModules: %s\n' "$1" "$2" "$3" "$4"
    printf '%s\n' 'Partitions/bootloader: UNCHANGED' 'Packages: additive, no removals' \
        'Config conflicts: timestamped backup before symlink' 'Authentication: no key generation or GitHub login'
}
