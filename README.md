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
└── scripts/            # install_shell_tools.sh, plus utilities that list installed
                        #   packages/extensions to stdout
```

## Bootstrap a new machine

```sh
git clone git@github.com:hariprasad12994/pc-config.git ~/code/pc-config
cd ~/code/pc-config
./install.sh             # GUI=1 to also install GUI packages
```

`install.sh` now runs the whole bootstrap: distro packages, oh-my-zsh, the
shell tools `.zshrc` needs, `stow.sh`, and — on WSL — the two Windows-side
deploy scripts. Re-run the individual pieces any time:

```sh
./stow.sh                   # re-link dotfiles (GUI=1 to include rofi)
./windows-terminal.sh       # WSL: redeploy Windows Terminal settings.json
./vscode.sh                 # WSL: redeploy VS Code settings.json
./vscode.sh --extensions    # WSL: reinstall the tracked extension set
scripts/install_shell_tools.sh   # powerlevel10k, zsh-autocomplete, uv
```

The one manual step left is making zsh the login shell:

```sh
chsh -s $(which zsh)
```

`.zshrc`'s dependencies are handled for you: `zsh-syntax-highlighting` comes
from the distro package, and `scripts/install_shell_tools.sh` fetches
powerlevel10k, zsh-autocomplete and uv into `~/tools`. Each is sourced only if
present, so a partially-installed machine still gets a usable shell.

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
```

The VS Code one is different: it refreshes tracked config rather than printing
a snapshot, and `vscode.sh --extensions` restores from it.

```sh
scripts/vscode_extension_lister.sh         # → dotfiles/vscode/extensions.txt
```
