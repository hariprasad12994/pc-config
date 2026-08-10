#!/usr/bin/env bash
# Symlinks the repo-tracked Windows Terminal settings.json into place.
# WSL-only: Windows Terminal's config lives on the Windows filesystem
# outside $HOME, so it can't go through the regular stow.sh flow.
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$REPO_DIR/dotfiles/windows-terminal/settings.json"

if ! grep -qi microsoft /proc/version 2>/dev/null; then
    echo "Not running under WSL, skipping." >&2
    exit 0
fi

TARGET="$(find /mnt/c/Users -maxdepth 8 -iname settings.json \
    \( -ipath "*Packages/Microsoft.WindowsTerminal_*" -o -ipath "*Microsoft/Windows Terminal*" \) \
    2>/dev/null | head -1)"

if [ -z "$TARGET" ]; then
    echo "Could not find Windows Terminal's settings.json under /mnt/c/Users." >&2
    exit 1
fi

# Compare resolved paths, not just "-e && ! -L": a plain existence/symlink
# check can't tell "already linked to this repo" from "a real conflicting
# file", and mv-ing the former corrupts the tracked copy (see the stow.sh
# fix this mirrors).
if [ -e "$TARGET" ] && [ "$(readlink -f -- "$TARGET")" != "$(readlink -f -- "$SRC")" ]; then
    echo "Backing up $TARGET -> $TARGET.bak"
    mv "$TARGET" "$TARGET.bak"
fi

ln -sf "$SRC" "$TARGET"
echo "Linked $TARGET -> $SRC"
