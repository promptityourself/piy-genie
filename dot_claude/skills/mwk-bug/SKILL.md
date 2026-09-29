---
name: mwk-bug
description: Report a bug in the Mate Wish Key kit itself — write the report out of what actually happened, show it to them, and file it on GitHub once they say yes. Use when they say something is broken, that a command did not work, that this is a bug, or ask how to report one.
argument-hint: "[what went wrong, if they said]"
---

<!-- requires: gh -->

Something in **this kit** is not working and they want it fixed. Write the
report for them — they cannot, and that is the whole reason this exists.

What they said, if anything: `$ARGUMENTS`

## 1. Work out whether it is actually ours

**Do this before writing anything.** Three different things get called "a bug"
and only one of them belongs here:

- **This kit** — `mwk`, the prompt, the bar at the bottom, `CLAUDE.md`, one of the `/mwk-`
  commands, or a step in the setup. **That is a bug report. Carry on.**
- **Claude Code itself**, or a plugin somebody else wrote. Say so plainly, say
  where it actually goes, and offer to help them get there. Filing it with us
  puts it somewhere nobody who can fix it will read it.
- **Their own project** — their code, their site, their files. That is not a
  bug report, that is the work. Offer to fix it now instead.

If you genuinely cannot tell, say which one you think it is and let them
decide. Do not file on a guess.

## 2. Get the facts yourself

**Do not interview them.** You were there; they were not taking notes. Go and
look:

- **What actually happened** — the real error text, copied, not described.
- **What they were trying to do**, in their words, from what they asked for.
- **What they expected instead.** Only ask if it is genuinely not obvious.
- **Which machine** — macOS, Windows with WSL, or Linux.
- **Versions** — `claude --version`, and the kit's version from
  `git -C ~/projects/mwk-genie rev-parse --short HEAD`. There is no version file
  any more — the plugin manifest that used to carry one is gone, and a commit is
  a better answer anyway. If the kit is not in that folder, say so in the report
  rather than guessing.
- **Whether it reproduces.** If it is safe and quick to try again, try again
  and say what happened. "Happens every time" and "happened once" send the
  person reading it down completely different paths.

## 3. Take out the things that should not travel

**The report goes somewhere public.** Before they see it, before it is sent:

- **Replace their home folder path with `~`** everywhere. `/Users/their-name`
  and `/home/their-name` carry their name.
- **Take out anything that looks like a key, a token or a password** — long
  random strings, anything after `Bearer`, anything in a variable with `KEY`,
  `TOKEN` or `SECRET` in the name. Replace with `<removed>`.
- **Take out their project's content** unless it is the actual bug. A file name
  is usually enough; the file's contents almost never are.
- **Keep the error text intact.** That is the useful part, and over-redacting
  it makes the report worthless.

## 4. Show them, then ask

Print the whole report — title and body — and say, in one or two lines:

> This goes to a **public** page on GitHub. Anyone can read it, and it will
> have your GitHub name on it. Nothing else about you goes with it. Send it?

**Wait for a yes.** Never file silently, and never file a report they have not
read. If they want something taken out, take it out and show them again.

## 5. File it

```
gh issue create -R promptityourself/piy-genie \
  -t "<the title>" -b "<the body>"
```

Give them the link it prints, and tell them what happens next in one line:
somebody reads it, and they will get an email if there are questions.

**If `gh` is not set up** — they skipped GitHub, or the login expired — do not
make it their problem. Save the report next to their work, tell them the path,
and give them this to open when they are ready:

    https://github.com/promptityourself/piy-genie/issues/new/choose

## 6. Then get them unstuck

A filed bug does not fix their afternoon. **If there is a way around it, do
that now** — the report is so it stops happening to the next person, not
instead of helping this one.
