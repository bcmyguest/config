---
name: handoff
description: Write a concise handoff summary of the current troubleshooting/debugging activity so the next agent (or a future session) can continue without re-deriving anything. Use whenever the user invokes /handoff, says "summarize where we are", "write this up for the next agent/session", "capture the current state before we stop", or when a long troubleshooting session is winding down with the problem unsolved. Also use before context runs out on a gnarly multi-step investigation.
---

# Troubleshooting handoff

Produce a snapshot of the investigation **as it stands right now** — not a chronicle of
the session. The reader is an agent (or the user, weeks later) with zero context: no
session shorthand, no "the file from earlier", no codenames. Every line must be true at
the moment of writing; the most damaging thing a handoff can contain is a stale "fact"
that was disproven an hour ago, because the next agent will trust it.

## Process

1. **Prune first.** Go through what's known and discard everything superseded: fixed
   symptoms, disproven hypotheses (these move to *Ruled out*, one line each), abandoned
   approaches, environment details that changed (kernel was upgraded, package was
   removed, ...). If you're not sure a fact still holds and it's cheap to re-verify
   (a version check, a curl, an `ls`), verify it now rather than hedging in the doc.
2. **Write the doc** using the template below. Save to
   `~/.claude/handoffs/<topic-slug>-<YYYY-MM-DD>.md` (create the directory if needed).
   If a handoff for the same topic already exists, **update it in place** (keep the
   filename) instead of accumulating versions — same pruning rule applies.
3. **Show the full doc in your reply** — the file is for the next agent, the reply is
   for the user to sanity-check. They'll correct anything you got wrong; apply corrections
   to the file.
4. If the investigation will span days, add a one-line pointer in the memory index
   (`MEMORY.md`) so future sessions find it.

## Template

```markdown
# Handoff: <topic> (<YYYY-MM-DD>)

**Goal:** <what the user is ultimately trying to achieve — the end state, not the current sub-task>

**Status:** <2-4 sentences: where things stand right now and what the single next action is>

## Confirmed facts
<bullets; each fact carries how it was verified, with exact paths/versions/commands.
Only things re-checked or rock-solid. Dates absolute, never "today".>

## Ruled out
<one line each: hypothesis → what disproved it. This is what saves the next agent hours.>

## Blockers / waiting on
<upstream issues, hardware constraints, things on /watchlist — with links/ids>

## Next steps
<ordered, concrete, starting with the single best next action>

## Repro / key commands
<exact commands with expected good and bad output; include timeouts for anything that hangs>

## Constraints
<rules the next agent must follow, e.g.: sudo and system-state changes are user-run
only (print the command, ask them to use `!`); services that must not be restarted; etc.>
```

## Calibration

Brevity comes from pruning, not compression: short complete sentences, no arrow-chain
shorthand, no abbreviations the next agent would have to decode. A good handoff for a
day-long debug session fits in 40-60 lines. If a section is empty, delete it. The
*Ruled out* and *Constraints* sections earn their space even when short — they prevent
the two classic next-agent failures: re-testing dead hypotheses and "fixing" things by
restarting/reinstalling.
