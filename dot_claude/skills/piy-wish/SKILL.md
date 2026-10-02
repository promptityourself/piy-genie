---
name: piy-wish
description: Turn a wish — "I wish my computer could…" — into an answer and a first version, the way the show does it — they explain, we research what already does it, then deliver. Use when they describe something they want, an idea, a problem they would like solved, or say they wish something worked, before any project is made.
argument-hint: "[the wish, in their words]"
---

<!-- requires: gh -->

Someone has a wish. **Three moves, in order: understand it, find what already does it,
deliver.** The research is the part people skip, and it is the part that saves them from
building a worse copy of a thing that exists.

The wish, if they said it: `$ARGUMENTS`

## 1. Understand it — one question at most

Get it in their words. If it is not clear what they would *do* with it, ask exactly one
question: *"the day this works, what do you do with it?"* Do not interview them. Do not
propose anything yet.

## 2. Research — properly, and write it down

**Look for the thing that already does it** before thinking about building anything:

- a free or open-source tool that does exactly this;
- something one of the three services already has — Cloudflare, Replicate, GitHub — that
  covers it with no code;
- a paid product, if the free ones are genuinely worse — with the price.

Search the web for it. Read what you find, do not guess from names. Then write **one page**
— never longer — under `~/piy-work/<slug>/<YYYY-MM-DD>_wish/` from the report template,
with, in this order:

1. **The wish, in one line**, in their words.
2. **The answer, in two lines**: *use X* / *build it — the smallest version is Y* / *not
   worth it, because Z*. Say which. A page that ends in "it depends" is not finished.
3. **What exists** — two or three options, one line each: what it costs, what it gives up.
4. **If we build**: what it is made of, using the three services unless there is a stated
   reason not to, and what the first working version does *today*.
5. **What happens next** — the first thing you will do once they say go.

Hand them the link and the two-line answer in the chat. Then wait for one word.

## 3. Deliver

- **"Use X"** → set it up now, with them, in this session. Sign-ups are theirs; everything
  else is yours. End with it working and one line on how to use it tomorrow.
- **"Build it"** → `/piy-new` for the folder, then build the smallest version that does the
  wish, today, in this session. Not the full idea — the first thing they can actually try.
  `/piy-save` at the end.
- **"Not worth it"** → say so plainly and stop. Saving somebody an afternoon is a delivery.

**Something works before they close the laptop.** That is the show's rule and it is this
skill's rule: a page of options with nothing running is a failure, however good the page.
