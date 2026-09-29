#!/bin/sh
# The whole thing, on a real machine, in one command:
#
#   curl -fsSL https://raw.githubusercontent.com/promptityourself/piy-genie/<ref>/test/on-this-machine.sh \
#     | MWK_REF=<ref> sh
#
# It installs, checks, exercises, uninstalls, and reinstalls.
#
# ⚠ THIS INSTALLS ON THE MACHINE YOU RUN IT ON. That is the point: nothing here is mocked.
# It finishes by uninstalling and reinstalling, so the machine is left set up, not clean.
#
# What it CANNOT test, and says so at the end: anything needing a keyboard. `mwk add`
# refuses without a TTY by design, so the store is checked for that refusal and the real
# key path is left to a human.
set -u

REF="${MWK_REF:-main}"
KIT="$HOME/projects/mwk-genie"
RAW="https://raw.githubusercontent.com/promptityourself/piy-genie/$REF"

if [ -t 1 ]; then
  case "${COLORTERM:-}" in truecolor|24bit) RED=$(printf '\033[38;2;226;52;43m');; *) RED=$(printf '\033[38;5;203m');; esac
  B=$(printf '\033[1m'); D=$(printf '\033[2m'); G=$(printf '\033[32m'); Y=$(printf '\033[33m'); R=$(printf '\033[0m')
else RED=''; B=''; D=''; G=''; Y=''; R=''; fi

PASS=0; FAIL=0
phase(){ printf '\n%s%s── %s%s\n' "$B" "$RED" "$1" "$R"; }
ok(){ printf '  %s✓%s %s\n' "$G" "$R" "$1"; PASS=$((PASS+1)); }
bad(){ printf '  %s✗%s %s\n' "$RED" "$R" "$1"; [ $# -gt 1 ] && printf '      %s%s%s\n' "$D" "$2" "$R"; FAIL=$((FAIL+1)); }
try(){ if eval "$2" >/dev/null 2>&1; then ok "$1"; else bad "$1" "$2"; fi; }
note(){ printf '  %s%s%s\n' "$D" "$1" "$R"; }

printf '\n%s%sTesting mwk-genie on this machine%s\n' "$B" "$RED" "$R"
note "ref $REF · $(uname -s) $(uname -m) · $(date)"

phase "1 · Install"
curl -fsSL "$RAW/install.sh" | MWK_REF="$REF" sh 2>&1 | sed 's/^/  /'
[ -f "$KIT/mise.toml" ] && ok "the kit is at ~/projects/mwk-genie" || bad "the kit landed" "no mise.toml"

# Everything from here needs the PATH the install just created, which this shell does not
# have — same trap the agent hits. Source it rather than opening a new window.
[ -f "$HOME/.mwk-shell.sh" ] && . "$HOME/.mwk-shell.sh"

phase "2 · The fast checks"
if [ -f "$KIT/test/check.sh" ]; then
  ( cd "$KIT" && bash test/check.sh ) 2>&1 | sed 's/^/  /'
  note "counts above are check.sh's own"
else bad "check.sh is present" "not in the kit"; fi

phase "3 · Is it actually usable"
try "mwk runs"                      "command -v mwk"
try "sops, age, age-keygen"         "command -v sops && command -v age && command -v age-keygen"
try "jq, gh"                        "command -v jq && command -v gh"
try "claude"                        "command -v claude"
try "the rules file landed"         "test -f \$HOME/.claude/CLAUDE.md"
try "settings say opus"             "grep -q opus \$HOME/.claude/settings.json"
try "settings say auto mode"        "grep -q '\"defaultMode\": *\"auto\"' \$HOME/.claude/settings.json"
try "the status bar script runs"    "printf '{}' | sh \$HOME/.claude/statusline.sh | grep -q '% full'"
try "the howto is at ~/mwk-work/README.md" "grep -q 'How to work with your genie' \$HOME/mwk-work/README.md"
try "miniserve"                     "command -v miniserve"
# The server is started by the first interactive shell. This script is not one, so do what
# that shell does and then ask the port — the same mechanism a person meets, not a hand start.
bash -ic true >/dev/null 2>&1; sleep 2
try "their page answers on 29200"   "curl -sf -m 5 http://127.0.0.1:29200/ -o /dev/null"
try "…and it is the howto"          "curl -sf -m 5 http://127.0.0.1:29200/ | grep -q 'How to work with your genie'"
try "…and it is NOT on the network" "! curl -sf -m 4 http://\$(hostname):29200/ -o /dev/null"
try "all eight skills"              "test \$(ls -d \$HOME/.claude/skills/mwk-* | wc -l) -eq 8"
# The one thing only a real account can answer: does auto mode actually engage here?
# `claude --permission-mode auto` on an account without it is the unmeasured case.
try "claude accepts --permission-mode auto" "claude --permission-mode auto --print 'say ok' 2>&1 | grep -qi ok"
try "the starter websites"          "test -f \$KIT/site-templates/one-page/index.html"
try "nothing of ours in their home" "! test -e \$HOME/uninstall.sh && ! test -e \$HOME/mwk"

phase "4 · The store refuses what it should"
out=$(mwk add SOMETHING </dev/null 2>&1); rc=$?
[ "$rc" = 3 ] && ok "mwk add refuses with no keyboard (exit 3)" || bad "mwk add refuses without a tty" "exit $rc"
printf '%s' "$out" | grep -q 'your own terminal' && ok "and says why, in words" || bad "the refusal explains itself"
try "mwk with no args prints usage when piped" "mwk </dev/null | grep -q 'mwk add'"
try "…and it lists exactly three commands"     "test \$(mwk </dev/null | grep -c '^  mwk ') -eq 3"

phase "5 · Take it off, put it back on"
sh "$KIT/uninstall.sh" --all >/dev/null 2>&1
try "the shell file is gone"        "! test -f \$HOME/.mwk-shell.sh"
try "mwk is gone"                   "! test -x \$HOME/bin/mwk"
try "the skills are gone"           "! test -d \$HOME/.claude/skills/mwk-save"
try "the kit folder is gone"        "! test -d \$KIT"
try "the rc files are unhooked"     "! grep -q mwk-shell \$HOME/.zshrc 2>/dev/null && ! grep -q mwk-shell \$HOME/.bashrc 2>/dev/null"
curl -fsSL "$RAW/install.sh" | MWK_REF="$REF" sh >/dev/null 2>&1
[ -f "$HOME/.mwk-shell.sh" ] && . "$HOME/.mwk-shell.sh"
try "reinstall put mwk back"        "command -v mwk"
try "reinstall put the skills back" "test -f \$HOME/.claude/skills/mwk-save/SKILL.md"

printf '\n%s%s%s passed, %s failed%s\n' "$B" "$G" "$PASS" "$FAIL" "$R"
cat <<EOF

  ${Y}Not tested here, because it needs your hands:${R}
    mwk add       making the key and storing a value — it refuses without a keyboard, on purpose
    GitHub login  the device-code flow, in a real session
    the bar       open claude and look at the bottom: model · folder · % full
    auto mode     whether the first session really runs without asking — the line above only
                  proves the flag is accepted
    iTerm2        only installs on a Mac, and only if it was not there already
    the prompts   whether they read well to somebody who has never done this

EOF
