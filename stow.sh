#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$REPO_DIR/dotfiles"

CLI_PACKAGES="bash zsh nvim vim tmux taskwarrior timewarrior"
GUI_PACKAGES="rofi"

STOW_PACKAGES="$CLI_PACKAGES"
[ "${GUI:-0}" = "1" ] && STOW_PACKAGES="$STOW_PACKAGES $GUI_PACKAGES"

for pkg in $STOW_PACKAGES; do
    pkg_dir="$DOTFILES_DIR/$pkg"
    [ -d "$pkg_dir" ] || continue

    # Back up any real files that would conflict with stow targets
    while IFS= read -r -d '' src; do
        rel="${src#$pkg_dir/}"
        target="$HOME/$rel"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            echo "Backing up $target -> $target.bak"
            mv "$target" "$target.bak"
        fi
    done < <(find "$pkg_dir" -type f -print0)

    stow --dir="$DOTFILES_DIR" --target="$HOME" "$pkg"
done

echo "Done."
