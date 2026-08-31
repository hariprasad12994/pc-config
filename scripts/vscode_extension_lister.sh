#!/usr/bin/env bash
# Refreshes the tracked VS Code extension set from what is currently installed.
# Restore the other direction with ./vscode.sh --extensions
set -e
command -v code >/dev/null || { echo "'code' not on PATH." >&2; exit 1; }
code --list-extensions > "$(dirname "$0")/../dotfiles/vscode/extensions.txt"
echo "Updated dotfiles/vscode/extensions.txt"
