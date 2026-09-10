#!/usr/bin/env bash
# Installs SauceCodePro Nerd Font - the face Windows Terminal's settings.json
# names, and the one powerlevel10k needs for its prompt glyphs. Without it the
# prompt renders as boxes and question marks.
#
# On WSL the font must go to Windows, not Linux: Windows Terminal and VS Code
# are Windows processes and never look at ~/.local/share/fonts. Installing
# per-user avoids needing admin, but then dropping the .ttf into the folder is
# not enough on its own - Windows only finds it once it is registered under
# HKCU, which is what the powershell call below does.
set -e

FONT_ZIP_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/SourceCodePro.zip"
MARKER="SauceCodeProNerdFont-Regular.ttf"

# WSL detection: /proc/version is not usable for this, because a container
# running on WSL sees the host's Microsoft kernel there and wrongly concludes it
# is WSL. wslpath and /mnt/c are the capabilities these scripts actually need.
is_wsl() { command -v wslpath >/dev/null 2>&1 && [ -d /mnt/c ]; }

fetch_fonts() {
    local dest="$1"
    command -v curl >/dev/null || { echo "curl is required." >&2; exit 1; }
    command -v unzip >/dev/null || { echo "unzip is required." >&2; exit 1; }
    echo "Downloading SauceCodePro Nerd Font"
    curl -fsSL "$FONT_ZIP_URL" -o "$dest/fonts.zip"
    unzip -qo "$dest/fonts.zip" -d "$dest" '*.ttf'
    rm -f "$dest/fonts.zip"
}

if is_wsl; then
    # glob rather than find: /mnt/c is a 9p mount where a recursive find under
    # C:\Users takes tens of seconds, against a tenth of a second for this.
    FONT_DIR=""
    for d in /mnt/c/Users/*/AppData/Local/Microsoft/Windows/Fonts; do
        [ -d "$d" ] && { FONT_DIR="$d"; break; }
    done
    if [ -z "$FONT_DIR" ]; then
        echo "Could not find the Windows per-user font directory." >&2
        exit 1
    fi

    if [ -f "$FONT_DIR/$MARKER" ]; then
        echo "SauceCodePro Nerd Font already installed in Windows."
        exit 0
    fi

    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' EXIT
    fetch_fonts "$tmp"

    for ttf in "$tmp"/*.ttf; do
        base="$(basename "$ttf")"
        cp -f "$ttf" "$FONT_DIR/$base"
        win_path="$(wslpath -w "$FONT_DIR/$base")"
        name="${base%.ttf}"
        powershell.exe -NoProfile -Command \
            "New-ItemProperty -Path 'HKCU:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts' \
             -Name '$name (TrueType)' -Value '$win_path' -PropertyType String -Force | Out-Null" \
            >/dev/null 2>&1 || echo "  warning: could not register $base" >&2
        echo "  installed $base"
    done
    echo "Done. Restart Windows Terminal to pick the font up."
else
    FONT_DIR="$HOME/.local/share/fonts/SauceCodePro"
    if [ -f "$FONT_DIR/$MARKER" ]; then
        echo "SauceCodePro Nerd Font already installed."
        exit 0
    fi
    mkdir -p "$FONT_DIR"
    fetch_fonts "$FONT_DIR"
    command -v fc-cache >/dev/null && fc-cache -f "$FONT_DIR" >/dev/null
    echo "Installed into $FONT_DIR"
fi
