#!/bin/sh
# The whole setup, as one command they paste once:
#
#   curl -fsSL https://raw.githubusercontent.com/promptityourself/piy-genie/main/install.sh | sh
#
# WHY A SCRIPT AND NOT AN AGENT WORKING THROUGH A DOCUMENT (mate's call, 2026-08-30):
# v1 asked Claude to read SETUP.md and carry out ~30 steps by interpreting prose. Every
# documented near-miss in this repo came out of that — a block appended instead of replaced,
# two `alias ccc=` pairs with the dangerous one silently winning. A script does the same work
# the same way every time, and it frees the agent for the thing they actually came for.
#
# POSIX sh on purpose: it runs before anything is installed, including bash on a minimal image.
set -eu

REPO="https://github.com/promptityourself/piy-genie"
# Which branch to install. Defaults to main; the rehearsal sets it to test a branch for real
# rather than pre-placing the kit, which would be the test arranging its own precondition.
REF="${PIY_REF:-main}"
KIT="$HOME/projects/piy-genie"
BIN="$HOME/.local/bin"

# Prompt It Yourself red is #e2342b. Truecolor when the terminal says it can, the nearest
# xterm-256 red otherwise, and nothing at all when this is piped somewhere — the first
# thing a person sees should not be a screenful of escape codes.
if [ -t 1 ]; then
  case "${COLORTERM:-}" in
    truecolor|24bit) RED=$(printf '\033[38;2;226;52;43m') ;;
    *)               RED=$(printf '\033[38;5;203m') ;;
  esac
  B=$(printf '\033[1m'); DIM=$(printf '\033[2m'); GRN=$(printf '\033[32m'); R=$(printf '\033[0m')
else
  RED=''; B=''; DIM=''; GRN=''; R=''
fi

say()  { printf '\n%s%s%s%s\n' "$B" "$RED" "$*" "$R"; }
step() { printf '  %s%s%s\n' "$DIM" "$*" "$R"; }
have() { command -v "$1" >/dev/null 2>&1; }

# `command -v git` is TRUE on every Mac even with no developer tools, because /usr/bin/git
# is Apple's xcode-select shim — verified 2026-08-30: /usr/bin/git and /usr/bin/clang are
# the SAME INODE (1152921500312571562, 78 hardlinks) and the binary links libxcselect.
# Running it pops a GUI dialog and exits non-zero, and this script is `set -eu`, so the
# whole install would die at step 1. Ask whether git WORKS, not whether a file exists.
have_git() {
  command -v git >/dev/null 2>&1 || return 1
  if [ "$(uname -s)" = Darwin ] && ! xcode-select -p >/dev/null 2>&1; then return 1; fi
  return 0
}

case "$(uname -s)" in
  Darwin|Linux) ;;
  *) printf 'This needs macOS or Linux. On Windows, open your Ubuntu window and run it there.\n' >&2; exit 1 ;;
esac

say "1/6  Getting the kit"
mkdir -p "$HOME/projects"
# Until 2026-10-02 the kit lived at ~/projects/mwk-genie. A machine from then reaches here
# through `piy update`, which runs THIS file from the old folder: moving it is safe, because
# sh already has the script open. Only when the new name is free, and the remote is
# repointed so the next pull does not lean on GitHub's redirect from the old name.
OLD_KIT="$HOME/projects/mwk-genie"
if [ ! -e "$KIT" ] && [ -d "$OLD_KIT" ] && [ ! -L "$OLD_KIT" ]; then
  mv "$OLD_KIT" "$KIT"; step "moved ~/projects/mwk-genie to ~/projects/piy-genie"
  if [ -d "$KIT/.git" ] && have_git; then git -C "$KIT" remote set-url origin "$REPO.git" 2>/dev/null || true; fi
fi
if [ -d "$KIT/.git" ] && have_git; then
  # ⚠ THIS USED TO BE `git pull ... || true`, AND THAT IS THE BUG THIS REPO KEEPS HAVING.
  # A kit with a local edit, or a branch that has diverged, makes --ff-only fail. The
  # `|| true` swallowed it, the screen still said "updating", and step 6 then applied the
  # OLD kit — so the one command whose entire job is being up to date reported success
  # while doing nothing. Silence and success were indistinguishable. Compare the commit
  # before and after and say which of the three things actually happened.
  before=$(git -C "$KIT" rev-parse --short HEAD 2>/dev/null || echo unknown)
  if git -C "$KIT" pull --ff-only >/dev/null 2>&1; then
    after=$(git -C "$KIT" rev-parse --short HEAD 2>/dev/null || echo unknown)
    if [ "$before" = "$after" ]; then step "already here, and already up to date"
    else                              step "already here — updated $before → $after"; fi
  else
    step "already here — could not update, so keeping the copy you have ($before)"
    step "nothing is broken. If this keeps happening, ask me about it"
  fi
elif have_git && [ ! -e "$KIT" ]; then
  step "cloning"; git clone --quiet --branch "$REF" "$REPO.git" "$KIT"
else
  # This arm is also the RECOVERY path, and that is why the clone above insists the
  # directory is absent. A kit that arrived as a tarball (a Mac whose Command Line Tools
  # were not ready, the container) is a directory with no .git. Once git appeared, the old
  # `elif have_git` sent it to `git clone` into a non-empty directory: fatal, exit 128,
  # under `set -eu`, at step 1 of 6. `piy update` is `exec` of this script, so the one
  # command written for when things are broken was the one thing that could not run.
  # Untarring over the existing directory just replaces the files. Reproduced 2026-09-18.
  # A Mac with no developer tools has a /usr/bin/git that only offers to install Xcode.
  # curl is always real there, so the tarball is the kinder path. Safe to re-run.
  step "downloading (no git needed)"
  mkdir -p "$KIT"
  # refs/heads/<x> is a BRANCH path and 404s for a commit SHA — and the rehearsal is told
  # to pass a SHA, because raw.githubusercontent serves a stale branch for minutes after a
  # push. So try the branch path, then the bare one, which is what a SHA needs.
  curl -fsSL "$REPO/archive/refs/heads/$REF.tar.gz" 2>/dev/null | tar xz --strip-components=1 -C "$KIT" 2>/dev/null \
    || curl -fsSL "$REPO/archive/$REF.tar.gz" | tar xz --strip-components=1 -C "$KIT"
fi

say "2/6  Installing mise (this is the only tool that installs tools)"
# mise is PINNED, like everything it installs. Unpinned, mise.run hands out whichever release
# is a day old, and on 2026-10-02 that was 2026.9.18: it refused the sops pin in mise.lock
# ("Lockfile requires SLSA provenance … no signer_identity"), and every fresh install died
# at 3/6. Fixed upstream in 2026.10.0 (jdx/mise#13856). MISE_VERSION is mise.run's own
# variable and skips its release-age rule. Bump it on purpose, after a rehearsal.
MISE_PIN="v2026.10.0"
if have mise; then step "already installed"; else curl -fsSL https://mise.run | MISE_VERSION="$MISE_PIN" sh >/dev/null; fi
PATH="$BIN:$HOME/.local/share/mise/shims:$PATH"; export PATH

say "3/6  Installing chezmoi, sops, age, miniserve, jq and gh"
step "from $KIT/mise.toml — same versions on every machine"
( cd "$KIT" && mise install --yes >/dev/null 2>&1 ) || ( cd "$KIT" && mise install --yes )

# Make the kit's tools active EVERYWHERE, not just inside the kit directory — and do it
# BEFORE installing Claude Code. Step 2 put mise's shims first on PATH and step 3 created
# a `jq` shim for the project config; until the global versions exist, that shim errors
# "No version is set for shim: jq" — and Claude Code's installer uses jq. Measured
# 2026-09-17 in the container: with Claude Code as step 4, the installer died on that
# error every time, with its output in /dev/null, and the kit said "type claude". On a
# real machine prompt one installs Claude Code first, so the step is skipped and nobody
# saw it. Order fixes it; the honest banner at the end is what surfaced it.
#
# mise shims resolve a tool from the config in scope. mise.toml is a PROJECT config, so
# `sops` and `age` are in scope inside ~/projects/piy-genie and nowhere else — and `piy`
# is run from wherever the person happens to be standing. `mise use -g` writes the same
# pinned versions into their global config, additively, so the shims resolve anywhere.
say "4/6  Making those tools available everywhere"
step "so piy works wherever you are standing, not just inside the kit"
for t in $(grep -oE '^"aqua:[^"]+"' "$KIT/mise.toml" | tr -d '"'); do
  # The version is the quoted thing after `=`, NOT the last quoted thing on the line: a
  # trailing `# comment` after the pin made the old `$`-anchored regex return nothing for
  # three of six tools, `mise use -g tool@` then meant `@latest`, and the global config
  # said "latest" for the three tools the pin exists for. Found by an external review.
  # `|| true` so the guard below can RUN. Under `set -eu` a command substitution that
  # exits non-zero takes the whole script with it, so the "NOT making it global" message
  # was unreachable: a pin this regex could not read aborted the install at 4/6 with no
  # word of explanation, which is the opposite of what the comment promises.
  v=$(grep -E "^\"$t\"" "$KIT/mise.toml" | grep -oE '= *"[0-9][^"]*"' | grep -oE '[0-9][^"]*' || true)
  if [ -z "$v" ]; then
    printf '  could not read the pinned version of %s from mise.toml — NOT making it global\n' "$t" >&2
    continue
  fi
  mise use -g "$t@$v" >/dev/null 2>&1 || printf '  mise use -g %s@%s failed\n' "$t" "$v" >&2
done

say "5/6  Installing Claude Code"
if have claude; then step "already installed"; else curl -fsSL https://claude.ai/install.sh | bash >/dev/null 2>&1 || true; fi

say "6/6  Setting up your computer"
step "no questions, and no password"
# There is nothing left to ask, which is why this can run unattended. chezmoi's prompts
# were the only thing that needed a TTY; with none, an agent can run this script too.
# Any extra arguments still reach chezmoi, which is how the rehearsal drives it.
mise exec -C "$KIT" -- chezmoi init --apply --source "$KIT" "$@"

printf '\n  %s────────────────────────────────────────────────────────────%s\n' "$DIM" "$R"
# Say which thing actually happened. Step 4 swallows a failed Claude Code install on
# purpose (the rest of the kit is still worth having), but a green "type claude" over a
# missing claude is a beginner's first "command not found" — an external review's finding.
if [ ! -t 1 ]; then
  # Nobody is reading this at a terminal: an agent ran it through a tool, or it is going
  # to a log. The message below is written for `curl … | sh` typed by hand, and in the
  # DOCUMENTED flow that reader does not exist — Claude Code runs this mid-conversation
  # and then keeps working in the same window, fixing its own PATH, proving the install,
  # connecting accounts. Relayed verbatim, "close this window and open a new one" reads
  # as "quit me", right before the half of setup that needs the session alive. Found by a
  # beginner-angle review, 2026-09-18. `[ -t 1 ]` is the same test the colours use.
  printf '   Done. You are reading this from a tool, not a terminal, so do NOT tell them
'
  printf '   to close anything. Run  . ~/.piy-shell.sh  in this session to pick up the
'
  printf '   new tools, then carry on. A window THEY open later gets it on its own.
'
  if ! have claude; then
    printf '   Claude Code itself did not install. Retry: curl -fsSL https://claude.ai/install.sh | bash
'
  fi
elif have claude; then
  printf '   %s%sDone.%s One thing left, and it has to be you:\n\n' "$B" "$GRN" "$R"
  printf '     Close this window and open a new one.\n'
  printf '     Then type:   %s%sclaude%s\n\n' "$B" "$RED" "$R"
  printf '   %sA terminal only reads its settings when it starts, so your\n' "$DIM"
  printf '   new tools do not exist in this window yet.%s\n' "$R"
else
  printf '   %s%sNearly.%s Everything is in place except Claude Code itself,\n' "$B" "$RED" "$R"
  printf '   which did not install (no network, or an unsupported computer).\n\n'
  printf '     Run this again:   curl -fsSL https://claude.ai/install.sh | bash\n'
  printf '     Then close this window, open a new one, and type:   %s%sclaude%s\n' "$B" "$RED" "$R"
fi
printf '  %s────────────────────────────────────────────────────────────%s\n\n' "$DIM" "$R"
