#!/usr/bin/env python3
"""PreToolUse guard: enforce Linux-kernel AI attribution on git commits.

Reads the PreToolUse hook payload on stdin. If the Bash command creates a
commit message, require an `Assisted-by:` trailer and forbid the AI adding a
`Signed-off-by:` (DCO is human-only) or the old `Co-Authored-By: Claude` line.
Blocks by exiting 2 with the reason on stderr, which Claude Code feeds back to
the model so it can rewrite the commit.

Ref: https://docs.kernel.org/process/coding-assistants.html#attribution
"""
import json
import re
import sys


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0  # never block on a parse failure

    cmd = (payload.get("tool_input") or {}).get("command", "")
    if "git commit" not in cmd:
        return 0

    # Commits that don't author a new message (no -m / -F / -C and not amending
    # the message) carry no message to check.
    creates_message = bool(re.search(r"-m\b|--message|-F\b|--file|-C\b|--reuse-message", cmd))
    amends = "--amend" in cmd and "--no-edit" not in cmd
    if not (creates_message or amends):
        return 0

    problems = []
    if "Assisted-by:" not in cmd:
        problems.append(
            "missing `Assisted-by: Claude:claude-fable-5` trailer"
        )
    if re.search(r"Co-Authored-By:\s*Claude", cmd, re.IGNORECASE):
        problems.append(
            "remove the `Co-Authored-By: Claude` line — kernel policy uses "
            "`Assisted-by:` instead"
        )
    if re.search(r"Signed-off-by:.*(claude|anthropic)", cmd, re.IGNORECASE):
        problems.append(
            "AI must NOT add a Signed-off-by line — only the human developer "
            "can certify the DCO"
        )

    if problems:
        sys.stderr.write(
            "Commit blocked by git-attribution guard (kernel attribution policy):\n"
            + "\n".join(f"  - {p}" for p in problems)
            + "\n\nUse a trailer like:\n  Assisted-by: Claude:claude-fable-5\n"
            "and let the human add their own Signed-off-by if they want one.\n"
        )
        return 2

    return 0


if __name__ == "__main__":
    sys.exit(main())
