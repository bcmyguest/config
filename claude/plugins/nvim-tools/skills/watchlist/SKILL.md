---
name: watchlist
description: Check upstream GitHub issues, PRs, and releases the user is waiting on, and report what moved since the last check. Use whenever the user invokes /watchlist, asks "any movement on that PR/issue", "check the watchlist", "are we still waiting on X", "has that llama.cpp/ollama/lemonade thing landed yet", or asks to start watching / stop watching an upstream issue, PR, or release. Also use when the user says "remind me to check back on this issue" or "add this to the things we're waiting on".
---

# Watchlist

Track upstream work the user is blocked on (issues, PRs, releases) and report movement.
The state lives in `~/.claude/watchlist.json`. Each entry records why the user cares and
what "resolved" looks like — read those fields before reporting, because raw GitHub state
(open/closed) is often not the real question. Example: a PR may merge but only add CLI
support, while the user is waiting for *server* support.

## Subcommands

Parse the argument string:

- *(no args or "check")* — check every item, report changes, update stored state.
- `add <github url or owner/repo#123> [note about why]` — fetch current state, ask
  nothing, infer `waiting_for` from the note/conversation, append to the JSON.
- `remove <id or fragment>` — delete the matching entry (confirm if ambiguous).
- `list` — print the table from stored data without hitting the network.

## How to check

Use the GitHub REST API unauthenticated via curl (rate limit 60/hr is plenty; fall back
to `gh api` if curl gets 403-rate-limited and gh is authenticated):

```bash
# issues AND pull requests both work through the issues endpoint:
curl -s -m 15 https://api.github.com/repos/{owner}/{repo}/issues/{number}
# extra PR detail (draft, merged_at) lives under .pull_request or:
curl -s -m 15 https://api.github.com/repos/{owner}/{repo}/pulls/{number}
# releases:
curl -s -m 15 https://api.github.com/repos/{owner}/{repo}/releases/latest
```

Check all items in one Bash call (a small inline loop) rather than one call per item.

An item "moved" when, vs. the entry's `last_state`: `state` changed, `merged_at` became
non-null, `draft` flipped, `comments` count grew, `updated_at` advanced, or (releases) the
tag changed. When an item moved, fetch the most recent comments and skim for whether the
movement is *relevant to* `waiting_for` — that's the judgment call this skill exists for:

```bash
curl -s -m 15 "https://api.github.com/repos/{owner}/{repo}/issues/{number}/comments?per_page=5&sort=created&direction=desc"
```

After checking, rewrite the JSON with the fresh state and `last_checked` (ISO date).

## Report format

Lead with the verdict, not the data: "Still waiting on both" / "Movement: ...".
Then one line per item: **name — status vs. what we're waiting for** (e.g. "PR open,
draft, 51→57 comments; latest discussion is about Metal perf, still no server support").
If something *resolved*, say what the user can now do (e.g. "merged — next step is a
lemonade pinned-build update; want me to check lemonade releases?").
If nothing moved at all, one sentence is enough.

## Entry schema (watchlist.json)

```json
{
  "items": [
    {
      "id": "short-slug",
      "type": "pr | issue | release",
      "repo": "owner/repo",
      "number": 24423,
      "url": "https://github.com/...",
      "why": "one line: what this blocks for the user",
      "waiting_for": "the actual resolution criterion, not just 'closed'",
      "added": "2026-06-12",
      "last_checked": "2026-06-12",
      "last_state": {"state": "open", "draft": true, "merged_at": null, "comments": 51, "updated_at": "..."}
    }
  ]
}
```

For `type: release`, `last_state` is `{"tag": "...", "published_at": "..."}` instead.
