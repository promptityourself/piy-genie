# piy-genie — agent notes

The starter kit for **[Prompt It Yourself](https://promptityourself.com)**: an AI agent running on somebody's
own computer, set up for a person who has never opened a terminal. One question, two things to
paste, and no password. `README.md` is the front door for a human; this file is the stuff that will
bite you.

**THERE ARE TWO `CLAUDE.md` FILES HERE AND THEY HAVE NOTHING TO DO WITH EACH OTHER.** This one is
notes for whoever works ON the kit. `dot_claude/create_CLAUDE.md` is a **product artefact** — chezmoi
places it at a stranger's `~/.claude/CLAUDE.md` and it becomes the rules their agent lives by.
Editing the wrong one is silent: nothing fails, and either the kit stops working or a beginner gets
instructions meant for you.

## How v3 works, in one pass

```
prompt one  (browser)  → Mac or Windows? → WSL → Claude Code → start it with
                         --permission-mode auto
prompt two  (Claude)   → read install.sh and report → run it → prove it → Xcode CLT (Mac)
                         → accounts → a folder to work in
install.sh             → kit → mise → 6 pinned tools → Claude Code → mise use -g → chezmoi apply
chezmoi                → ~/.piy-shell.sh, ~/bin/piy, ~/piy-work/README.md,
                         ~/.claude/{CLAUDE.md,settings.json,statusline.sh,skills/},
                         and on macOS iTerm2
piy                    → add · run · update. That is all of it.
```

**It is not a plugin.** Skills are placed straight at `~/.claude/skills/piy-*/SKILL.md`, which
loads with no marketplace and no manifest. The prefix is in the directory name because user-level
skills share one flat namespace.

## The rule that shapes v3 (mate, 2026-09-17)

**A command exists only if it is needed OFTEN. Everything infrequent, the agent does.** It is on the
machine, it can see the actual state, and it will handle a one-off better than a function written
months earlier for a machine nobody had seen. So there is no `init`, `list`, `needs`, `lock`,
`rekey`, `uninstall`, `restore`, no menu, no page. `create_CLAUDE.md` carries each of those as one
sentence under *Things that need no command*. **Don't add a command for something rare.** It rots.

**The floor stays a script.** `install.sh` runs before the agent is useful, is read before it runs,
and is tested in a container. OpenClaw's own install is `curl … | bash` and their docs say a skill
"cannot install or update the runtime itself" — checked 2026-09-17, not assumed. v1 was an agent
following prose for ~30 steps, and every documented near-miss came out of that.

**Fix the silent bugs; let the agent handle the loud ones.** It routes around a missing tool or a
404. It does not route around `Stored ✓` printed over a store that just lost two keys.

`docs/v3-plan.md` is the record of why, with the research table and the four decisions.

## The one question, and the two that were deleted

`.chezmoi.toml.tmpl` prompts for **nothing**. The single question — Mac or Windows — lives in
`prompts/install.md`, because Windows needs WSL before a terminal exists and nothing later can ask.

**Removing the prompts removed a TTY requirement**: chezmoi needed a terminal only because it was
asking; with nothing to ask, an agent can run `install.sh`, and the 87-character one-liner never
has to appear inside a prompt file.

- **Model** — deleted. Opus, settled 2026-08-11. Written by `dot_claude/modify_settings.json`;
  removing the question once removed the setting with it — Claude Code's own default is not opus.
- **Admin** — deleted, not answered. iTerm2 goes to `~/Applications`, which needs no password, so
  nothing in the flow uses `sudo` at all.
- **`ccc_mode`** — gone with `ccc` itself, 2026-09-17 (v3.1 below). How Claude asks is
  `permissions.defaultMode` in their `settings.json`, written as `auto` by
  `dot_claude/modify_settings.json` **only when absent** — that is the escape hatch now: a value
  they change stays changed. `.chezmoidata.yaml` holds only `iterm_dest`.

## The read-before-you-run guardrail

`prompts/setup.md` makes the agent read `install.sh` and answer four questions out loud: sudo,
writes outside `$HOME`, unexpected download hosts, deletions. A stranger cannot read it themselves,
and "trust us" is not an answer.

**The checklist must stay true of the script.** It once listed three hosts while `install.sh`
fetched from four, so the guardrail would have fired on its own installer. **A guardrail that cries
wolf the first time is ignored the second.** `check.sh` now extracts every host `install.sh` fetches
from and asserts `setup.md` names each one.

## Things measured on real machines, so nobody re-derives them

| Fact | Consequence |
|---|---|
| `/usr/bin/git` and `/usr/bin/clang` share an inode on macOS — it is the xcode-select shim | `command -v git` is true with no dev tools. Ask `xcode-select -p`, not whether a file exists |
| macOS has **no `timeout`** and no `gtimeout` | Calling it exits 127. Nothing in v3 calls it; if something ever does, this is why it dies on a Mac |
| A stock Mac has **no pinentry and no gpg-agent** | Irrelevant since 2026-09-17 — the passphrase is gone. Kept because it is why the passphrase is gone: it made `piy lock` mean two different things on two platforms |
| Binaries fetched by curl/Go carry `com.apple.provenance`, not `com.apple.quarantine` | Gatekeeper does not block the toolchain. **Never add a blanket `xattr -dr`** to "fix" it |
| chezmoi, sops and age were checked ad-hoc signed arm64; jq and gh were pinned later and not re-checked | They exec on Apple Silicon. `spctl -a` says "rejected" for ad-hoc binaries — that is the assessment API, not exec enforcement |
| `mise` shims resolve from the config **in scope** | `mise.toml` is a project config, so tools were active only inside the kit. `mise use -g` fixes it |
| A plain chezmoi-managed `settings.json` | With no TTY it **aborts the whole apply**; with `--force` it reverts the file and destroys `enabledPlugins`. Use `modify_`; `.chezmoi.stdin` does not exist, so it must be a script. **Measured to preserve `enabledPlugins`, 2026-09-13** — it was an assumption until the fixture was proved planted |
| `.chezmoiignore` patterns match the **target** name | `dot_claude/**` matches nothing — the target is `.claude/**`. Writing the source name places NOTHING while reading correctly |
| **mise was the one unpinned tool, and mise.run hands out the newest DAY-OLD release** | On 2026-10-02 that was 2026.9.18, which refuses the sops SLSA provenance in `mise.lock` (no signer in the aqua registry): every fresh install died at 3/6. Fixed upstream in 2026.10.0 (jdx/mise#13856). `install.sh` pins `MISE_PIN`, passed as `MISE_VERSION` (mise.run's own variable, which also skips the age rule). Bump it on purpose, after a rehearsal |
| **`chezmoi init` writes the DEFAULT config, `~/.config/chezmoi/chezmoi.toml`** | Measured 2026-10-03 in a scratch home: anybody already using chezmoi had their settings replaced by the kit's, silently, and `uninstall.sh` then `rm -rf`'d `~/.local/share/chezmoi` — their dotfiles, a folder the kit never made — not even to the trash. Found while preparing the first real-Mac run: every fleet Mac uses chezmoi. The kit now runs chezmoi with `--config ~/.config/piy/chezmoi.toml` (the state file follows the config), uninstall removes `~/.config/piy`, and a `~/.config/chezmoi` only when its `sourceDir` is the kit. Rehearsed with a third user who has their own chezmoi |
| **In `.chezmoiignore`, `*` matches TOP-LEVEL names only, and a `!` beats an ignore** | Measured with `chezmoi managed`, 2026-10-02. So the "ignore everything" allow-list never covered anything nested (`bin/mwk`, `.claude/skills/x`), and a `!.claude/**` un-ignored the old `mwk-*` skills over an explicit ignore line. It is gone; the old names are ignored by name. `check.sh` plants stale sources in a copy and asks what chezmoi would place |
| `A && B \|\| C && D` groups as `((A && B) \|\| C) && D` | A successful first branch still ran the second. Use `if/elif` |
| `[ -t 1 ]` is false inside **every** pipeline and every `$()` | It asks about the current redirection, not whether a person is there. `have_tty` asks whether `/dev/tty` **opens** |
| `exit` from a pipeline stage leaves the **subshell**, not the script | A function that reads must `return` non-zero and let the main shell decide. This is how `piy add` once replaced the store with one key |
| **`grep -c` exits 1 when the count is zero** | `n=$(grep -c x f \|\| echo 0)` yields the two-line string `0\n0`. Use `\|\| true` and default only the empty case |
| `ubuntu:24.04` ships **no python3** | A `python3 … \|\| true` fixture plants nothing and the check never runs. **Assert the fixture landed before asserting what survives it** |
| `env -i … <shell function>` is "No such file", silently | `env` execs binaries. The store test's first run reported "no store was made" against a store that was. Put the pty inside the env, not a function around it |
| **sops searches for `.sops.yaml` upward from the CURRENT DIRECTORY** | `piy add` runs from inside a project, not the store. Pass `--config` explicitly |
| **sops matches creation rules on the file NAME, and stdin has none** | `--filename-override <name>`, or a no-catch-all `.sops.yaml` refuses with `no matching creation rules found` — which is that rule doing its job on the wrong file |
| **A login shell has `~/bin` but not mise's shims.** Ubuntu's `.profile:20-21` adds `~/bin`; `.bashrc:6-8` returns before the kit's source line whenever the shell is non-interactive (`su - user -c`, cron, a script) | Measured in `ubuntu:24.04`, 2026-09-17. So `piy` is found and `sops` is not. A tool preflight at the top of `piy` made bare usage exit 1 and would have killed `piy update` — the command for when things are broken. Tools are checked inside `add` and `run` only. **Same class, second time:** `statusline.sh` was placed, wired, and printed nothing under a login shell — `jq` is a shim too, and Claude Code inherits PATH from whatever launched it. The script names the shim path itself now |
| **mise trusts `mise.toml` by content hash — editing it untrusts the directory** | Every shim run from that directory then exits 1 with a mise error, while `command -v` stays true. Found 2026-09-17 when the store test went red on both the new and the previous `piy` after miniserve was added back; `mise trust` fixed it. `install.sh` runs `mise install --yes` in the kit dir, and `rehearse.sh` now asserts each tool **runs** from there, not that its shim exists |
| **A mise shim with no global version exits 1 — and Claude Code's installer uses `jq`** | `install.sh` had Claude Code at step 4, after the shims went first on PATH (step 2) and a project `jq` shim existed (step 3), but before `mise use -g` (step 5). The installer died on `No version is set for shim: jq`, into `/dev/null`, and the banner said "type claude". Never seen on a real machine because prompt one installs Claude first. Reordered; the container asserts `~/.local/bin/claude` exists now |
| **The container script in `rehearse.sh` is ONE double-quoted string** | A bare `"` on a comment line inside it ENDS the script; the rest becomes arguments to `docker`, the truncated script runs to its end, exit 0. Measured: two assertions, no verdict, `EXIT=0`, `bash -n` green. The script ends with `REHEARSAL-COMPLETE` and the outer script demands it; `check.sh` refuses a bare quote on a comment line in there |
| This box's fleet shell exports `SOPS_AGE_KEY_FILE` | It contaminated the first round of store research with an unexplained recipient mismatch. `piy` sets it explicitly; `check.sh` runs the store under `env -i`. **Do store research in a clean env** |
| **The WSL image is NOT the container image.** Canonical's own manifest for the image `wsl --install` gives you (`cloud-images.ubuntu.com/wsl/noble/current/*.manifest`, 529 packages) lists `curl`, `git`, `python3`, `wget`, `ca-certificates`, `tar` and `sudo`. `ubuntu:24.04` in Docker has **none** of the first five | Measured 2026-09-18. So the rehearsal runs in a HARSHER world than any real machine, which is what makes it a good test bed and a bad model. Do not reason from the container to WSL: a 2026-09-18 review called the WSL kit-fetch unsafe because "WSL has no git", which the manifest disproves |
| **git REFUSES to commit with no `user.email`**, and cannot invent one when the hostname has no domain (`cicmorgi@dev-cicmorgi.(none)`) | Reproduced under `env -i` 2026-09-18: `piy add` printed a green `Stored` over a store with zero commits, because the refusal went to `/dev/null` behind `\|\| true`. A store repo now gets a LOCAL identity; `/piy-onboard` sets their real one from `gh api user` |
| **`claude plugin install <x>@<marketplace>` fails on a machine that has never had a plugin** — no marketplace is registered, and the error names the marketplace as if it were stale | Reproduced on a clean `$HOME` 2026-09-18, both directions: `claude plugin marketplace add anthropics/claude-code` first, then the identical install succeeds. Never visible on a dev box, which already has one |
| `api.github.com` sends `access-control-allow-origin: *`, but a **private** repo 404s unauthenticated | Measured with a positive control (`td-sops` private → 404, `piy-genie` public → 200). It decided that no page would ever read their issues — and then the page went anyway |

## The store — `~/projects/keys`

A private git repo of sops-encrypted dotenv files, and **one plain age key at sops's default path,
`~/.config/sops/age/keys.txt`**, mode 600. The thing they save in their password manager, once, is
that key's `AGE-SECRET-KEY` line.

```
~/projects/keys/.sops.yaml          their PUBLIC key, one rule, no catch-all. Safe to commit
~/projects/keys/keys.enc.env        every key. ONE file, no per-project scope (mate, 2026-09-17:
                                    "one global password manager, do not overcomplicate it")
~/.config/sops/age/keys.txt         the PRIVATE key. Never in git, never in ~/projects, never in chat
```

Measured 2026-09-17 under `env -i`, sops 3.13.3 / age 1.1.1 — the table is in `docs/v3-plan.md`:
sops finds the default key path unaided; a hidden key fails instantly (exit 128 — the hang was
pinentry, and pinentry is gone); `sops updatekeys -y` after a new key locks the old one out; `git
add -A` stages zero secret lines.

**What replaced what.** `~/.piy` with a passphrase-encrypted identity was chosen so the saved
thing was "a password"; it cost pinentry, gpg-agent, the 600s cache, three TTY refusals, `lock`,
`rekey`, and a per-platform fork — and it had **no backup**. A 74-character string is what
password managers are for, and a repo is what backups are for.

**Three things are load-bearing in `bin/executable_piy`, and `check.sh` asserts each:**

- **`add` refuses without a TTY**, using the property that was measured (`/dev/tty` opens), and has
  **no `--value` flag** — that removes argv, `ps` and shell history as a class.
- **A store with no key is a NEW COMPUTER, not a first run.** `ensure_store` refuses to mint a key
  when `.sops.yaml` exists; a fresh key there would encrypt the next add to a key that cannot read
  the rest of the repo, and it would look like it worked. It says where the saved key goes.
- **`add` reads before it prompts, dies on a failed read, keeps the old ciphertext until the new one
  is proved, and reads the store back to confirm every previous name survived.** That is the
  2026-08-30 bug's fix, carried over. `check.sh` runs it against a real scratch store through a
  pty, and was confirmed red with the merge sabotaged before being trusted green.

**Each `add` commits, and pushes if the store has a remote** — and says which of those
actually happened, in the line after `Stored`. `/piy-onboard` is what creates the remote
(`gh repo create keys --private --source … --push`), because that needs GitHub and a
commit needs nothing. Before 2026-09-18 none of this was true: nothing anywhere created a
remote or pushed, while `README.md`, `HOW-TO.md` and `create_CLAUDE.md` all promised a
backup and a one-clone restore. The learning log had the whole lifecycle and the key store
had none of it, which is the tell — the same grep finds one and not the other.

## The failure this repo keeps having

**A string replace that does not match is silent, and it looks exactly like one that worked.**
v1's green ticks counted nothing; an ignore file placed nothing while reading correctly; a menu
renumbering left two number 3s; `piy add` replaced the store with one key while printing `Stored`;
a test fixture that never ran reported a verdict anyway; a `pty` function behind `env -i` never
executed and the suite said the store was never made.

Every one was written confidently and reviewed as correct. The defence is not more care, it is
asserting the result: after an edit, read back the thing that should have changed, and **when a
check goes green, break the thing and watch it go red first.** `check.sh` asserts the placed-file
list by name in both directions, the promised skill names against the shipped ones in both
directions, the dispatcher's arms against the usage text, and every cut command against every
document that ships.

## The cross-repo coupling — the website, and what it actually reads from here

**The live page is `promptityourself.com/topics/put-the-genie-in-the-box/`** (source
`src/content/topics/put-the-genie-in-the-box.mdx` in `mergodon/promptityourself-web`, which was `matewishkey-web`); `/wishes/…`,
`/how-to/…` and `/projects/…` all 301 to it. It has moved three times; curl it, don't quote it.

**The coupling is LIVE again — their `108b448`, matewishkey-web#82, and it makes three of our
files load-bearing in somebody else's build.** At build time they fetch `HOW-TO.md`,
`prompts/install.md` and `prompts/setup.md` from `main`: `HOW-TO.md` is the page body with its
H1 dropped, and the first fenced block of each prompt fills the matching slot. **A 404 on any of
the three FAILS their build** (the disk cache opens only for a network error, a 429 or a 5xx),
and `GenieHowTo.astro` fails it too if both slot comments are not present. So renaming or
deleting a prompt file, `HOW-TO.md`, or either
`<!-- PROMPT ONE goes here -->` / `<!-- PROMPT TWO goes here -->` marker **breaks a third
party's deploy, and our own `check.sh` stays green while it does.** Never do it in a cleanup.

**Verified against the served HTML, 2026-09-19** — not read, and not taken from their issue
comment: both `<pre>` blocks are byte-for-byte the first fence of `install.md` (5588 chars) and
`setup.md` (7346 chars) on `main`; all 52 prose fragments of `HOW-TO.md` appear in the page
(0 missing, once smart quotes and em dashes are normalised — the raw compare showed 9 false
misses on `'` vs `’` alone); the slot comments are dropped in their render, but the two
GitHub fallback lines are NOT (this said they were until 2026-10-03; since 2026-10-06 they read
`The same prompt on GitHub: prompts/….md`, which is true in both places;
`GenieHowTo.astro` only splits on the slots, and both lines show on the live page under each
copy block); relative links are repointed at `blob/main`. **They do
NOT rebuild on our commits** — their deploy is a manual `wrangler deploy` from `.11`. The paragraph
from `88be94a` was live the next day because somebody deployed, and this line used to read that as a
trigger. Measured 2026-10-03: the `mwk` → `piy` rename sat unpublished, so a change that a reader
must see needs an issue asking for a deploy (promptityourself-web#102 was the first).
The v1 prose is gone — the only "Homebrew" left is the kit's own *"Do not install Homebrew"*
inside prompt one. `assertNarrow` and their `scripts/check-prompts.mjs` are gone with #77.

**Two things from the old coupling still bite:** it reads the **first** fenced block, so a second
fence above it publishes the wrong thing; and any width cap has to stay gone, because both
prompts are prose now (longest lines 505 and 631). **One thing is theirs, not ours:** the page's
JSON-LD `dateModified` is hand-written frontmatter and understates the body it renders
(`2026-09-17` against a 2026-09-18 commit), so it drifts every time this kit changes.

## Rules that survived and still apply

**Verify identifiers.** Every URL here is handed to a stranger whose agent acts on it. `check.sh`
extracts URLs from the files that ship and curls them; it does not read a hand-kept list.

**A test that arranges its own preconditions is worse than no test.** When a check goes green, ask
what would have to be true for it to go red.

**Existing is not running.** `test -x ~/bin/piy` passed for a day while `~/bin` was on nobody's
PATH and the first command a person is told to type did not exist.

**The show is mentioned twice, and no more** — `README.md:7` and the howto (`piy-work/create_README.md`); `check.sh` counts exactly two.
Unresolved, and mate's to decide (#14).

**No disclaimer link.** Settled 2026-08-09 and still settled.

**One kit, not one per platform** (mate, 2026-09-13, after measuring). WSL Ubuntu *is* Linux —
`uname -s` says `Linux` — and the whole kit branches on OS in three places: the xcode-select shim
check and the Darwin|Linux gate in `install.sh`, and `run_onchange_after_20-darwin-iterm2.sh.tmpl`.
Forking would duplicate ~1000 lines to manage three conditionals. The two platform differences that
were real — the passphrase cache and the served page — are both gone with v3.

## Test it before you push

```
bash test/check.sh                    # seconds, no Docker. Runs piy add against a real scratch store
bash test/rehearse.sh <sha>           # minutes, Docker, install → update → uninstall → reinstall
curl … test/on-this-machine.sh | sh   # a REAL machine. See test/README.md
```

Pass a **commit SHA**, not a branch — `raw.githubusercontent.com` serves a stale branch for minutes
after a push, and that has already cost two runs.

**Run, 2026-10-03, against `768f393`: `check.sh` 283/283, `rehearse.sh` ALL GREEN (61
assertions)** — the 11 new ones are a second user installing `9c62ddd` (the last `mwk`), then
`mwk update` to the new kit, then `piy update`. Every new `check.sh` assertion was confirmed RED
against a sabotaged copy first. The first rehearsal (`6a1cf93`) died at 3/6 on nothing in the
rename: mise itself — see the table.

**Run, 2026-09-25, against `f75ab9d`: `check.sh` 262/262. `rehearse.sh` was NOT run** — the
day's changes were the suite, a `.github/` link and prose, nothing the container exercises; say
which suite ran rather than letting one number stand for both. The count went 256 → 264 → 262:
five assertions added for what the website builds from, three URLs reached that no run had ever
reached (the kit's own raw `install.sh`, excluded since v2 as a 404 and long since 200, plus the
two in `.github/`, which the sweep had never read), then **two removed for being incapable of
failing** — `pgrep -x miniserve` and `pkill -x miniserve` matched only the comments explaining
why those guards were retired. Every added assertion was confirmed RED in a scratch copy first,
and so were the two survivors that replaced the pair. **A number going down is the good outcome
here**; the suite got smaller and can fail in two more places than it could that morning.

**Run, 2026-09-18, against `161d5fd`: `check.sh` 256/256, `rehearse.sh` ALL GREEN (50
assertions).** Every one of the 18 assertions added that day was confirmed RED against the
file it replaced before being believed — including the seven in the store, which only
became testable once `check.sh` stopped handing itself a git identity. Earlier: `e8a5d27`
234/234 and 50, the first run in which "Claude Code installed" was one of them; `895fb31`
200/200 and 48.
Three container runs earlier the same day each went red on one line. Two were real bugs of the
same class — a tool preflight at the top of `piy`, then a status line that printed nothing — both
under a login shell with no mise shims on PATH (the table has the row). The third was the test:
"the server is stopped" ran inside miniserve's graceful shutdown after `pkill`, and every
reproduction that passed had a second's sleep the check did not. It has one now, and prints the
process table if it ever fails again — a red line with no `ps` is a guess. None of the three would
have been found by `check.sh`.

**The container has no git at all**, so it never exercises the store's git paths — not the
commit, not the late `init`, not the push. `check.sh`'s pty store test is the only place
those are covered, which is exactly why it must not hand itself an identity.

`check.sh` needs `sops`, `age-keygen` and a working `script(1)` for the store test, and says
**SKIPPED — not a pass** when it cannot run it. `on-this-machine.sh` has still never been run, and
macOS has still never had the kit installed on it — everything macOS in the table above was
measured by probing a real Mac. A red result on the first real run is information, not a defect.

## v3.1 — the warm environment (mate, 2026-09-17, second round)

What v1 had that v2/v3 had lost, brought back without a page or a new command:

- **No `ccc`. They type `claude`; auto mode is `permissions.defaultMode: "auto"` in
  `settings.json`**, set by `modify_settings.json` only if absent — so a value they change
  stays changed, and that is the escape hatch. `claude 2.1.274` has `--permission-mode auto`
  (measured); the docs describe it as a classifier approving each action in the background,
  versus `bypassPermissions` skipping every check including protected paths. **Where auto
  is not available, it falls back to asking — documented, not measured** (read 2026-10-05,
  `code.claude.com/docs/en/permission-modes`): "Plan: All plans"; it needs a recent model
  (Opus 4.6+ on the API — the kit's `opus` qualifies) and a Team/Enterprise admin can
  disable it; and when settings select `auto` but it is unavailable, "Claude Code starts the
  session in Manual instead" — silently. Also documented: 3 classifier blocks in a row or 20
  in a session pause auto mode and it asks again. So the failure is a beginner being asked
  before every step, not a broken session; the howto's "Changing your mind" is the way back.
  Mate uses auto himself and prefers it.
- **The status bar** — `~/.claude/statusline.sh`, wired by the same merge. Model, folder,
  `% full`, red past 70. Fields verified against the docs (`model.display_name`,
  `workspace.current_dir`, `context_window.used_percentage`, null before the first reply).
  Cost: a custom status line hides most of the footer hints (`esc to interrupt`, `?`); the
  howto teaches the two that matter.
- **Their page is back — as a folder server, not a dashboard** (mate, 2026-09-17, third
  round). `~/piy-work/<project>/<YYYY-MM-DD_slug>/` is `work.l`'s layout for one person; miniserve
  (`0.35.0`, back in `mise.toml`) serves it at `http://127.0.0.1:29200/` with `--readme`, so
  **the root `README.md` is the howto and the bookmark is the howto.** Placed by chezmoi as
  `piy-work/create_README.md` — **write-once, ours on day one, theirs after**; `rehearse.sh`
  appends a line and asserts it survives an apply. What I got wrong the first time: the
  objection to the v2 page was the *bespoke dashboard and queue*, not serving a folder;
  reading what the agent writes is a frequent need, and the rule forbids commands for rare
  things, not infrastructure for frequent ones. **Started by `~/.piy-shell.sh`** on the first
  interactive shell — **the guard is a port probe** (`curl` against `127.0.0.1:29200`), not a
  process-name check: `pgrep -x miniserve` matched any miniserve on the machine, so an
  unrelated one suppressed their page (2026-09-18). `check.sh` goes red if a name-based
  guard comes back. No launchd, no systemd, identical on both
  platforms, self-heals after a reboot. Loopback only, symlinks off, **no password**: the
  served root is only what was written to be read. Flags from `--help`, not memory — `-q`
  is a QR code in 0.35.0. `~/projects` stays `~/projects` (his clients use it); only the
  new folder carries the `piy-` prefix, hard-coded.
- **WSL: files stay in the Linux home, and that is Microsoft's own instruction**, quoted:
  *"store your files in the WSL file system if you are working in a Linux command line…
  `/home/<user name>/Project`, not `/mnt/c/Users/<user name>/Project`."* And the browser
  reaches the server without anything: *"you can access it from a Windows app (like your
  Edge or Chrome internet browser) using `localhost` (just like you normally would)"* —
  WSL2 default (NAT) mode, documented, **not yet measured on a real Windows box**. Explorer
  reaches the folder via `explorer.exe .` or `\\wsl$`; the agent puts a Desktop shortcut
  there once (`wslpath -w` gives the Windows address — a documented tool, unverified here).
  `piy-learn` goes back to being only the log, at `~/projects/learning/README.md`.
  **The howto is the second of the two show mentions**; `check.sh` counts exactly two.
- **`/piy-onboard`** — GitHub, Cloudflare, Replicate; keys in via `piy add NAME` from a
  second tab; each proved with a real call. Endpoints measured 2026-09-17:
  `api.cloudflare.com/client/v4/user/tokens/verify` 200 good / 400 bad,
  `api.replicate.com/v1/account` 200 / 401. `setup.md` hands to it. Dashboard click-paths
  are deliberately NOT in the skill — it points at each vendor's current docs.
- **The page rule + `site-templates/report/index.html`.** Anything longer than a screen
  is a page (artifact), the chat keeps the one-line answer; **pages communicate,
  `~/projects` keeps** — the distinction that made `piy-learn` drop artifacts as a *record*
  still holds. Everything is inline in the template because an artifact cannot load a
  file beside it. Unverified: artifact publishing on a stranger's claude.ai tier.
- **The house rule** — `input/`, `archive/<date>/`, one-line `README.md`, `TODO.md`,
  `input/`+`archive/` gitignored — built by `/piy-new` (it made only a `README.md` before;
  that was #13's unbuilt half) and stated in `create_CLAUDE.md`.
- **Rejected: keeping learnings inside `~/projects/piy-genie` gitignored, or in a
  dotfolder.** Gitignored = no backup, which is the whole point; inside the kit = `piy
  update` pulls over it and uninstall trashes the folder with it; a dotfolder breaks
  "everything visible in `~/projects`". A repo of their own is the only shape that survives.

## v3.2 — the reference architecture, and the show's shape as a skill (mate, 2026-09-17)

- **Three services: GitHub, Cloudflare, Replicate.** Not a preference — measured across the 42
  repos in `~/projects` by files mentioning each: Cloudflare 19, Workers 16, R2 17, D1 13,
  Replicate 11, Astro 20; Hetzner and Dokku 4, Vercel 2, Supabase 0. `create_CLAUDE.md` carries
  it as a need → service table with the rule *"say in one line what these three cannot do
  before reaching for anything else"*, Hetzner as the stated exception, and "anything only
  they use on their own computer is fair game". Product names only, no prices — the file
  already says prices move. Astro is named because every real site of ours is one
  (`mwk-rider` is the auditor + starter); the kit's `site-templates/` stay as the first page.
- **`/piy-wish`** — they explain, we research what already does it, we deliver. Three moves,
  one page of research under `~/piy-work/<slug>/<date>_wish/` (the first real customer of
  the folder server), an answer that must be one of *use X / build the smallest version /
  not worth it*, and the show's rule: something works before they close the laptop. Named for
  the show, because it *is* the show. Eight skills now.
- **`/piy-tasks` validated against `/td-fly:mailbox`**: same shape — inbound + outbound,
  `**From:**` marker, one digest, decisions in one reply — minus the declared `## Cross-repo`
  list, because for one person `gh repo list` *is* the list. Added the `— <project>` sign-off
  and the "six small folders beat one big one" sentence, which is the reason mate wanted it.

## v3.3 — the external review round (2026-09-17, three models, no shared context)

Mate asked for "a few external reviewers with different models". Three fresh agents, each
given a different angle and nothing from the session. **Do this again after any large change;
it found things a single author cannot.**

| model | angle | what it found (all fixed, each with a check that fails on the old behaviour) |
|---|---|---|
| Haiku | consistency sweep | "5 pinned tools" / "Five of them" stale after miniserve returned. `check.sh` now derives the count from `mise.toml` and asserts every prose copy |
| Sonnet | a beginner reading what the person reads | setup built the first folder by hand instead of `/piy-new` (no save points, wrong shape); GitHub sign-in ran *before* the "tell them first" line; the agent-can-touch-all-of-`~` fact never reached the page they bookmark; `sudo`/`compiler` unexplained; prompt one never said the person types every command themselves; the entry name "piy key" existed in one place |
| Opus | security + correctness, reproduced against real sops/age | **five HIGHs in `piy`**: a one-line key file killed `add` with no output (`grep \| head` under pipefail); the decrypted dotenv was *sourced* — a backtick ran as code; `read -rs` took one line and handed the rest of a paste to the shell; `run` with the store missing ran the command with no keys, exit 0; `install.sh`'s `$`-anchored version regex pinned three tools to `latest`. Plus: half-restore minted a key over their data; `command -v git` on a Mac; a failed Claude install still said "type claude"; unhook said "unhooked" for a file it did not change; miniserve respawned forever on a symlinked root; bare `mktemp` on macOS; the settings merge no-ops without `jq` on PATH |

**Two more came out of chasing those, from the container, that no reviewer could see:** Claude
Code had *never* installed in the container (a `jq` shim with no global version, in
`/dev/null`, behind an unconditional "type claude"), and a bare quote in a comment silently
truncated the container script to two assertions at exit 0. Both in the table above, both
guarded.

**And one from the harness:** the store test went red on the *previous* `piy` too, because a mise
shim had appeared on the dev box's PATH and a scratch `$HOME` trusts nothing. The lesson is
general — `command -v` is not "runs" — and the container now executes every tool from the kit
directory rather than checking its symlink exists.

## v3.4 — the second external review round (2026-09-18, after the merge to main)

Same shape as v3.3, three fresh agents on different angles, and it paid for itself again.
**The angle matters more than the model**: the two that were given a job ("be the beginner",
"reproduce the executable surface") found everything; the one asked to sweep for
inconsistency reported a clean repo while two proven findings sat in files it had read.
**A reviewer that returns nothing has not established anything** — check it against a
finding you already hold before believing it.

| angle | what it found |
|---|---|
| a beginner following the published path | the plugin step fails on every fresh machine (no marketplace registered); `install.sh`'s closing banner tells a beginner to close the window in the middle of the agent's own run |
| the executable surface, reproduced | the store's whole backup story: a commit that git refuses and `\|\| true` swallows, a `git init` that only ever ran at creation, and nothing that pushes; the one-second paste drain failing in BOTH directions; the plaintext value back in `grep`'s argv; uninstall leaving a dangling `statusLine`; any unrelated `miniserve` suppressing their page; a tarball kit that `piy update` could never repair |
| a consistency sweep | nothing. It missed the two above that live in prose |

**And the same trap as last time, one layer up.** The reviewer reasoned from the container
to WSL and called the kit-fetch unsafe because "WSL ships no git". The container is
harsher than any real machine; Canonical's manifest says otherwise (table above). The
lesson is not "that reviewer was wrong", it is that **our own test bed is the least
representative environment we own**, and it is easy to quote it as evidence about a
person's laptop.

**What I got wrong, in my own first pass:** I repeated the python3-is-absent fact from the
container as though it applied to WSL. Measure the platform you are claiming about.

## v3.5 — the rename: Mate Wish Key → Prompt It Yourself, `mwk` → `piy` (2026-10-02)

The show became Prompt It Yourself (`mergodon/matewishkey-web#99`, decided 2026-09-29:
"retired everywhere a reader sees it"); the GitHub org and this repo were renamed with it.
Mate asked for the commands to follow, so **everything the kit puts on a machine is `piy`
now**: the command, the eight `/piy-*` skills, `~/.piy-shell.sh`, `~/piy-work`,
`~/projects/piy-genie`, `piy.css`, `PIY_REF`/`PIY_STORE`/`PIY_KEY`. The red `#e2342b` and the
host stay. History in this file was renamed along with it, so an old incident reads with
today's names; `docs/` was left as written.

**An existing machine comes across in two steps, and both are rehearsed from `9c62ddd`**,
the last `mwk` commit:

1. **The old `mwk update`** runs the OLD `install.sh` from disk, which fetches the new kit
   into `~/projects/mwk-genie` and applies it. `run_onchange_before_00-retire-mwk.sh` runs
   first: moves `~/mwk-work` → `~/piy-work` (never copies, never when both exist), unhooks
   the old rc line, deletes our old command/shell file/skills **by name** (not `mwk-*` — a
   skill of theirs keeps), and renames our words inside their two **write-once** files,
   `~/.claude/CLAUDE.md` and the howto. No later apply ever reaches a `create_` file, so
   without that their agent would keep typing `mwk add` forever.
2. **The first `piy update`** finds the kit at the old path, and `install.sh` step 1 moves
   it to `~/projects/piy-genie` and repoints `origin`. It cannot happen in step 1: chezmoi is
   reading from that folder.

**A tarball kit keeps the old sources on disk** (untarring deletes nothing), which is what
exposed the `.chezmoiignore` row in the table above.

## Still open

| # | |
|---|---|
| **#14** | The show is mentioned exactly twice now (`README.md`, the howto) and `check.sh` counts it. Whether that tone is right is mate's — open until he says |
