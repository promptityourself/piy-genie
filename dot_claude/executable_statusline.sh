#!/bin/sh
# ~/.claude/statusline.sh — the bar at the bottom of Claude Code: which model, which folder,
# how full its memory is. Placed by piy-genie; edit the kit and `piy update`, not this file.
#
# WHY IT EXISTS (v1 had it, v2 lost it): the agent can only hold so much of a conversation at
# once, and when that fills up the older parts get squeezed out. Without the number, that just
# feels like it going stupid on them for no reason. With it, /clear is an obvious next move.
#
# Claude Code hands this script one JSON document on stdin per repaint. The fields used here
# are documented — model.display_name, workspace.current_dir, context_window.used_percentage —
# and used_percentage is null before the first reply, hence the `// 0`.
# jq is a mise shim, and Claude Code inherits PATH from whatever launched it — a terminal
# that read ~/.piy-shell.sh has the shims, a login shell or an app launcher does not. The
# container rehearsal hit exactly that: placed, wired, and printing nothing. Name the path.
PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin:$PATH"
command -v jq >/dev/null 2>&1 || exit 0     # still no jq → no bar, never an error in the footer
input=$(cat)
model=$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"')
dir=$(printf '%s' "$input"   | jq -r '.workspace.current_dir // ""')
pct=$(printf '%s' "$input"   | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
case "$dir" in "$HOME"*) dir="~${dir#"$HOME"}";; esac
# Prompt It Yourself red, once, and only when it is worth a /clear.
if [ "${pct:-0}" -ge 70 ] 2>/dev/null; then c=$(printf '\033[38;5;203m'); r=$(printf '\033[0m'); else c=''; r=''; fi
printf '%s · %s · %s%s%% full%s\n' "$model" "$dir" "$c" "$pct" "$r"
