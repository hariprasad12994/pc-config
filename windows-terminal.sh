#!/usr/bin/env bash
# Deploys the repo-tracked Windows Terminal settings.json to its real path.
# WSL-only: Windows Terminal's config lives on the Windows filesystem
# outside $HOME, so it can't go through the regular stow.sh flow.
#
# This is a one-way copy, not a symlink: a Windows-side path can't be
# symlinked to a target inside the WSL-native filesystem (\\wsl.localhost) -
# the reparse point WSL creates doesn't resolve from the Windows side, even
# for unsandboxed processes, so Windows Terminal fails to load it ("file
# cannot be accessed by the system"). Re-run this script after editing the
# repo copy to deploy; if you edit settings.json via Windows Terminal's
# Settings UI instead, copy it back into the repo manually to keep it
# tracked.
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$REPO_DIR/dotfiles/windows-terminal/settings.json"

# WSL detection: /proc/version is not usable for this, because a container
# running on WSL sees the host's Microsoft kernel there and wrongly concludes it
# is WSL. wslpath and /mnt/c are the capabilities these scripts actually need.
is_wsl() { command -v wslpath >/dev/null 2>&1 && [ -d /mnt/c ]; }

if ! is_wsl; then
    echo "Not running under WSL, skipping." >&2
    exit 0
fi

# glob rather than find: a recursive find on the 9p /mnt/c mount takes tens of
# seconds, against a tenth of a second for this.
TARGET=""
for f in /mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminal_*/LocalState/settings.json; do
    [ -f "$f" ] && { TARGET="$f"; break; }
done

if [ -z "$TARGET" ]; then
    echo "Could not find Windows Terminal's settings.json under /mnt/c/Users." >&2
    exit 1
fi

if [ -e "$TARGET" ] && ! diff -q "$TARGET" "$SRC" >/dev/null 2>&1; then
    echo "Backing up $TARGET -> $TARGET.bak"
    cp "$TARGET" "$TARGET.bak"
fi

cp "$SRC" "$TARGET"
chmod 644 "$TARGET"
echo "Deployed $SRC -> $TARGET"
