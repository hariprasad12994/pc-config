#!/usr/bin/env bash
# Installs the shell dependencies .zshrc sources but no package manager
# provides: the powerlevel10k prompt, zsh-autocomplete, and uv.
#
# These used to be undocumented, so a fresh machine got a zsh that errored on
# every prompt. Idempotent - re-run it any time.
set -e

TOOLS="$HOME/tools"
mkdir -p "$TOOLS"

clone_or_update() {
    local url="$1" dest="$2"
    if [ -d "$dest/.git" ]; then
        echo "Updating $dest"
        git -C "$dest" pull --ff-only --quiet
    else
        echo "Cloning $url -> $dest"
        git clone --depth 1 "$url" "$dest"
    fi
}

clone_or_update https://github.com/romkatv/powerlevel10k.git      "$TOOLS/powerlevel10k"
clone_or_update https://github.com/marlonrichert/zsh-autocomplete.git "$TOOLS/zsh-autocomplete"

if [ ! -x "$HOME/.local/bin/uv" ]; then
    echo "Installing uv"
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "uv already installed"
fi

echo "Done. Run 'p10k configure' if you want to regenerate ~/.p10k.zsh."
