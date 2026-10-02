---
name: piy-onboard
description: Connect the three accounts everything else leans on — GitHub, Cloudflare, Replicate — for someone who is not a developer. Walk them through each in their browser, put each key in their store from a second tab, and PROVE each one answers. Re-runnable — it also answers "what is connected?". Use at the end of setup, when they ask to connect or set up an account, or when something says a key is missing.
---

<!-- requires: gh piy curl -->

Three accounts, in this order, and **the closing line is measured, not claimed**:

    GitHub ✓   Cloudflare ✓   Replicate –

Every check below is a real call. A tick you did not get from a call is not a tick.

**Say first, in three lines, what each is for and what it costs** — GitHub keeps a copy of
their work off their laptop (free); Cloudflare is where a website, a domain and email at
their own domain live (the first two free at their size); Replicate runs image and other
models by the second (pay as you go, pennies for trying things). If they do not want one
of the three today, skip it and say so in the closing line. Do not sell.

## 0. What is already connected

Run all three checks (below) before asking them to do anything. Anything already green is
already done — say so and move on. This is what makes the skill re-runnable.

## 1. GitHub

Check: `gh auth status` exits 0.

If not: `gh auth login --hostname github.com --git-protocol https --skip-ssh-key` in the
background, read the short code out of its output slowly — it has letters and numbers and
is easy to hear wrong — and send them to github.com/login/device. Their phone is fine.
Poll `gh auth status` until it is clean; if the code expires, run it again and give them a
fresh one rather than reporting failure. No account yet → walk them through making one
first; it is free.

## 2. Cloudflare

They need an **API token** (not the Global API Key). Tell them where to make one by looking
at Cloudflare's current documentation rather than describing the dashboard from memory —
it moves. A token scoped to what they will actually use is right; "everything" is not.

Then, in a second tab — say why it is theirs to type, and that the screen shows nothing
while they paste:

    piy add CLOUDFLARE_API_TOKEN

**If this is their first `piy add`**, warn them BEFORE they run it: it will make them a key
of their own and tell them to copy one line into their password manager. That line is the
only way into their keys, ever. Say it before, not after.

Check — measured 2026-09-17, a good token answers 200 and a wrong one 400:

    piy run -- sh -c 'curl -s -o /dev/null -w "%{http_code}" \
      -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
      https://api.cloudflare.com/client/v4/user/tokens/verify'

`200` is the tick. Anything else: say what came back and try the token again — do not
mark it done.

## 3. Replicate

Same shape. The token is on their Replicate account page (again: point at Replicate's own
docs for where, not memory).

    piy add REPLICATE_API_TOKEN

Check — measured 2026-09-17, a good token answers 200 and a wrong one 401:

    piy run -- sh -c 'curl -s -o /dev/null -w "%{http_code}" \
      -H "Authorization: Bearer $REPLICATE_API_TOKEN" \
      https://api.replicate.com/v1/account'

## 4. Their keys, somewhere other than this laptop

Only once GitHub works, and only if `~/projects/keys` exists — it appears at their first
`piy add`, which may not have happened yet. A repo on one disk is not a backup, and what
they read promises them one.

- **Give git their name**, if it has none: `user.name` and `user.email` from `gh api user`,
  using `<id>+<login>@users.noreply.github.com` so their real address is not in every
  commit they ever make. Without an identity git REFUSES to commit on any machine whose
  hostname has no domain, and `piy` can only tell them after the fact.
- **If the store has no `origin`, give it one and push:**
  `gh repo create keys --private --source ~/projects/keys --remote origin --push`.
  Then confirm with `gh repo view --json visibility` and say the word back to them. Every
  value in there is encrypted, so this is not a disaster waiting to happen, but it is the
  one repo where "private" is worth reading with your own eyes.
- **Say what it does and does not cover.** GitHub now holds the locked file. The key that
  opens it is the line in their password manager, it is not in there, and it never will be.

If GitHub is not connected, skip this and say it in one line: their keys live on this
computer only until it is.

## 5. The closing line

One line, three names, a tick or a dash each, **from the checks you just ran** — and, if
step 4 put their store on GitHub, four words saying so. Then one sentence on what the
first dash would unlock, if there is one, and stop. No summary, no
next steps — `/piy-new` is the next thing and they will get there.
