#!/usr/bin/env bash
# Reports where this machine diverges from what the repo declares.
#
# Report-only: fixing is install.sh's job, knowing is this script's. Exits
# non-zero if anything failed, so it is usable as a check rather than only as
# something to read.
#
# It exists because every failure it looks for has already happened here and
# was invisible: xclip declared but never installed, so tmux copy-mode yanked
# into nothing for months; ~/.timewarrior left dangling at a deleted directory;
# .zshrc sourcing four things nothing installed.

# Windows paths are found by glob, not by find: /mnt/c is a 9p mount, and a
# recursive find under C:\Users takes 17-58 seconds there against 0.1s for a
# glob anchored to the layout Windows fixes anyway.
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
is_wsl() { command -v wslpath >/dev/null 2>&1 && [ -d /mnt/c ]; }

fails=0
section() { printf '\n\033[1m%s\033[0m\n' "$1"; }
ok()   { printf '  \033[32mok  \033[0m %-22s %s\n' "$1" "${2:-}"; }
bad()  { printf '  \033[31mFAIL\033[0m %-22s %s\n' "$1" "${2:-}"; fails=$((fails + 1)); }
warn() { printf '  \033[33mwarn\033[0m %-22s %s\n' "$1" "${2:-}"; }

# ── declared packages ────────────────────────────────────────────────────────

section "apt packages declared in packages.txt"
missing=""
count=0
while read -r p; do
    [ -n "$p" ] || continue
    count=$((count + 1))
    dpkg -s "$p" >/dev/null 2>&1 || missing="$missing $p"
done < <(grep -v '^\s*#' "$REPO_DIR/packages.txt" | grep -v '^\s*$')

if [ -z "$missing" ]; then
    ok "all $count present"
else
    bad "missing" "$(echo "$missing" | xargs)"
fi

# ── tools no package manager provides ────────────────────────────────────────

section "tools installed outside apt"
check_cmd() { if command -v "$1" >/dev/null 2>&1; then ok "$1" "$2"; else bad "$1" "$3"; fi; }
check_path() { if [ -e "$1" ]; then ok "$2"; else bad "$2" "$3"; fi; }

check_cmd nvim   "$(nvim --version 2>/dev/null | head -1 | cut -d' ' -f2)" "install.sh fetches it from GitHub"
check_cmd rustup "" "install.sh installs it via rustup.rs"
check_cmd uv     "" "scripts/install_shell_tools.sh installs it"
check_path "$HOME/tools/powerlevel10k"    powerlevel10k    "scripts/install_shell_tools.sh"
check_path "$HOME/tools/zsh-autocomplete" zsh-autocomplete "scripts/install_shell_tools.sh"
check_path "$HOME/.oh-my-zsh"             oh-my-zsh        "install.sh"

if is_wsl; then
    fdir=""
    for d in /mnt/c/Users/*/AppData/Local/Microsoft/Windows/Fonts; do
        [ -d "$d" ] && { fdir="$d"; break; }
    done
    if [ -n "$fdir" ] && [ -f "$fdir/SauceCodeProNerdFont-Regular.ttf" ]; then
        ok "nerd font" "installed in Windows"
    else
        bad "nerd font" "run ./fonts.sh - powerlevel10k renders as boxes without it"
    fi
elif [ -f "$HOME/.local/share/fonts/SauceCodePro/SauceCodeProNerdFont-Regular.ttf" ]; then
    ok "nerd font"
else
    bad "nerd font" "run ./fonts.sh"
fi

# ── what the configs assume by name ──────────────────────────────────────────
#
# These are referenced literally inside config files, so a missing one fails
# silently at the point of use rather than at startup.

section "binaries the configs invoke by name"
assumed() { if command -v "$1" >/dev/null 2>&1; then ok "$1" "$2"; else bad "$1" "$2"; fi; }
assumed xclip "tmux copy-mode yank"
assumed fzf   "prefix + N workspace picker"
assumed rg    "telescope live-grep in nvim"
assumed tig   "/review in the claude repo"
assumed stow  "stow.sh"
assumed unzip "fonts.sh unpacks the release with it"

# ── stow health ──────────────────────────────────────────────────────────────
#
# Compares resolved paths rather than testing for a symlink: stow tree-folds, so
# ~/.config/tmux is one directory symlink and the files inside it are reached
# through it without being links themselves.

section "stow links resolve into the repo"
for pkg in $(grep -m1 '^CLI_PACKAGES=' "$REPO_DIR/stow.sh" | cut -d'"' -f2); do
    pkg_dir="$REPO_DIR/dotfiles/$pkg"
    [ -d "$pkg_dir" ] || { bad "$pkg" "no such stow package"; continue; }
    bad_files=""
    while IFS= read -r src; do
        rel="${src#$pkg_dir/}"
        target="$HOME/$rel"
        if [ ! -e "$target" ]; then
            bad_files="$bad_files $rel(missing)"
        elif [ "$(readlink -f -- "$target")" != "$(readlink -f -- "$src")" ]; then
            bad_files="$bad_files $rel(not-ours)"
        fi
    done < <(find "$pkg_dir" -type f)
    if [ -z "$bad_files" ]; then ok "$pkg"; else bad "$pkg" "$(echo "$bad_files" | xargs)"; fi
done

broken="$(find "$HOME" -maxdepth 3 -xtype l 2>/dev/null | grep -v '/\.local/share/nvim/\|/tools/\|/\.cache/' | head -5)"
if [ -z "$broken" ]; then ok "no dangling links"; else bad "dangling links" "$(echo "$broken" | xargs)"; fi

# ── windows-side deploys ─────────────────────────────────────────────────────
#
# One-way copies, so they drift the moment either side is edited alone.

if is_wsl; then
    section "windows-side deploys in sync"
    wt=""
    for f in /mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminal_*/LocalState/settings.json; do
        [ -f "$f" ] && { wt="$f"; break; }
    done
    if [ -z "$wt" ]; then
        warn "windows terminal" "settings.json not found on the Windows side"
    elif diff -q "$wt" "$REPO_DIR/dotfiles/windows-terminal/settings.json" >/dev/null 2>&1; then
        ok "windows terminal"
    else
        warn "windows terminal" "differs from the repo copy - ./windows-terminal.sh to redeploy"
    fi

    vs=""
    for f in /mnt/c/Users/*/AppData/Roaming/Code/User/settings.json; do
        [ -f "$f" ] && { vs="$f"; break; }
    done
    if [ -z "$vs" ]; then
        warn "vs code" "settings.json not found on the Windows side"
    elif diff -q "$vs" "$REPO_DIR/dotfiles/vscode/settings.json" >/dev/null 2>&1; then
        ok "vs code"
    else
        warn "vs code" "differs from the repo copy - ./vscode.sh to redeploy, --export to pull back"
    fi
fi

# ── verdict ──────────────────────────────────────────────────────────────────

echo
if [ "$fails" -eq 0 ]; then
    printf '\033[32mno divergence found\033[0m\n'
else
    printf '\033[31m%d check(s) failed\033[0m - run ./install.sh, or see the notes above\n' "$fails"
fi
exit $(( fails > 0 ? 1 : 0 ))
