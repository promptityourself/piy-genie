#!/bin/sh
# The kit was Mate Wish Key until 2026-10-02, and everything it put on a machine was called
# `mwk`: the command, the eight skills, ~/.mwk-shell.sh, ~/mwk-work. It is Prompt It Yourself
# now, and all of it is `piy`. This takes a machine that has the old names to the new ones.
# On a fresh install there is nothing here to find, and it prints nothing.
#
# BEFORE, not after: ~/piy-work/README.md is a create_ file. If chezmoi placed it first, a
# fresh howto would sit in a new empty ~/piy-work while their pages stayed in ~/mwk-work.
# Moving the folder first means create_ finds it and leaves it alone, as it should.
#
# Not done here: the kit's own folder, ~/projects/mwk-genie. This script runs FROM it, as
# chezmoi's source, so it cannot move it; install.sh does that on the next `piy update`.
set -eu

# Their folder is MOVED, never copied and never deleted. Only when the new name is free —
# if both exist, someone made the new one by hand and it is not ours to merge.
if [ -d "$HOME/mwk-work" ] && [ ! -L "$HOME/mwk-work" ] && [ ! -e "$HOME/piy-work" ]; then
  mv "$HOME/mwk-work" "$HOME/piy-work"
  printf 'piy-genie: moved ~/mwk-work to ~/piy-work\n'
  # The server was serving the old path. Matched by port, as uninstall.sh does: the next
  # interactive shell starts it again over ~/piy-work, at the same address.
  pkill -f 'miniserve .*-p 29200' 2>/dev/null || true
fi

# The one line in their rc files that sourced the old shell file. The after-hook adds the
# new one. `cat >` rather than `mv`, so a symlinked rc stays a symlink; grep exit 1 means
# nothing was left, which is still a file to write (see uninstall.sh).
for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
  [ -f "$rc" ] && grep -q '\.mwk-shell\.sh' "$rc" 2>/dev/null || continue
  tmp="$rc.piy.$$"; rc_grep=0
  grep -v '\.mwk-shell\.sh' "$rc" > "$tmp" || rc_grep=$?
  if [ "$rc_grep" -le 1 ]; then cat "$tmp" > "$rc"; printf 'piy-genie: unhooked the old line from %s\n' "$rc"; fi
  rm -f "$tmp"
done

# Ours, by name. An explicit list rather than mwk-*: a skill of theirs that happens to
# start with mwk- is theirs.
rm -f "$HOME/bin/mwk" "$HOME/.mwk-shell.sh" "$HOME/.mwk-server.log"
for s in bug learn new onboard review save tasks wish; do
  rm -rf "$HOME/.claude/skills/mwk-$s"
done

# Two files were placed ONCE and are theirs after that, so no update ever reaches them:
# the agent's rules and the howto. Left alone they keep telling the agent to type `mwk add`
# and run `/mwk-save`, which no longer exist. Rename OUR words in them and nothing else —
# the command, the skills, the folders, the name and the site. Their own edits survive.
# sed -E with no \b, so it means the same thing on macOS and Linux. Run twice because a
# match consumes the character after it, so `mwk mwk` would otherwise keep the second.
for f in "$HOME/.claude/CLAUDE.md" "$HOME/piy-work/README.md"; do
  [ -f "$f" ] && grep -qE 'mwk|Mate Wish Key|matewishkey\.com' "$f" 2>/dev/null || continue
  tmp="$f.piy.$$"
  sed -E -e 's/Mate Wish Key/Prompt It Yourself/g' -e 's/matewishkey\.com/promptityourself.com/g' \
         -e 's/(^|[^A-Za-z0-9_])mwk([^A-Za-z0-9_]|$)/\1piy\2/g' \
         -e 's/(^|[^A-Za-z0-9_])mwk([^A-Za-z0-9_]|$)/\1piy\2/g' "$f" > "$tmp" \
    && [ -s "$tmp" ] && cat "$tmp" > "$f" && printf 'piy-genie: renamed mwk to piy in %s\n' "$f"
  rm -f "$tmp"
done
