#!/usr/bin/env bash
# Walks the queue of agents blocked on input.
#
# Oldest first, not window order: window order lets an agent blocked ten minutes
# ago sit behind one blocked five seconds ago, which is the failure the whole
# notifier exists to prevent.
set -uo pipefail

# Fields are pipe-separated because pane_current_path can contain spaces.
waiting() {
    tmux list-panes -a -F '#{@agent_state}|#{@agent_since}|#{pane_id}|#{pane_current_path}' 2>/dev/null \
        | grep '^wait|' | sort -t'|' -k2,2n
}

# A pane that dies while flagged never runs its clear hook, so the stored count
# outlives the queue. Re-derive it here: this runs exactly when you reached for
# the counter, which is when a wrong one would matter.
resync_count() {
    local n="$1"
    if [ "$n" -gt 0 ]; then
        tmux set-option -g @agent_wait_count "$n"
    else
        tmux set-option -gu @agent_wait_count 2>/dev/null || :
    fi
    tmux refresh-client -S 2>/dev/null || :
}

focus() {
    local p="$1" sess
    sess="$(tmux display-message -p -t "$p" '#{session_name}' 2>/dev/null)"
    tmux switch-client -t "$sess" 2>/dev/null || :
    tmux select-window -t "$p"
    tmux select-pane -t "$p"
}

duration() {
    local s="$1"
    if   [ "$s" -ge 3600 ]; then printf '%dh%02dm' $((s / 3600)) $(((s % 3600) / 60))
    elif [ "$s" -ge 60 ];   then printf '%dm%02ds' $((s / 60)) $((s % 60))
    else                         printf '%ds' "$s"
    fi
}

jump_next() {
    local lines cur target i n
    mapfile -t lines < <(waiting)
    n=${#lines[@]}
    resync_count "$n"
    [ "$n" -gt 0 ] || { tmux display-message "no agents waiting"; return; }

    cur="$(tmux display-message -p '#{pane_id}')"
    # Strictly after the current pane, wrapping: pressing twice without
    # answering must advance rather than park on the same pane.
    target="${lines[0]}"
    for ((i = 0; i < n; i++)); do
        if [ "$(cut -d'|' -f3 <<<"${lines[i]}")" = "$cur" ]; then
            target="${lines[$(((i + 1) % n))]}"
            break
        fi
    done
    focus "$(cut -d'|' -f3 <<<"$target")"
}

menu() {
    local lines args now since pid path k label
    mapfile -t lines < <(waiting)
    resync_count "${#lines[@]}"
    [ "${#lines[@]}" -gt 0 ] || { tmux display-message "no agents waiting"; return; }

    now="$(date +%s)"
    args=()
    k=1
    for l in "${lines[@]}"; do
        IFS='|' read -r _ since pid path <<<"$l"
        label="$(basename "$path")  ($(duration $((now - since))))"
        args+=("$label" "$k" "select-window -t $pid ; select-pane -t $pid")
        k=$((k + 1))
        [ "$k" -gt 9 ] && break
    done
    tmux display-menu -T " agents waiting " "${args[@]}"
}

case "${1:-next}" in
    next) jump_next ;;
    menu) menu ;;
    *)    echo "usage: agent-jump.sh [next|menu]" >&2; exit 2 ;;
esac
