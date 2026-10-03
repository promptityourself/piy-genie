# Put the genie in the box

An AI agent, running on your own computer, set up for someone who has never opened a
terminal. You paste two things, answer one question, and about an hour later you have a
computer that does what you ask it to.

You do not need to be any good at this. That is the whole point.

## What you need

- **A computer that is yours:** a Mac, or Windows 11. Not a work computer: the agent gets
  on with things without asking you about every step, and it can see and change anything
  in your home folder. That is what makes it useful, and it is why it belongs on your own
  machine and nobody else's.
- **A paid Claude plan.** Claude Code is not usable on the free one. If you do not have
  one, [claude.ai/upgrade](https://claude.ai/upgrade). The first step will send you there
  anyway.
- **A phone, or a second screen.** Signing in to GitHub shows you a short code on one
  screen that you type on another.
- **A password manager.** Any one. There is exactly one thing in all of this that you have
  to save and can never get back if you lose it, and this is where it goes.
- **About an hour, and a coffee.** Some steps download a lot and show nothing while they
  do it. Every one of those tells you first.

## Step 1: in your browser

Open [claude.ai](https://claude.ai), a normal chat, nothing special, and paste this in:

<!-- PROMPT ONE goes here. On GitHub: it is the grey box in prompts/install.md. -->

**[prompts/install.md](prompts/install.md):** copy the grey box.

It asks you one question: **Mac or Windows?** Then it walks you through getting Claude Code
onto your computer, one step at a time, and waits for you to say each one worked.

**In this part, you type the commands.** The chat in your browser cannot touch your
computer, so it tells you exactly what to type and where, one line at a time. Three things
it will warn you about before they happen, so you know what you are looking at:

- **Windows:** it installs a real Ubuntu terminal inside Windows, which needs a restart.
  Afterwards nothing opens by itself; you open Ubuntu from the Start menu. The first time,
  it asks you to invent a username and password, and **the screen shows nothing at all
  while you type the password.** That is normal. It is not your Windows password.
- **Mac:** Apple's own developer tools download first: five to fifteen minutes, in a
  window Apple opens, and it looks finished before it is. Wait for Apple's window to say so.
- **Both:** the last line starts Claude Code with a setting that lets it work without
  asking you about every command. It explains that line before you run it.

Step 1 ends with Claude Code open on your computer and signed in. **Keep that window
open.** The next thing you paste goes in there, not in the browser.

## Step 2: in Claude Code

In the window step 1 left open, paste this:

<!-- PROMPT TWO goes here. On GitHub: it is the grey box in prompts/setup.md. -->

**[prompts/setup.md](prompts/setup.md):** copy the grey box.

**From here on, the agent types and you watch.** It will:

1. **Read the installer out loud before running it.** Does it ask for a password, does it
   touch anything outside your home folder, where does it download from, does it delete
   anything? It tells you the answers. You cannot read it; it can. "Trust us" is not an
   answer, so this is the answer instead.
2. **Run it.** Two to five minutes, mostly silent. Go and get the coffee.
3. **Prove it worked**, in plain words, rather than just saying it did.
4. **Connect your accounts:** GitHub (where your work is saved), Cloudflare (websites,
   domains, email at your own domain) and Replicate (AI models). Each one is proved to
   answer, not assumed. When it needs a key from you, you type it in a second terminal tab,
   never in the chat, so it never ends up in a transcript.
5. **Make you a key of your own**, the first time you store one. It will tell you to copy
   one line into your password manager, as an entry called **piy key**. **Do that, once.**
   It is the only way into your keys, on this computer and on the next one, and nobody
   can make it again. The agent never sees it.
6. **Make your first project:** a folder with the right shape, saving turned on, a private
   copy on GitHub. Then it moves you into it in a fresh window.

## What you end up with

| | |
|---|---|
| `claude` | starts the agent, from any folder. It gets on with the work; Anthropic's own safety check runs in the background instead of asking you |
| the bar at the bottom | which model, which folder, and how full its memory is, so a slow, forgetful agent is a number you can see |
| `http://127.0.0.1:29200/` | **your page. Bookmark it.** How all of this works, in plain English, and under it every page the agent writes for you |
| `~/projects/<your thing>/` | your work: `input/` for things you drop in, `archive/` for what has been dealt with |
| `~/projects/keys/` | your keys, encrypted, in a repo of their own, pushed to a private copy on GitHub |
| `piy add NAME` | puts a key in that store. You type it, so it never goes through the chat |

And eight things you can ask for by name, or just say in normal words: `/piy-wish` turns
an idea into a researched answer and a first version, `/piy-onboard` connects your
accounts, `/piy-new` starts a project, `/piy-save` saves and pushes it and tidies up,
`/piy-learn` adds to your record of what you have learnt, `/piy-review` is a second
opinion, `/piy-tasks` is what is open across your projects, `/piy-bug` reports anything
in the kit that is broken.

Everything else (seeing which keys you have, a new computer, changing a key, taking it all
off again) you ask the agent. There is no menu and no long list of commands on purpose.

## When something goes wrong

- **Paste the error back to it.** Whatever red text you got, paste it in and let it work
  it out. This is the single most useful habit you can have.
- **Take a screenshot and paste that in.** It can see pictures.
- **Ask what a command does before you say yes.** That question is never annoying.
- **"You have reached your limit" is not a fault.** Every plan has a ceiling on how much
  you can use in a stretch, and a long session can reach it. It says when it is back.
  Nothing is lost, and you carry on then.
- **If the genie itself is broken**, say *"report this bug"*: it writes the report, shows
  you, and files it only if you say yes.

## Changing your mind

**"Ask me before every command from now on"** turns the asking back on: one line in a
settings file, and the agent changes it. **"Take all of this off my computer"** does what it
says: your key goes to the trash, not the bin, and your work is not touched.
