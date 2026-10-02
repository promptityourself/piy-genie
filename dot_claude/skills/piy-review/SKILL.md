---
name: piy-review
description: Step back and look at this project with fresh eyes — work out what it is actually trying to do, then say where it has drifted away from that, and offer to tidy it up. Summoned on demand. Use when they ask for a review, a second opinion, a check-up, or say something feels off and they cannot say why.
---

<!-- requires: git -->

They have summoned you for a look around. **This is a change of altitude, not a
bug hunt.** You have been inside the details; now come out of them.

Do not start listing problems. Do the first step properly or the rest is noise.

## 1. Work out what this is for

Read the project as if you had never seen it — the `README.md`, the `TODO.md` if
there is one, the recent save points, then the work itself. From that, and only
from that, write **one paragraph: what is this trying to do?**

Say it back to them and ask if it is right.

If your paragraph and their answer do not match, **stop — that is the finding.**
A project that has quietly become a different project is worth more than any
list of small things underneath it, and everything you would have said next was
measured against the wrong thing anyway.

## 2. Look at it from somewhere else

Now go round it once, deliberately not from the angle you have been working at.
Useful angles, pick the ones that fit:

- **A stranger opening this next week.** Would they know what it does and where
  to start?
- **Them, in a month, having forgotten all of it.** Does anything only work
  because of something you both happen to remember today?
- **Consistency.** Two things doing the same job in different ways. A name that
  means one thing here and another thing there. A rule followed everywhere
  except one place — which is usually the place that will bite.
- **Half-finished.** Something started, abandoned, and still sitting there
  looking finished.

## 3. Say what has drifted, not what is imperfect

Every project has small imperfections and they do not matter. **What matters is
what gets harder the longer it is left.** That is the only sorting that counts:

- **Drifting** — costs a little to fix now, more every week, and eventually it
  is a rebuild. Say these.
- **Fine** — untidy but stable, will cost the same to fix whenever. Do not say
  these. They are noise dressed as diligence.

**Three things at most.** If you have found more than three, you have gone back
to bug hunting — pick the three that are moving.

For each one: what it is, why it gets worse, and what fixing it looks like, in
plain English. No jargon, no severity labels.

**If nothing has drifted, say so and stop.** That is a real answer and it is
worth more than a manufactured list. Do not pad it.

## 4. Offer to fix them

Say which of the three you can do right now and roughly what would change. Then
wait. **Do not start fixing while you are still describing** — they asked you to
look, not to rearrange.

If they say yes, fix them, then run `/piy-save` so the tidy-up is a save
point of its own and not tangled up with their actual work.
