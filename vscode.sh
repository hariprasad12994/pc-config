#!/usr/bin/env bash
# Deploys the repo-tracked VS Code settings.json to its real path, and
# optionally restores the tracked extension set.
#
# WSL-only, and a one-way copy rather than a symlink, for the same reason as
# windows-terminal.sh: VS Code runs as a Windows process, its config lives on
# the Windows filesystem outside $HOME, and a Windows-side symlink into
# \\wsl.localhost does not resolve. Re-run after editing the repo copy; if you
# change settings through VS Code's UI instead, run --export to pull them back.
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$REPO_DIR/dotfiles/vscode/settings.json"
EXTS="$REPO_DIR/dotfiles/vscode/extensions.txt"

mode=deploy
while [ $# -gt 0 ]; do
    case $1 in
        --export)     mode=export ;;
        --extensions) mode=extensions ;;
        *) echo "usage: vscode.sh [--export | --extensions]" >&2; exit 2 ;;
    esac
    shift
done

# WSL detection: /proc/version is not usable for this, because a container
# running on WSL sees the host's Microsoft kernel there and wrongly concludes it
# is WSL. wslpath and /mnt/c are the capabilities these scripts actually need.
is_wsl() { command -v wslpath >/dev/null 2>&1 && [ -d /mnt/c ]; }

if ! is_wsl; then
    echo "Not running under WSL, skipping." >&2
    exit 0
fi

# Installing an extension or listing them provisions the WSL server on first
# use, which is slow and noisy - so only the extension modes touch `code`.
if [ "$mode" = extensions ]; then
    command -v code >/dev/null || { echo "'code' not on PATH." >&2; exit 1; }
    while read -r ext; do
        case "$ext" in ''|\#*) continue ;; esac
        echo "Installing $ext"
        code --install-extension "$ext" --force
    done < "$EXTS"
    exit 0
fi

TARGET_DIR="$(find /mnt/c/Users -maxdepth 6 -type d -ipath '*AppData/Roaming/Code/User' 2>/dev/null | head -1)"
if [ -z "$TARGET_DIR" ]; then
    echo "Could not find VS Code's User directory under /mnt/c/Users." >&2
    exit 1
fi
TARGET="$TARGET_DIR/settings.json"

if [ "$mode" = export ]; then
    [ -f "$TARGET" ] || { echo "No settings.json at $TARGET." >&2; exit 1; }
    cp "$TARGET" "$SRC"
    chmod 644 "$SRC"
    echo "Exported $TARGET -> $SRC"
    exit 0
fi

if [ -e "$TARGET" ] && ! diff -q "$TARGET" "$SRC" >/dev/null 2>&1; then
    echo "Backing up $TARGET -> $TARGET.bak"
    cp "$TARGET" "$TARGET.bak"
fi

cp "$SRC" "$TARGET"
chmod 644 "$TARGET"
echo "Deployed $SRC -> $TARGET"
