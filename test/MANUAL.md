# The bits no script can check — walk this on a real machine

`check.sh` and `rehearse.sh` cover everything mechanical. What is left needs a browser, a
login, a Windows desktop, or a person reading the thing. **Windows first**: it has never been
tested by anyone (#9), and three of the kit's claims are documented-not-measured there.

Every ✗ here is information, not a defect. Write down what actually happened.

## Before you start

**Take the default path, because that is the one being tested.** v3 has been on `main`
since 2026-09-17, so the prompts a guest would use are the ones to use:
`https://raw.githubusercontent.com/promptityourself/piy-genie/main/prompts/install.md`, and the
same for `setup.md`. Paste the fenced block. Say nothing to prompt two about branches — it
takes `main` on its own, and watching it do that unaided is part of the test.

Two things that used to be here and are not any more. The website **does** show both prompts
again, fetched from `main` at build time (`CLAUDE.md` → *The cross-repo coupling*, verified
2026-09-19), so it is a second source and a walker may legitimately arrive from it. And there
is no reason to pin a commit: pinning was for testing a branch `main` did not have. Only go back to `<sha>` and *"use commit `<sha>`"* if you are
deliberately testing something unmerged.

## Prompt one — in a browser chat, Windows

- [ ] **It asks Mac or Windows first, and nothing else.**
- [ ] **WSL install:** it warns about the restart before the restart, says nothing opens by
      itself afterwards, and says the Ubuntu username/password is NOT the Windows one and
      shows nothing while typed — **before** you type it.
- [ ] **Ubuntu becomes the default profile in Windows Terminal.** The prompt tells the agent to
      have you do this and to look up where the setting is. Confirm: press Ctrl+Shift+T later
      and the new tab is Ubuntu, not `PS C:\`. **This is the gap a beginner hits first.**
- [ ] **`claude --permission-mode auto` starts** — and then: **does it ask before commands, or
      not?** This is the single most important measurement on this list. The docs say auto
      mode is available "when available to your session"; nobody has run it on a fresh
      consumer account. Note exactly what the first command did.
- [ ] **Sign-in opens the Windows browser**, and the prompt said it would.

## Prompt two — inside Claude Code

- [ ] **It reads `install.sh` out loud against the four questions** (sudo, outside `$HOME`,
      hosts, deletions) and the answers are all "no" — the host list must not flag its own
      installer.
- [ ] **`install.sh` runs to the end** with nothing typed. Note anything that looked like a hang.
- [ ] **`git --version` answers afterwards.** Nothing installs git on Linux; the Ubuntu WSL image
      is assumed to ship it. If it does not, `/piy-new` cannot work — that is a finding.
- [ ] **The bar at the bottom shows model · folder · % full** after the first reply.
- [ ] **`http://127.0.0.1:29200/` opens in the Windows browser** and shows *How to work with your
      genie*. Documented (WSL2 localhost forwarding is on by default), never measured on the
      fleet. If it does not open, try `http://localhost:29200/` and note which worked.
- [ ] **A new Ubuntu tab knows `piy`** and `piy` alone prints three commands.
- [ ] **`/piy-onboard`:** the GitHub device code is read out slowly; the first `piy add` is
      preceded by the key warning; `piy add` refuses inside Claude and works in the second tab;
      the second tab is Ubuntu (see above); `cat ~/.config/sops/age/keys.txt` shows one
      `AGE-SECRET-KEY` line and you can copy it; the Cloudflare and Replicate checks print
      `200`; the closing line has ticks that came from those calls.
- [ ] **Desktop shortcuts.** The agent puts a shortcut to `~/projects` and `~/piy-work` on the
      Windows Desktop via the `\\wsl$` address. Double-click each: Explorer opens on the Linux
      folder. `wslpath -w` is the documented tool for the address; nobody here has run it.
- [ ] **`explorer.exe .`** from a project folder opens the right place.
- [ ] **`/piy-new`** makes `README.md`, `input/`, `archive/`, `.gitignore`, a private repo,
      and moves you into it with `cd …` + `claude` — and it waits for you to say the new
      window started.
- [ ] **A page.** Ask for something longer than a screen (a plan, a comparison). It lands under
      `~/piy-work/<project>/<date_slug>/`, the link opens in the Windows browser, it looks like
      the rest of the kit, and `~/piy-work` got a commit.
- [ ] **`/piy-save`** says what changed in plain English, writes `TODO.md`, pushes, and prints
      `cd …` / `claude` / `/clear` with the `/clear` explanation.
- [ ] **`/piy-learn`** writes `~/projects/learning/README.md`, entry at the top, and does NOT
      touch `~/piy-work/README.md`.
- [ ] **`/clear` and `/model sonnet`** do what the howto says; the bar changes model name.
- [ ] **Turn the asking back on** by saying so; confirm `permissions.defaultMode` changed in
      `~/.claude/settings.json` and the next session asks.
- [ ] **`/piy-bug`** shows the report before filing and redacts the home path. **Answer no** —
      do not file a real issue from a test.

## Then the automated pass on the same machine

```
curl -fsSL https://raw.githubusercontent.com/promptityourself/piy-genie/<sha>/test/on-this-machine.sh \
  | PIY_REF=<sha> sh
```

It installs, checks, uninstalls and reinstalls — the machine is left set up. Its last block
lists what it could not test; those are the boxes above.

## macOS — the same, plus

- [ ] **Command Line Tools (prompt two, after the install is proved):** the agent warns first, `xcode-select --install` opens Apple's
      window, and the agent waits for you to say it finished rather than assuming.
- [ ] **No Homebrew appears** (`command -v brew` finds nothing).
- [ ] **iTerm2 lands in `~/Applications`** with no password asked, and Ctrl+J makes a new line
      in Apple's Terminal too.
- [ ] **Ad-hoc signed binaries run** — `sops`, `age`, `chezmoi`, `miniserve`, `jq`, `gh` all
      answer `--version`. The last three were pinned after the signing check.
- [ ] **Everything in the Windows list from "prompt two" down**, with `open .` and Finder in
      place of Explorer, and `ln -s` shortcuts on the Desktop.

## Only worth doing before a release

- [ ] **The live site still matches.** Open `promptityourself.com/topics/put-the-genie-in-the-box/`
      and check it says what `HOW-TO.md` says — and if it shows the two prompt boxes, that they
      are the ones in `prompts/`. It shows both as of 2026-09-19, byte-for-byte the first fence
      of each prompt file (`CLAUDE.md` → *The cross-repo coupling*). What to look for now is a
      MISMATCH, not an absence: their build is the thing that can go stale, not ours.
