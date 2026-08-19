#!/usr/bin/env bash
# Creates a project window from a template: one window in the current session,
# a fixed pane geometry, and a program started in each pane.
#
# Programs are started with send-keys rather than handed to new-window, so
# quitting nvim or claude leaves a usable shell behind instead of destroying the
# pane and half the layout with it.
set -uo pipefail

usage() {
    cat >&2 <<'EOF'
usage: tmux-workspace.sh [-f] TEMPLATE [DIR]
       tmux-workspace.sh --pick TEMPLATE

  agent   editor | claude      side-by-side 50/50
  code    editor / shell       stacked 70/30
  tui     editor | shell       side-by-side 50/50
  single  editor               one pane

DIR defaults to the current directory. -f forces a new window even when one
for DIR already exists.
EOF
    exit 2
}

opt() { tmux show-options -gqv "$1" 2>/dev/null; }

[ -n "${TMUX:-}" ] || { echo "tmux-workspace.sh: not inside tmux" >&2; exit 1; }

editor="${WS_EDITOR:-$(opt @ws_editor)}"; editor="${editor:-nvim}"
agent="${WS_AGENT:-$(opt @ws_agent)}";    agent="${agent:-claude}"
shell_cmd="${WS_SHELL:-$(opt @ws_shell)}"
root="${WS_ROOT:-$(opt @ws_root)}";       root="${root:-$HOME/code}"

force=0
if [ "${1:-}" = "-f" ]; then force=1; shift; fi

if [ "${1:-}" = "--pick" ]; then
    tmpl="${2:-}"
    [ -n "$tmpl" ] || usage
    sel="$(find "$root" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null \
           | sort | fzf --prompt="$tmpl > " --height=100% --reverse)" || exit 0
    [ -n "$sel" ] || exit 0
    exec "$0" "$tmpl" "$root/$sel"
fi

tmpl="${1:-}"
[ -n "$tmpl" ] || usage
dir="${2:-$PWD}"
dir="${dir%/}"

[ -d "$dir" ] || { echo "tmux-workspace.sh: no such directory: $dir" >&2; exit 1; }
dir="$(cd "$dir" && pwd)"

case "$tmpl" in
    agent)  split=-h; size=50%; second="$agent" ;;
    code)   split=-v; size=30%; second="$shell_cmd" ;;
    tui)    split=-h; size=50%; second="$shell_cmd" ;;
    single) split="";  size="";  second="" ;;
    *)      usage ;;
esac

if [ "$force" = 0 ]; then
    existing="$(tmux list-windows -a -F '#{window_id}|#{@ws_dir}' 2>/dev/null \
                | awk -F'|' -v d="$dir" '$2 == d { print $1; exit }')"
    if [ -n "$existing" ]; then
        tmux select-window -t "$existing"
        exit 0
    fi
fi

win="$(tmux new-window -P -F '#{window_id}' -n "$(basename "$dir")" -c "$dir")"

# Without this the project name is overwritten by whatever process starts, which
# also costs the alert menu its only way to say which project is blocked.
tmux set-option -w -t "$win" automatic-rename off
tmux set-option -w -t "$win" @ws_dir "$dir"
tmux set-option -w -t "$win" @ws_template "$tmpl"

p0="$(tmux list-panes -t "$win" -F '#{pane_id}' | head -1)"
[ -n "$editor" ] && tmux send-keys -t "$p0" "$editor" C-m

if [ -n "$split" ]; then
    p1="$(tmux split-window -P -F '#{pane_id}' "$split" -l "$size" -t "$p0" -c "$dir")"
    [ -n "$second" ] && tmux send-keys -t "$p1" "$second" C-m
    [ "$tmpl" = agent ] && tmux set-option -w -t "$win" @agent_pane "$p1"
fi

tmux select-pane -t "$p0"
