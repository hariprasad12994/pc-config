#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# /proc/version is not usable for this: a container running on WSL sees the
# host's Microsoft kernel there and wrongly concludes it is WSL. wslpath and
# /mnt/c are the capabilities the Windows-side scripts actually need.
is_wsl() { command -v wslpath >/dev/null 2>&1 && [ -d /mnt/c ]; }

# ── 1. Distro packages ───────────────────────────────────────────────────────
#
# Ubuntu only, deliberately. The previous arch/ubuntu split cost 53 of this
# script's 90 lines and a three-file package layout, to serve nine entries -
# and it was silently wrong for years, because nothing running on Ubuntu can
# check that Arch really calls taskwarrior 'task'. When Arch comes back it
# arrives through nix, which has one name per package.

if ! command -v apt-get >/dev/null 2>&1; then
    echo "This bootstrap targets Ubuntu/Debian; apt-get not found." >&2
    exit 1
fi

sudo apt-get update -qq
grep -v '^\s*#' "$REPO_DIR/packages.txt" | grep -v '^\s*$' \
    | xargs sudo apt-get install -y

if [ "${GUI:-0}" = "1" ]; then
    sudo apt-get install -y rofi
fi

# ── 2. Tools that are not apt packages ───────────────────────────────────────
#
# Each of these is pinned to whatever is newest at install time, so two
# machines built a month apart do not match. That is the hole nix is meant to
# close later; until then they live here.

# neovim: apt's version is too old for this config
NVIM_URL=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest \
    | grep '"browser_download_url"' \
    | grep 'nvim-linux-x86_64\.tar\.gz"' \
    | cut -d'"' -f4)
curl -L "$NVIM_URL" -o /tmp/nvim.tar.gz
sudo tar -xzf /tmp/nvim.tar.gz -C /usr/local --strip-components=1
rm /tmp/nvim.tar.gz

if ! command -v rustup >/dev/null 2>&1; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended
fi

"$REPO_DIR/scripts/install_shell_tools.sh"
"$REPO_DIR/fonts.sh"

# ── 3. Link the dotfiles, and deploy the Windows-side configs on WSL ─────────

"$REPO_DIR/stow.sh"

if is_wsl; then
    "$REPO_DIR/windows-terminal.sh"
    "$REPO_DIR/vscode.sh"
fi

echo ""
echo "Done - packages installed, tools fetched, dotfiles linked."
echo "Next step:"
echo "  - chsh -s \$(which zsh)   # then log out and back in"
if is_wsl; then
    echo "  - ./vscode.sh --extensions to restore the tracked VS Code extension set"
fi
