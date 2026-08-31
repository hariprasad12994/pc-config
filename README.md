# pc-config

Personal dotfiles and bootstrap configuration for Manjaro/Arch and Ubuntu.
Uses [GNU Stow](https://www.gnu.org/software/stow/) to symlink configs into `$HOME`.

## Documentation

Usage docs live with the tool they describe, so they travel with the config
when it is stowed onto a machine. This README covers only repo structure,
bootstrap and stow mechanics.

| Tool | Page | What's in it |
|---|---|---|
| tmux | [`dotfiles/tmux/.config/tmux/README.md`](dotfiles/tmux/.config/tmux/README.md) | Keybindings, themes, agent alerts, workspace templates |

## Repo structure

```
pc-config/
├── install.sh          # Bootstrap script — installs packages and oh-my-zsh (one-time)
├── stow.sh             # Symlinks dotfiles into $HOME via GNU Stow (run any time)
├── windows-terminal.sh # WSL only: deploys the repo's Windows Terminal settings.json into place
├── vscode.sh           # WSL only: deploys VS Code settings.json; --export pulls it back, --extensions restores them
├── packages/
│   ├── common.txt      # Packages with identical names on Arch and Ubuntu
│   ├── arch.txt        # Arch/Manjaro-only packages
│   └── ubuntu.txt      # Ubuntu/Debian-only packages
├── dotfiles/           # Config files, one subdirectory per tool (stow packages)
│   ├── bash/           # → ~/.bashrc, ~/.profile
│   ├── git/            # → ~/.gitconfig
│   ├── zsh/            # → ~/.zshrc
│   ├── nvim/           # → ~/.config/nvim/
│   ├── vim/            # → ~/.vimrc
│   ├── tmux/           # → ~/.config/tmux/ (has its own README — keybindings, templates)
│   ├── rofi/           # → ~/.config/rofi/
│   ├── taskwarrior/    # → ~/.taskrc
│   ├── vscode/         # → VS Code settings.json + extension list (WSL only, see vscode.sh)
│   └── windows-terminal/ # → Windows Terminal settings.json (WSL only, see windows-terminal.sh)
└── scripts/            # Utilities to list installed packages/extensions (print to stdout)
```

## Bootstrap a new machine

```sh
git clone git@github.com:hariprasad12994/pc-config.git ~/code/pc-config
cd ~/code/pc-config
bash install.sh          # install packages + oh-my-zsh (one-time; GUI=1 for GUI tools)
bash stow.sh             # symlink dotfiles into $HOME (GUI=1 to include rofi)
bash windows-terminal.sh # WSL only: deploy the repo's Windows Terminal settings.json (rerun after editing it)
bash vscode.sh           # WSL only: deploy VS Code's settings.json (rerun after editing it)
bash vscode.sh --extensions # WSL only: reinstall the tracked VS Code extension set
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

## Stow reference

Use `stow.sh` for everyday operations, or the raw stow commands below for targeting individual packages. All commands run from the repo root.

| Task | Command |
|---|---|
| Stow a single package | `stow --dir=dotfiles --target=$HOME nvim` |
| Stow all CLI packages | `stow --dir=dotfiles --target=$HOME bash git zsh nvim vim tmux taskwarrior` |
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

## Listing current package state

These print to stdout — redirect them wherever you want a snapshot. Nothing is
tracked in the repo, so no dump can go stale.

```sh
scripts/user_installed_package_lister.sh   # explicitly-installed packages (pacman or apt)
scripts/snap_export.sh                     # installed snaps
scripts/vscode_extension_lister.sh         # VS Code extensions
```
