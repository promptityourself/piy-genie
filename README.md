# Mate Wish Key — put the genie in the box

An AI agent, running on your own computer, set up for someone who has never opened a terminal.

**Two things to paste, one question to answer, and no password.**

> This is homework for [the show](https://matewishkey.com/show/). You do it once, on your own machine, and then we build the thing you actually wanted — together, on air.

**Never opened a terminal? Start with [HOW-TO.md](HOW-TO.md)** — what you need, what happens, and what you end up with, in plain English. This file is the repo's front door; that one is yours.

## How it goes

1. **[Paste prompt one](prompts/install.md)** into any chat you already have open. It asks whether you are on a Mac or on Windows — the only question in the whole process — and gets Claude Code onto your computer and signed in.
2. **[Paste prompt two](prompts/setup.md)** into Claude Code itself. It reads the installer, tells you what it does, runs it, checks its own work, and makes you somewhere to start.

That is the whole thing. It does not ask which model, whether it may use admin, or whether to check with you before each step. Those were questions once; they are decided now, and the one that is worth changing your mind about is one character in a file the setup shows you.

## What you end up with

| | |
|---|---|
| `claude` | starts the agent, from anywhere. It gets on with the work without asking you about every command — Anthropic's own safety check runs in the background instead |
| the bar at the bottom | which model, which folder, and how full its memory is — so a slow, forgetful agent is a number you can see, not a mystery |
| `mwk add NAME` | puts a key in your store — you type it, so it never goes through the chat |
| `~/projects/<your thing>/` | your work: `input/` for things you drop in, `archive/` for what has been dealt with, a one-line `README.md` |
| `~/projects/keys/` | your keys, encrypted, in a repo of their own. Once GitHub is connected it is pushed there, private, so they come with you to a new computer |
| `~/projects/learning/` | what you have learnt, added to each time you ask |
| `http://127.0.0.1:29200/` | your page: how to work with all of this, and under it every page the agent writes for you. The files are in `~/mwk-work`, one folder per project |

Plus eight things you can ask for by name: `/mwk-wish` takes an idea, finds what already does it, and delivers a first version, `/mwk-onboard` connects your accounts and proves they work, `/mwk-new` starts a project, `/mwk-save` saves and pushes it and tidies up, `/mwk-learn` adds to your record of what you have learnt, `/mwk-review` is a second opinion, `/mwk-tasks` is what is open across your projects, `/mwk-bug` reports anything in here that is broken.

Everything else — seeing which keys you have, a new computer, changing a key — you ask the agent. **There is no menu and no long list of commands on purpose:** a thing you do once a year is a thing the agent does for you, not a thing you learn.

## The two things that will scare you

**It does not ask you before each command.** Setting up a computer is hundreds of small commands, and approving them one at a time means you stop reading and start pressing enter, which is worse than not being asked. So instead, Anthropic's own check looks at each action in the background and stops the ones that do not fit what you asked for. **This is still why it does not belong on a work computer.** To turn the asking back on, say so — it is one line in `~/.claude/settings.json`, and the agent will change it for you.

**It can see and change things in your home folder.** Not just one project. That is what makes it useful and it is worth knowing.

## Taking it off again

Ask the agent to remove it, or run `sh ~/projects/mwk-genie/uninstall.sh` yourself. It removes everything it put there and asks before touching anything that is yours. **Your key goes to the trash, not the bin**, and your work in `~/projects` is not touched at all. `--dry-run` says what would go without touching anything.

## Keys

Never put an API key in a file or in the chat. `mwk add NAME` stores one, encrypted, in `~/projects/keys`, a repo of its own. Each one is committed, and pushed to your private copy on GitHub once `/mwk-onboard` has made you one, so the store outlives the laptop. `mwk run -- <command>` hands the values to that one command and they vanish with it.

The first time you add a key, one is made for you at `~/.config/sops/age/keys.txt`. **Copy the line that starts `AGE-SECRET-KEY` into your password manager, once.** It is the only way into `~/projects/keys` — on this computer, and on the next one.

The agent cannot type a key and will not ask you to give it one. When something genuinely needs your keyboard it says so in the chat, and you run it in a second tab.

## No package manager

No Homebrew, no apt. Every tool is a pinned binary from its own project, fetched by `mise` from one list ([`mise.toml`](mise.toml)), identical on macOS, Ubuntu and WSL. On a Mac it also installs Apple's Command Line Tools, because you will want git before long.

## Working on the kit itself

[`CLAUDE.md`](CLAUDE.md) is the notes for whoever changes this repo — the reasoning, and the things that will bite you. [`test/`](test/) says what is checked automatically and what still needs a human.

Something broken? `/mwk-bug` writes the report for you, or [open one here](https://github.com/promptityourself/piy-genie/issues/new/choose).
