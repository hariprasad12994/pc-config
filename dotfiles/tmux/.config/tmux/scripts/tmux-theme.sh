#!/usr/bin/env bash
# Applies or toggles the tmux color theme (tokyonight / gruvbox).
# The active theme is remembered in a state file outside the dotfiles repo
# so toggling at runtime doesn't dirty the git working tree.
set -euo pipefail

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/tmux"
state_file="$state_dir/theme"
themes_dir="$HOME/.config/tmux/themes"
default_theme="tokyonight"

mkdir -p "$state_dir"

current="$(cat "$state_file" 2>/dev/null || true)"
[ -f "$themes_dir/$current.conf" ] || current="$default_theme"

action="${1:-apply}"
case "$action" in
    apply) ;;
    toggle)
        if [ "$current" = "tokyonight" ]; then
            current="gruvbox"
        else
            current="tokyonight"
        fi
        ;;
    *)
        echo "usage: tmux-theme.sh [apply|toggle]" >&2
        exit 1
        ;;
esac

echo "$current" >"$state_file"
tmux source-file "$themes_dir/$current.conf"
[ "$action" = "toggle" ] && tmux display-message "tmux theme -> $current"

exit 0
