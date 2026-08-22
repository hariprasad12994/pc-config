# tmux

Prefix is **`C-p`**, not `C-b`. Everything below is `prefix` then the key,
except the `M-` pane moves, which need no prefix.

## Keybindings

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

The resize keys do not follow vim's directions: `j`/`k` are up/down, `h`/`l`
are right/left.

Copy mode is vi-keyed: `v` starts a selection, `y` yanks it to the system
clipboard via `xclip`, and a mouse drag copies on release. Mouse mode is on.

## Themes

`tokyonight` (default) and `gruvbox`, matching the nvim colorschemes. `prefix +
T` toggles and remembers the choice in
`${XDG_STATE_HOME:-~/.local/state}/tmux/theme` — outside the repo, so toggling
at runtime never dirties the working tree.

Each theme file also defines `@color_urgent` and `@color_ok`, which the agent
alert glyphs below read, so the alerts follow whichever theme is active.

## Agent alerts

When a Claude Code session needs an answer, its window is flagged in the status
bar — so an agent waiting in a window you are not looking at still reaches you.

| Marker | Meaning |
|---|---|
| ● | Blocked on you right now — a permission prompt or a question |
| ○ | Turn finished, sitting at an empty prompt |
| `N waiting` in `status-right` | How many are blocked across every window |

A toast also fires on the window you are currently in, so you do not have to be
watching the bar. It is suppressed when the blocked pane is the one you are
already looking at.

`prefix + a` walks the queue **oldest-first** and each entry clears as you
answer it; keep pressing until `N waiting` disappears. `prefix + A` opens a
chooser instead, listing each blocked project with how long it has waited —
better than cycling blind once three or four are queued.

### How it works

`scripts/agent-flag.sh` writes the state, driven by Claude Code hooks
configured in the [claude](https://github.com/hariprasad12994/claude) repo —
see `docs/agents-in-tmux.md` there for the hook wiring and the design
reasoning. The script stores state in tmux options: `@agent_state` per pane,
`@agent_win_state` rolled up per window for the status bar, and
`@agent_wait_count` globally for the counter.

`scripts/agent-jump.sh` reads them back for `prefix + a` and `prefix + A`.

Nothing here depends on tmux being present: run `claude` outside tmux and the
hooks exit silently.

## Workspace templates

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
instead of creating a duplicate.

Windows are named after the project and **keep** that name: templates turn
`automatic-rename` off for themselves, so a running `nvim` or `claude` cannot
overwrite it. Windows you open by hand are unaffected and still auto-rename.

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

## Files

```
~/.config/tmux/
├── tmux.conf              prefix, splits, pane nav, status formats, keybinds
├── themes/
│   ├── tokyonight.conf    default
│   └── gruvbox.conf
└── scripts/
    ├── tmux-theme.sh      apply / toggle, persists the choice
    ├── agent-flag.sh      hook-driven; writes agent state into tmux options
    ├── agent-jump.sh      walks the blocked-agent queue
    └── tmux-workspace.sh  creates a project window from a template
```
