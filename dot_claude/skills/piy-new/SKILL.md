---
name: piy-new
description: Start a new project for someone who is not a developer — a folder in ~/projects, save points turned on, a private GitHub repo, and one line telling them how to come back to it. Use when they say they want to start something new, or want to work on a thing that does not exist yet.
argument-hint: "[what it is for]"
---

<!-- requires: git gh -->

They want to start something new. **Do all of this for them** — do not hand them
commands to type.

The argument, if there is one, is what the project is for: `$ARGUMENTS`

## 1. What is it for

If they did not say, ask **one** question: what do they want this project to do?
One sentence back from them is enough. Do not interview them.

## 2. Pick a name

Turn their answer into a short folder name — lowercase, hyphens instead of
spaces, two or three words at most. `holiday-photos`, not
`my-holiday-photos-project-2026`.

Show them the name you picked and let them change it. One line, not a debate.

If `~/projects/<name>` already exists, say so and pick another rather than
writing into it.

## 3. Make it

- `mkdir -p ~/projects/<name>/input ~/projects/<name>/archive` and work there from
  now on. **Every project has the same three things, so nobody has to remember where
  anything goes:**
  - `input/` — where they drop things for you: a PDF, a photo, a spreadsheet. Say that
    sentence out loud; it is the folder they will actually use.
  - `archive/<date>/` — where something from `input/` goes once it has been dealt with,
    under the day it was dealt with. Move, never delete.
  - `README.md` — a title and the one sentence they gave you. That is all it needs today.
- Write a `.gitignore` with `input/` and `archive/` in it. Those are **their material**,
  not the project's — a save point should hold the work, not the 40 MB PDF it came from.

## 4. Turn on save points

`git init`, then a first commit.

Say what it buys them, **in one sentence, once**: from now on every version of
their work is kept, so trying something and hating it costs nothing. Do not
explain git. Do not use the words *repository*, *commit* or *branch* without
saying what they mean in the same sentence.

## 5. Put it on GitHub

A private repo, pushed, using the official GitHub command-line tool — check its
own help rather than reciting flags from memory.

**Private unless they ask otherwise.** Say that out loud, because "on the
internet" is the bit that worries people.

If they are not signed in to GitHub on this machine, or the tool is not
installed, do not derail the whole thing: say the folder and save points are
working, that the GitHub copy is missing, and offer to sort it now or later.

## 6. Show them it worked

Show the folder path, and that the first save point and the GitHub copy exist.
"Done" on its own is not done.

## 7. Move them into it — do not just tell them where it is

**You are still standing in the wrong folder, and so are they.** You made the
project somewhere else; this window is not in it. If you stop here and carry on
talking, the next hour of work lands in the wrong place.

So walk them through it, and wait:

1. **Tell them to open a new terminal window.** Not this one. Say why in one
   line — this window is standing in the old folder and cannot move.
2. **Give them these two lines to paste**, on their own lines, with a blank line
   above and below:

        cd ~/projects/<name>
        claude

3. **Wait for them to say it started.** Do not carry on in this window. This is
   the same shape as the last step of setup: a thing that only exists once a
   new window has read it.

Say what the two lines do, once: the first walks into the folder, the second
starts me there. `cd` is the one command worth them knowing and this is where
they will use it every day.

## 8. Then, in the new window

    /piy-save

...when they are finished for now. It writes down what changed and puts it
somewhere safe. Tell them they can also just say "save my work" — the slash
command and the sentence do the same thing.

## If it is a website, do not start from an empty file

Two starter sites ship with the kit, at `~/projects/piy-genie/site-templates/`:

- **`one-page/`** — everything on one scrolling page. Almost every first website is this.
- **`pages/`** — a small site with a menu, when there is genuinely more than one thing to say.

Copy one into their project rather than writing a page from scratch, then change the words
with them. Start with `one-page/` unless they say otherwise; splitting it later is five
minutes and starting with too much is where people stall.

**Then say what the structure is, in about three lines:** plain HTML with one stylesheet,
no build step and nothing to install, so opening the file in a browser just works. The
colours and sizes are all named at the top of `piy.css` — change one there and the whole
site changes. That is the only thing they need to know to start editing it.

`~/projects/piy-genie/site-templates/README.md` has the longer version if they ask.

## 9. Then get on with it — over there, not here

Once they are running in the new window, that session asks what they actually
want to do. That is the thing they came for. Everything above was only the
folder.

**In this window, you are finished.** Say so plainly, so they are not left with
two conversations open and no idea which one is real.
