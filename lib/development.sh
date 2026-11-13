#!/usr/bin/env bash
set -euo pipefail
[[ $EUID != 0 ]] || { echo 'Runtime setup must run as the target user.' >&2; exit 1; }
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"
# Arch's nvm package supplies the upstream manager; no curl|sh installers.
set +u
# shellcheck disable=SC1091
source /usr/share/nvm/init-nvm.sh
nvm install --lts
nvm alias default 'lts/*'
nvm use default
set -u
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$HOME/.cargo/bin:$HOME/.bun/bin:$PATH"
python_version=$(pyenv install --list | sed -n 's/^ *\(3\.[0-9]*\.[0-9]*\)$/\1/p' | sort -V | tail -1)
[[ -n $python_version ]] || { echo 'No stable Python version found by pyenv.' >&2; exit 1; }
pyenv install -s "$python_version"
pyenv global "$python_version"
rustup toolchain install stable
rustup default stable
# Pi's node shebang uses the active NVM Node LTS.
bun install --global @earendil-works/pi-coding-agent
command -v node
node --version
"$HOME/.bun/bin/pi" --version
