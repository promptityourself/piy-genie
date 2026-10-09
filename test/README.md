# Tests

```
bash test/check.sh          # seconds, no Docker. Files, renders, URLs.
bash test/rehearse.sh <sha> # minutes, Docker. The real install in a clean ubuntu:24.04.
```

And the third one, which is different in kind:

```
curl -fsSL https://raw.githubusercontent.com/promptityourself/piy-genie/<sha>/test/on-this-machine.sh \
  | PIY_REF=<sha> sh
```

⚠ **`on-this-machine.sh` installs on the machine you run it on.** Nothing is mocked, and it
finishes by uninstalling and reinstalling — so the machine is left set up, not clean. It is the
only way to test the Mac path, since the other two are Linux and a Linux container.

**Pass a SHA rather than a branch to any of them.** `PIY_REF` defaults to `main`. That used
to 404 outright, because `install.sh` did not exist there until v2 merged; it has been a 200
since 2026-09-17 and `check.sh` curls it now. The reason to pass a SHA is the next paragraph,
which is the one that actually bites.

**Pass a commit SHA to `rehearse.sh` right after a push**, not a branch name —
`raw.githubusercontent.com` serves a stale copy of a branch path for a few minutes, and
that has already cost two runs where the fix was in and the test was reading the old file.

`MANUAL.md` is the short list of what needs a browser, a login, or a person.

## The rule both scripts are written under

**When a check goes green, ask what would have to be true for it to go red.** If you cannot
construct that case, the check is decoration. v1's suite had three green ticks counting
nothing — a grep for a quoted string that never appears, a glob matching no directories,
and a `$()` that yielded `""` on a traceback and compared equal to `""`.

And: **a test that arranges its own preconditions is worse than no test.** `rehearse.sh`
pre-places nothing. If you find yourself adding a step to make it pass, the bug is in the
thing being tested.

## What is not covered, and cannot be

- **macOS.** `check.sh` is written to run under macOS's bash 3.2 and BSD tools, and
  `on-this-machine.sh` runs it there — but neither has run on a real Mac yet. The Mac install
  path (iTerm2, no `timeout`, no pinentry) has no other coverage.
- **The browser half.** Signing in, a paid plan, whether prompt one reads well to someone
  who has never done this.
- **Whether the agent behaves.** The scripts check what lands on disk. They cannot check
  that Claude reads the installer before running it, which is the guardrail prompt two is
  built around.
