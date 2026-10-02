#!/bin/sh
# Take it all back off, so it can go straight back on.
#
#   sh ~/projects/piy-genie/uninstall.sh          ask about anything that is theirs
#   sh ~/projects/piy-genie/uninstall.sh --all    take everything, still confirming once
#   sh ~/projects/piy-genie/uninstall.sh --dry-run   say what would go, touch nothing
#
# WHY THIS EXISTS: the kit is meant to be installed on a stranger's machine, and anything
# you can put on someone's computer you should be able to take off it. It is also the only
# way to test the installer honestly — a second install onto a machine that still has the
# first one is not the thing a new person experiences.
#
# WHAT IT WILL NOT DO: silently delete anything of theirs. Their keys and their work are
# MOVED TO THE TRASH, not erased, and it says so before and after. A password store that
# vanishes on a typo would be the worst thing this kit could do.
set -eu

DRY=0; ALL=0
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --all)     ALL=1 ;;
    -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) printf 'unknown option: %s\n' "$a" >&2; exit 2 ;;
  esac
done

# ── colour ────────────────────────────────────────────────────────────────────────────
# Prompt It Yourself red is #e2342b. Truecolor where the terminal says it can, the nearest
# xterm-256 red otherwise, and nothing at all when the output is not a terminal — a log
# full of escape codes helps nobody.
if [ -t 1 ]; then
  case "${COLORTERM:-}" in
    truecolor|24bit) RED=$(printf '\033[38;2;226;52;43m') ;;
    *)               RED=$(printf '\033[38;5;203m') ;;
  esac
  B=$(printf '\033[1m'); DIM=$(printf '\033[2m'); GRN=$(printf '\033[32m'); R=$(printf '\033[0m')
else
  RED=''; B=''; DIM=''; GRN=''; R=''
fi
say()  { printf '%s\n' "$*"; }
head_() { printf '\n%s%s%s\n' "$B$RED" "$1" "$R"; }
item() { printf '  %s%s%s  %s%s%s\n' "$GRN" "$1" "$R" "$DIM" "$2" "$R"; }

# ── trash, not rm ─────────────────────────────────────────────────────────────────────
# macOS has ~/.Trash. Linux desktops use the freedesktop spec, which wants a .trashinfo
# beside the file or the desktop trash shows it as an orphan.
if [ "$(uname -s)" = Darwin ]; then TRASH="$HOME/.Trash"; INFO=""
else TRASH="$HOME/.local/share/Trash/files"; INFO="$HOME/.local/share/Trash/info"; fi

trash_it() {
  [ -e "$1" ] || return 0
  if [ "$DRY" = 1 ]; then item "would move to trash" "$1"; return 0; fi
  mkdir -p "$TRASH"; [ -n "$INFO" ] && mkdir -p "$INFO"
  base=$(basename "$1"); dest="$TRASH/$base"
  # Never clobber something already in the trash — that would destroy the very thing the
  # trash is for.
  [ -e "$dest" ] && dest="$TRASH/$base.$(date +%Y%m%d-%H%M%S)"
  if [ -n "$INFO" ]; then
    printf '[Trash Info]\nPath=%s\nDeletionDate=%s\n' "$1" "$(date +%Y-%m-%dT%H:%M:%S)" \
      > "$INFO/$(basename "$dest").trashinfo" 2>/dev/null || true
  fi
  mv "$1" "$dest"
  item "moved to trash" "$1"
}
wipe() {
  [ -e "$1" ] || return 0
  if [ "$DRY" = 1 ]; then item "would delete" "$1"; return 0; fi
  rm -rf "$1"; item "deleted" "$1"
}
ask() {
  [ "$ALL" = 1 ] && return 0
  [ -t 0 ] || return 1          # no keyboard means no consent. Keep it.
  printf '  %s%s%s [y/N] ' "$B" "$1" "$R"
  IFS= read -r a || return 1
  case "$a" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

printf '\n%s%sTaking Prompt It Yourself back off this computer%s\n' "$B" "$RED" "$R"
[ "$DRY" = 1 ] && say "${DIM}Dry run — nothing will be touched.$R"
say "${DIM}Anything of yours goes to the trash, not the bin. You can put it back.$R"

head_ "The parts that are just plumbing"
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  [ -f "$rc" ] || continue
  grep -q 'piy-shell.sh' "$rc" 2>/dev/null || continue
  if [ "$DRY" = 1 ]; then item "would unhook" "$rc"; else
    # `grep -v` exits 1 when NOTHING is left — an rc file whose only line was the hook —
    # and `&& mv` then skipped the write while the screen said "unhooked". And `mv` over
    # the rc replaced a symlinked ~/.bashrc with a regular file. Write back with `cat >`
    # (keeps the symlink and the inode), and accept exit 1 as "empty now", not failure.
    tmp="$rc.piy.$$"; rc_grep=0
    grep -v 'piy-shell.sh' "$rc" > "$tmp" || rc_grep=$?
    if [ "$rc_grep" -le 1 ]; then
      cat "$tmp" > "$rc"; rm -f "$tmp"; item "unhooked" "$rc"
    else
      rm -f "$tmp"; item "could NOT unhook — take the piy-genie line out by hand" "$rc"
    fi
  fi
done
wipe "$HOME/.piy-shell.sh"
wipe "$HOME/bin/piy"
wipe "$HOME/.claude/statusline.sh"
# ...and take the POINTER to it out of their settings, or Claude Code keeps running a
# status line command that no longer exists. Removing the file while leaving the setting
# behind was the residue an external review found on 2026-09-18: the kit is gone, and
# every session still asks for a deleted script. Only the statusLine we wrote goes; model
# and permission mode are their settings now, and the closing banner says so.
SET="$HOME/.claude/settings.json"
if [ -f "$SET" ] && grep -q 'claude/statusline.sh' "$SET" 2>/dev/null; then
  if [ "$DRY" = 1 ]; then item "would unset" "statusLine in $SET"
  elif command -v jq >/dev/null 2>&1 \
       && jq 'if (.statusLine.command // "") | test("claude/statusline.sh") then del(.statusLine) else . end' \
            "$SET" > "$SET.piy.$$" 2>/dev/null && [ -s "$SET.piy.$$" ]; then
    cat "$SET.piy.$$" > "$SET"; rm -f "$SET.piy.$$"; item "unset" "statusLine in $SET"
  else
    rm -f "$SET.piy.$$"
    item "could NOT unset — take the statusLine line out by hand" "$SET"
  fi
fi
# The server over ~/piy-work is ours to stop; the folder and everything in it is theirs.
# Matched by PORT, not by name: `pkill -x miniserve` killed every miniserve on the machine,
# including one the agent had started for them on another port minutes earlier.
pkill -f 'miniserve .*-p 29200' 2>/dev/null && item "stopped" "the page on 127.0.0.1:29200" || true
for s in "$HOME"/.claude/skills/piy-*; do [ -e "$s" ] && wipe "$s"; done
wipe "$HOME/.config/chezmoi"
wipe "$HOME/.local/share/chezmoi"

head_ "Things that might be yours"

# ~/projects/keys is THEIRS — a git repo like any other project, and it stays with the
# rest of ~/projects. The one thing that is ours to ask about is the key that opens it.
if [ -s "$HOME/.config/sops/age/keys.txt" ]; then
  printf '\n  %s%sThe key that opens ~/projects/keys%s\n' "$B" "$RED" "$R"
  say "  ${DIM}~/.config/sops/age/keys.txt — the AGE-SECRET-KEY line you saved in your password"
  say "  manager. It goes to the trash rather than being erased. Without it, or the copy in"
  say "  your password manager, nothing in ~/projects/keys can ever be read again.$R"
  if ask "Take the key off this computer?"; then trash_it "$HOME/.config/sops/age/keys.txt"
  else item "kept" "$HOME/.config/sops/age/keys.txt"; fi
fi

if [ -f "$HOME/.claude/CLAUDE.md" ]; then
  say "  ${DIM}~/.claude/CLAUDE.md is the file you were told you could edit.$R"
  if ask "Remove it?"; then trash_it "$HOME/.claude/CLAUDE.md"
  else item "kept" "$HOME/.claude/CLAUDE.md"; fi
fi

if [ -d "$HOME/Applications/iTerm.app" ]; then
  if ask "Remove iTerm2?"; then trash_it "$HOME/Applications/iTerm.app"
  else item "kept" "$HOME/Applications/iTerm.app"; fi
fi

if [ -d "$HOME/.local/share/mise" ]; then
  say "  ${DIM}mise is the tool that installed the other tools. If you had it before this"
  say "  kit, or another project uses it, keep it.$R"
  if ask "Remove mise and the tools it fetched?"; then
    wipe "$HOME/.local/share/mise"; wipe "$HOME/.local/bin/mise"; wipe "$HOME/.cache/mise"
  else item "kept" "mise"; fi
fi

head_ "The kit itself"
trash_it "$HOME/projects/piy-genie"
trash_it "$HOME/projects/mwk-genie"   # its name before 2026-10-02, if no update has moved it yet

printf '\n%s%sDone.%s\n' "$B" "$GRN" "$R"
say "${DIM}Claude Code itself was left alone — you are still signed in.$R"
say "${DIM}It still works without asking before each command, because that is a setting in$R"
say "${DIM}~/.claude/settings.json and it is yours now. Ask it to turn the asking back on.$R"
say "${DIM}Open a NEW terminal window: 'piy' should be gone from it. 'claude' is still yours.$R"
say "${DIM}Anything moved to the trash is in $TRASH$R"
printf '\n'
