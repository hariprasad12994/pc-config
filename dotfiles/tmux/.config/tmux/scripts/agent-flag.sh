#!/usr/bin/env bash
# Marks a Claude Code pane's blocking state, so an agent in a window you are not
# looking at can still reach you. Driven by hooks in ~/.claude/settings.json.
#
# The state arrives as argv instead of being read out of the hook's stdin JSON:
# the hook matcher already selects the notification type, which keeps this to a
# few milliseconds with no jq dependency. That matters because the clear path
# runs on PostToolUse, once per tool call per agent.
#
# Every exit is 0. A notifier able to fail an agent session is worse than none.

state="${1:-clear}"

[ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ] || exit 0
command -v tmux >/dev/null 2>&1 || exit 0

pane="$TMUX_PANE"
prev="$(tmux show-options -pqv -t "$pane" @agent_state 2>/dev/null)" || exit 0

# The PostToolUse clear fires constantly; leave immediately when nothing is set.
[ "$state" = clear ] && [ -z "$prev" ] && exit 0

case "$state" in
    wait)
        # Only stamp on entry, so re-notifying does not reset queue position.
        [ "$prev" = wait ] || tmux set-option -p -t "$pane" @agent_since "$(date +%s)"
        tmux set-option -p -t "$pane" @agent_state wait
        ;;
    done)
        tmux set-option -p -t "$pane" @agent_state done
        tmux set-option -pu -t "$pane" @agent_since 2>/dev/null || :
        ;;
    clear)
        tmux set-option -pu -t "$pane" @agent_state 2>/dev/null || :
        tmux set-option -pu -t "$pane" @agent_since 2>/dev/null || :
        ;;
    *)
        exit 0
        ;;
esac

# window-status-format is evaluated in window context and cannot iterate panes,
# so the worst state among a window's panes is rolled up into a window option.
#
# The rollup deliberately uses a different name from the pane option. Format
# lookups resolve pane -> window -> global, so a window @agent_state would be
# read back by every pane in that window, including this loop - the flag could
# then never clear itself.
win="$(tmux display-message -p -t "$pane" '#{window_id}' 2>/dev/null)"
rollup=""
while read -r s; do
    case "$s" in
        wait) rollup=wait; break ;;
        done) rollup=done ;;
    esac
done < <(tmux list-panes -t "$win" -F '#{@agent_state}' 2>/dev/null)

if [ -n "$rollup" ]; then
    tmux set-option -w -t "$win" @agent_win_state "$rollup"
else
    tmux set-option -wu -t "$win" @agent_win_state 2>/dev/null || :
fi

count="$(tmux list-panes -a -F '#{@agent_state}' 2>/dev/null | grep -c '^wait$')"
if [ "${count:-0}" -gt 0 ]; then
    tmux set-option -g @agent_wait_count "$count"
else
    tmux set-option -gu @agent_wait_count 2>/dev/null || :
fi

if [ "$state" = wait ]; then
    looking="$(tmux display-message -p -t "$pane" '#{&&:#{pane_active},#{window_active}}' 2>/dev/null)"
    if [ "$looking" != 1 ]; then
        project="$(basename "$(tmux display-message -p -t "$pane" '#{pane_current_path}' 2>/dev/null)")"
        if [ "${count:-0}" -gt 1 ]; then
            tmux display-message -d 3000 "$project needs you · $count waiting"
        else
            tmux display-message -d 3000 "$project needs you"
        fi
    fi
fi

# status-interval is 15s; without this the glyph lags by up to that long.
tmux refresh-client -S 2>/dev/null || :
exit 0
