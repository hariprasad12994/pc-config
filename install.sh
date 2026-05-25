#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$REPO_DIR/dotfiles"
PKG="$REPO_DIR/packages"

# ── 1. Detect distro ──────────────────────────────────────────────────────────

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Cannot detect distro: /etc/os-release not found." >&2
    exit 1
fi

# ── 2. Install packages ───────────────────────────────────────────────────────

case "$ID" in
    arch|manjaro)
        cat "$PKG/common.txt" "$PKG/arch.txt" \
            | grep -v '^\s*#' | grep -v '^\s*$' \
            | sudo pacman -Syu --needed -
        ;;
    ubuntu|debian)
        sudo apt-get update -qq
        cat "$PKG/common.txt" "$PKG/ubuntu.txt" \
            | grep -v '^\s*#' | grep -v '^\s*$' \
            | xargs sudo apt-get install -y

        # neovim: download latest release from GitHub (apt version is outdated)
        NVIM_URL=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest \
            | grep '"browser_download_url"' \
            | grep 'nvim-linux-x86_64\.tar\.gz"' \
            | cut -d'"' -f4)
        curl -L "$NVIM_URL" -o /tmp/nvim.tar.gz
        sudo tar -xzf /tmp/nvim.tar.gz -C /usr/local --strip-components=1
        rm /tmp/nvim.tar.gz

        # rustup: not in apt repos
        if ! command -v rustup &>/dev/null; then
            curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
        fi
        ;;
    *)
        echo "Unsupported distro: $ID" >&2
        exit 1
        ;;
esac

# ── 3. Optional GUI packages (GUI=1 to enable) ───────────────────────────────

if [ "${GUI:-0}" = "1" ]; then
    case "$ID" in
        arch|manjaro) sudo pacman -Syu --needed rofi ;;
        ubuntu|debian) sudo apt-get install -y rofi ;;
    esac
fi

# ── 4. oh-my-zsh (distro-agnostic) ───────────────────────────────────────────

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended
fi

echo ""
echo "Done. Run ./stow.sh to symlink dotfiles."
echo "Next steps:"
echo "  - chsh -s \$(which zsh)"
echo "  - Install zsh plugins manually:"
echo "      git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
echo "      git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
