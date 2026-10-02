# How to work with your genie

**This is your page — bookmark it.** Underneath this text is every page your genie writes for
you, one folder per project, newest at the bottom of each. The words you are reading are a
file, `~/piy-work/README.md`, and it is yours: if anything here is wrong, tell the genie and it
fixes the file.

## Starting it

Open a terminal window and type:

```
claude
```

It starts wherever you are standing, which is why *knowing where you are* matters below.

On Windows, "the terminal" means the **Ubuntu** window — open Ubuntu from the Start menu, not
the terminal that opens by default. If what you are looking at starts with `PS C:\` you are
in PowerShell, where none of this exists.

## Typing a second line

Hold **Ctrl** and press **J**. That starts a new line instead of sending. It works in every
terminal (Shift+Enter does too in most of them, but not Apple's).

## Knowing where you are

Your prompt — the bit before you type — tells you:

```
holiday-photos main* ›
```

- `holiday-photos` — the folder you are in.
- `main` — this folder is keeping saved versions of your work.
- `*` — you have work that is not saved yet. When the star is gone, everything is safe.

Three commands are the only ones worth learning: `cd holiday-photos` goes into a folder
(`cd ..` goes back up one), `ls` shows what is in this one, `mkdir notes` makes a new one.
So to open a project you already have:

```
cd ~/projects/holiday-photos
claude
```

## Finding your folders in a normal window

Two folders are yours: `~/projects` (your projects) and `~/piy-work` (the pages behind this
one). Ask the genie to **put a shortcut to each on your Desktop** — once — and you never need
the terminal to reach them again.

- **Mac:** `open ~/projects` opens it in Finder.
- **Windows:** your folders live inside Ubuntu, so File Explorer will not find them by
  looking. From the folder you are in, `explorer.exe .` opens it as a normal Windows
  window you can drag files into; `\\wsl$` typed into Explorer's address bar shows all of
  it. Keep your work there rather than moving it onto `C:` — it is much slower from
  Ubuntu's side, and it is not where the genie will look for it.

## Every project has the same shape

```
~/projects/holiday-photos/
    README.md      one line: what this is for
    input/         drop things in here — a PDF, a photo, a spreadsheet
    archive/       where things from input/ go once they have been dealt with, by date
    TODO.md        the note the genie leaves you at the end of each session
```

## The things it does for you

You can type these, or just say them in normal words. Both work.

| say | or type | what happens |
|---|---|---|
| "I wish my computer could…" | `/piy-wish` | it finds what already does that, writes you one page of options, and builds the first version today |
| "connect my accounts" | `/piy-onboard` | GitHub, Cloudflare and Replicate — set up, keys stored, each one proved to answer |
| "start me a new project" | `/piy-new` | a folder with the shape above, saving turned on, a private copy on GitHub |
| "save my work" | `/piy-save` | says what changed, writes the note for next time, saves, pushes, tidies up |
| "what did I learn today" | `/piy-learn` | adds today to `~/projects/learning` — your running record |
| "how are we doing" | `/piy-review` | steps back and says whether this has wandered off, or got too complicated |
| "what's outstanding" | `/piy-tasks` | everything open across all your projects, with a suggested next step each |
| "report this bug" | `/piy-bug` | writes a report about the genie itself, shows you, files it only if you say yes |

## The pages under this one

When the genie has something longer than a screen to tell you — a plan, a choice between
options, a comparison, a report — it writes a page rather than filling the chat, and gives you
the link. They all land here, under the project they belong to, under the day they were
written. They are files in `~/piy-work`, saved and pushed like your projects, so they are still
here in a year.

## Your keys

An API key — the password a service gives you so a program can use it — never goes in a
file and never goes in the chat. In a **second** terminal tab:

```
piy add OPENAI_API_KEY
```

It asks you to paste the value and shows nothing while you do. Because nothing appears,
people press Enter to check — that is fine, it does not break anything.

The key is stored encrypted in `~/projects/keys`, and `piy run -- <something>` hands it to
that one program for that one run. After it saves, it tells you in one line where the copy
went: on this computer only, or to your private repo on GitHub as well. If it says this
computer only, say *"put my keys on GitHub"* and it is done in a minute.

**The first time you do this it makes you a key of your own** and tells you to copy one
line — it starts `AGE-SECRET-KEY` — into your password manager, as an entry called **piy
key**. **Do that, once.** It is the only way into your keys, on this computer and on the next
one, and nobody can make it again.

## Starting a fresh conversation

```
/clear
```

It forgets the conversation, not your work. Your files and saved versions stay exactly
where they are. Do it whenever you start something different, or when the bar at the bottom
says it is getting full — a fresh conversation is faster and sharper than a long one.

## The bar at the bottom

`Opus · ~/projects/holiday-photos · 34% full` — which model you are talking to, which
folder, and how full its memory is. Past about 70% it turns red, and that is your cue to
`/clear`. If the bar is not there, ask the genie why.

```
/model sonnet
```

Opus is the stronger one and what you are on unless you changed it. Sonnet is faster and
your plan stretches much further on it — reach for it when the job is straightforward.
It switches for this conversation only; `/model opus` puts it back.

## Two things that will scare you

**Typing your computer password shows nothing.** No dots, no stars, nothing moves. It is
working. Type it and press Enter. Do not type it again. On Windows it is not your Windows
password — it is the Ubuntu one you made the first time you opened Ubuntu.

**It does not ask before each command, and it can see and change anything in your home
folder** — not just one project. Anthropic's own safety check looks at each action in the
background and stops anything that does not fit what you asked for, but the reach is real,
and it is the trade that makes this a your-own-computer thing and **not a work one**. To
change your mind about the asking, say: *"ask me before every command from now on"* — it is
one line in a settings file, and the genie changes it.

## Changing how it behaves

```
~/.claude/CLAUDE.md
```

Written in plain English, and yours. If something it does annoys you, change the line and
it does it differently from then on. No settings screen, no support ticket. Or say: *"add a
rule to my CLAUDE.md that…"* and it does it for you.

## When something goes wrong

- **Paste the error back to it.** Copy whatever red text you got, paste it in, let it work
  it out. This is the single most useful habit you can have.
- **Take a screenshot and paste that in.** It can see pictures.
- **Ask what a command does before you say yes.** That question is never annoying.
- **If this page will not open**, open a new terminal window — that starts it — and try
  again. If it still will not, tell the genie.
- **If it says you have reached your limit, nothing is broken and nothing is lost.** Every
  plan has a ceiling on how much you can use in a stretch, and a long build can reach it.
  It tells you when it comes back — usually a few hours. Your work is on your disk; type
  `claude` again after that and carry on where you were. This is the one message that
  looks like a fault and is not.
- **If the genie itself is broken**, say "report this bug".

## Where this came from

[Prompt It Yourself](https://promptityourself.com) — a show about sitting down with a complete
stranger for a few hours and building the thing they wished their computer did. Everything
you just set up is the box; the point is doing it together. Want to come on
[the show](https://promptityourself.com/show/)? You do not need to be any good at this — that is
the whole premise.
