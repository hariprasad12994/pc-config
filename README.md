# pc-config

Personal dotfiles and bootstrap configuration for Manjaro/Arch and Ubuntu.
Uses [GNU Stow](https://www.gnu.org/software/stow/) to symlink configs into `$HOME`.

## Repo structure

```
pc-config/
├── install.sh          # Bootstrap script — installs packages and oh-my-zsh (one-time)
├── stow.sh             # Symlinks dotfiles into $HOME via GNU Stow (run any time)
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
│   └── timewarrior/    # → ~/.timewarrior/
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
