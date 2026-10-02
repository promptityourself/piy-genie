---
name: piy-save
description: Wrap up a session for someone who is not a developer — say in plain English what changed, leave a note for next time, tidy anything that has gone stale, make a save point, push it to GitHub, and close off anything on the project's list that is provably done. Use when they say they are finished, done for now, want to save or back up, or want to close something off.
---

<!-- requires: git gh -->

They are finished for now. **Save everything, leave the place tidy, and say very
little** — this is the last thing they read, not a report. Everything below runs
without asking. Ask **one question at most**, at the very end, and only if there is
genuinely one to ask.

Saving and closing are the same act. If they say they are done with this project
*for good*, do the same steps and, at the end, say so in the note and in the last
commit message — nothing else changes.

## 0. Before anything, look at what is about to be committed

**Never commit a key.** Keys belong in `~/projects/keys`, not in a file. If you find
one in what is about to be saved, stop, take it out, and tell them in one line to
put it in the store from a second tab: `piy add THE_NAME`, and why. `input/` and
`archive/` are theirs, not the project's — they should already be in `.gitignore`,
and if they are not, add them before the push rather than after.

## 1. What actually changed

Read the actual changes, not just the file names, so you can describe them in their
words. **If nothing has changed**, say so and stop — an empty save point is noise.
**If this folder is not set up for save points**, say so plainly and offer to set it
up now; `/piy-new` is what does that.

Two or three lines, in plain English: what the work does now that it did not before.
Not a list of files. Not a diff. They want to know it landed.

## 2. The note for next time

Write **`TODO.md`** in the project folder — a short note to whoever opens this next,
which is you, with none of this conversation in your head:

- **Where things got to.** One or two lines.
- **What is next.** Only real things: something started and not finished, something
  that broke, a decision they still have to make.

**Replace the file, do not add to it.** A note that only ever grows turns into sludge
nobody reads; anything done comes out. If there is genuinely nothing outstanding,
say so in one line, or delete the file. Then tell them, in one line, that the note
is there.

## 3. Tidy what has gone stale

Fresh eyes, quickly: does `README.md` still describe what the project is for? Does
anything in it name a file, a command or a step that no longer exists? Fix the small
and obvious inline. Do **not** rewrite, restructure, or polish — a stale sentence is
the target, not the prose.

## 4. Save point, then push

Commit everything, `TODO.md` included, with a message that says what changed in
normal words — a sentence a human would write, no prefixes or tags. Then push, so
there is a copy that is not on their laptop and the note travels with it.

If the folder has nowhere to push to, say so and offer to put it on GitHub now,
private. Do not do it without asking — that is the one question this skill may ask.

## 5. Close off what is done

If the project has a GitHub issue list, look at what is open. For each one, ask
only: **did this session provably finish it?** — a change you just made, that you
can point at. If yes, close it with one plain line saying what did it. If not, leave
it exactly alone. Never close something because it is old, and never open new
issues here; things worth tracking go in `TODO.md`, where they will actually be read.

## 6. How to come back, and how to start fresh

Print these on their own lines, with a blank line above and below:

    cd ~/projects/<folder name>
    claude

...opens this project again, from any terminal window. You will read `TODO.md` when
you get there, so they can start the next session by saying "carry on".

    /clear

...starts a fresh conversation. Say what it actually does, because the word is
alarming: **it makes you forget this conversation, not their work.** Their work is
saved, pushed, and the note is written down — this only empties your head so the
next thing starts clean and fast. Mention the context bar in passing if it is
looking full; that is the thing `/clear` fixes.
