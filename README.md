# pc-config

Personal dotfiles and bootstrap configuration for Manjaro/Arch and Ubuntu.
Uses [GNU Stow](https://www.gnu.org/software/stow/) to symlink configs into `$HOME`.

## Repo structure

```
pc-config/
├── install.sh          # Bootstrap script — installs packages and oh-my-zsh (one-time)
├── stow.sh             # Symlinks dotfiles into $HOME via GNU Stow (run any time)
├── windows-terminal.sh # WSL only: deploys the repo's Windows Terminal settings.json into place
├── packages/
│   ├── common.txt      # Packages with identical names on Arch and Ubuntu
│   ├── arch.txt        # Arch/Manjaro-only packages
│   └── ubuntu.txt      # Ubuntu/Debian-only packages
├── dotfiles/           # Config files, one subdirectory per tool (stow packages)
│   ├── bash/           # → ~/.bashrc, ~/.profile
│   ├── zsh/            # → ~/.zshrc
│   ├── nvim/           # → ~/.config/nvim/
│   ├── vim/            # → ~/.vimrc
│   ├── tmux/           # → ~/.config/tmux/
│   ├── rofi/           # → ~/.config/rofi/
│   ├── taskwarrior/    # → ~/.taskrc
│   ├── timewarrior/    # → ~/.timewarrior/
│   └── windows-terminal/ # → Windows Terminal settings.json (WSL only, see windows-terminal.sh)
├── scripts/            # Utilities to export currently installed packages/extensions
├── out/                # Output from export scripts
├── dwm/                # Submodule: personal dwm build (Arch/X11 only)
└── dmenu/              # Submodule: personal dmenu build (Arch/X11 only)
```

## Bootstrap a new machine

```sh
git clone --recurse-submodules git@github.com:hariprasad12994/pc-config.git ~/code/pc-config
cd ~/code/pc-config
bash install.sh          # install packages + oh-my-zsh (one-time; GUI=1 for GUI tools)
bash stow.sh             # symlink dotfiles into $HOME (GUI=1 to include rofi)
bash windows-terminal.sh # WSL only: deploy the repo's Windows Terminal settings.json (rerun after editing it)
```

After running, set zsh as default shell:

```sh
chsh -s $(which zsh)
```

Install oh-my-zsh plugins referenced in `.zshrc`:

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions \
    ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

## tmux

Prefix is **`C-p`**, not `C-b`. Everything below is `prefix` then the key,
except the `M-` pane moves, which need no prefix.

| Key | Action |
|---|---|
| `C-p` | Send a literal `C-p` through to the program in the pane |
| `\|` | Split side-by-side |
| `-` | Split stacked |
| `M-j` / `M-l` | Select pane left / right *(no prefix)* |
| `M-i` / `M-k` | Select pane up / down *(no prefix)* |
| `j` / `k` | Resize pane up / down — repeatable |
| `h` / `l` | Resize pane right / left — repeatable |
| `z` | Zoom the pane (tmux default) |
| `P` | Paste buffer |
| `r` | Reload `~/.config/tmux/tmux.conf` |
| `T` | Toggle theme — tokyonight ⇄ gruvbox, remembered across restarts |
| `a` | Jump to the agent that has been blocked longest |
| `A` | Menu of every blocked agent, with how long each has waited |
| `N` | New project window from a template |

Copy mode is vi-keyed: `v` starts a selection, `y` yanks it to the system
clipboard via `xclip`, and a mouse drag copies on release. Mouse mode is on.

### Agent alerts

When a Claude Code session needs an answer, its window is flagged in the
status bar — so an agent waiting in a window you are not looking at still
reaches you.

| Marker | Meaning |
|---|---|
| ● | Blocked on you right now — a permission prompt or a question |
| ○ | Turn finished, sitting at an empty prompt |
| `N waiting` in `status-right` | How many are blocked across every window |

A toast also fires on the window you are currently in, so you do not have to
be watching the bar. `prefix + a` walks the queue oldest-first and clears as
you answer; keep pressing until `N waiting` disappears.

The state is written by `scripts/agent-flag.sh`, driven by Claude Code hooks
configured in the [claude](https://github.com/hariprasad12994/claude) repo.
Both glyph colors come from the active theme, so `prefix + T` carries them.

### Workspace templates

`prefix + N` picks a template, then a project directory via `fzf`. From a
shell, `ws <template> [dir]` does the same, defaulting to the current
directory.

| Template | Layout | Panes |
|---|---|---|
| `agent` | side-by-side 50/50 | editor \| claude |
| `code` | stacked 70/30 | editor / shell — the build-run loop |
| `tui` | side-by-side 50/50 | editor \| shell, so a TUI gets real terminal width |
| `single` | one pane | editor |

```sh
ws agent ~/code/kohle     # editor left, agent right
ws code                   # stacked, in $PWD
ws -f agent ~/code/kohle  # force a second window for a directory already open
```

Without `-f`, asking for a directory that already has a window switches to it
instead of creating a duplicate. Windows are named after the project and keep
that name — templates turn `automatic-rename` off for themselves, so a running
`nvim` or `claude` cannot overwrite it. Windows you open by hand are
unaffected.

Programs are swappable, persistently in `tmux.conf` or per invocation:

```sh
WS_AGENT=aider ws agent ~/code/kohle
WS_EDITOR=hx   ws code  ~/code/cstdx
```

| Option | Default | Env override |
|---|---|---|
| `@ws_editor` | `nvim` | `WS_EDITOR` |
| `@ws_agent` | `claude` | `WS_AGENT` |
| `@ws_shell` | *(plain prompt)* | `WS_SHELL` |
| `@ws_root` | `$HOME/code` | `WS_ROOT` |

Panes start their program with `send-keys` rather than having it replace the
shell, so quitting `nvim` or `claude` leaves a usable prompt instead of
destroying the pane.

## Stow reference

Use `stow.sh` for everyday operations, or the raw stow commands below for targeting individual packages. All commands run from the repo root.

| Task | Command |
|---|---|
| Stow a single package | `stow --dir=dotfiles --target=$HOME nvim` |
| Stow all CLI packages | `stow --dir=dotfiles --target=$HOME bash zsh nvim vim tmux taskwarrior timewarrior` |
| Unstow a package | `stow --dir=dotfiles --target=$HOME -D nvim` |
| Restow (refresh symlinks) | `stow --dir=dotfiles --target=$HOME -R nvim` |
| Dry-run (preview changes) | `stow --dir=dotfiles --target=$HOME -n -v nvim` |

## Adding a new dotfiles package

1. Create `dotfiles/<toolname>/` mirroring the path under `$HOME`:
   ```
   dotfiles/myapp/.config/myapp/config.toml
   ```
2. Stow it:
   ```sh
   stow --dir=dotfiles --target=$HOME myapp
   ```
3. Add the package name to `CLI_PACKAGES` or `GUI_PACKAGES` in `stow.sh`.

## Exporting current package state

```sh
bash scripts/user_installed_package_lister.sh   # pacman packages → out/
bash scripts/snap_export.sh                      # snap packages → out/
bash scripts/vscode_extension_lister.sh          # VS Code extensions → out/
```
