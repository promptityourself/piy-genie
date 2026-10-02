---
name: piy-tasks
description: What is open across all their projects, in one list — every GitHub issue on every repo of theirs, and anything one project has asked of another — with a suggested next step for each, decided in one reply. Use when they ask what is outstanding, what they should do next, what is waiting on them, or want to look across everything rather than one folder.
argument-hint: "[a project name, to look at just that one]"
---

<!-- requires: gh git -->

They want to see what is open, across everything, without visiting each project.
**Gather it all, show ONE list, suggest a next step for each, and take their
decisions in a single reply.** Do not walk them through issues one at a time.

The argument, if there is one, narrows it to a single project: `$ARGUMENTS`

## 1. Gather

`gh repo list --json name,nameWithOwner --limit 100` — every repo of theirs. If
that fails, say so in one line ("GitHub is not signed in on this computer") and
stop; there is nothing to gather.

For each repo (or just the named one), the open issues:
`gh issue list -R <owner/name> --state open --limit 50 --json number,title,body,createdAt,comments`.

Also read every `TODO.md` under `~/projects/*/` — those are the notes `/piy-save`
leaves, and for someone who works mostly in the chat they are more of the truth
than the issue list is.

## 2. Anything one project asked of another

A project can leave a request for another one by opening an issue in that other
repo whose body starts `**From:** <project-name>`, and every comment or closure on
such an issue is signed `— <project-name>`. That is the whole convention, and it is
the same one `/td-fly:mailbox` runs on for the people who made this kit. Show these
separately, both ways: what *this* project has asked of others, and what others have
asked of *this* one. If none exist, say nothing about it — a heading with nothing
under it is a question they cannot answer.

**Small projects are the point.** Someone with six small folders and this list knows
more about where they are than someone with one big folder and a memory. When a
project's `TODO.md` is really three projects, say so — `/piy-new` is cheap.

## 3. The list

One table, newest first, in their words. Columns: project · what it is · how
long it has been open · **suggested next step**. Keep every row to one line.

The suggestion is the point. For each item, one of:

- **do it now** — small, and you can do it in this session. Say what you would do.
- **it looks done** — a save point in that project plainly finished it. Say which.
- **needs them** — a decision only they can make, or something only they can do.
  Say what, in one line.
- **let it go** — it has been open long enough that it is probably not a thing
  any more. Ask, never assume.

Group by project. Skip any project with nothing open.

## 4. Take the decisions

End with the numbered items that need an answer, one line each, and take the
answers in a single reply. For anything they say yes to: closing an issue is
`gh issue close <n> -R <owner/name> --comment "<one plain line>"`, and doing a
small thing is doing it — then `/piy-save` in that project.

Never close anything because it is old, and never open new issues from here.
Things worth tracking go in that project's `TODO.md`.
