---
name: git-attribution
description: How to attribute AI assistance in git commits, following the Linux kernel coding-assistants policy. Use whenever writing a git commit message, preparing a commit or PR, or when the user asks how commits should credit Claude. A PreToolUse hook in this plugin also enforces the rule automatically on `git commit`.
---

# Git commit attribution (kernel policy)

Follow <https://docs.kernel.org/process/coding-assistants.html#attribution> on every
commit, in any repo on this machine.

## The rule

- Credit AI assistance with an **`Assisted-by:`** trailer:

  ```
  Assisted-by: Claude:claude-fable-5
  ```

  Format is `Assisted-by: AGENT_NAME:MODEL_VERSION [extra-analysis-tools]`. Append
  specialized analysis tools only if actually used (e.g. `coccinelle`, `sparse`,
  `smatch`, `clang-tidy`). Update the model version to whichever model you actually
  are.

- **Never add `Signed-off-by:` as the AI.** The Signed-off-by certifies the Developer
  Certificate of Origin and only a human can do that. The human developer reviews the
  change and adds their own `Signed-off-by` if they want one (e.g. `git commit -s`).

- **Never add `Co-Authored-By: Claude`.** That older convention is replaced by
  `Assisted-by:` here.

- Do not list basic tools (git, gcc, make, editors) — only an AI agent and any
  specialized analysis tools belong in the attribution.

## Why

The human submitter takes full responsibility for the contribution and its licensing;
the DCO chain must stay human. `Assisted-by:` records the assistance transparently
without implying the AI can certify provenance.

## Enforcement

This plugin ships a PreToolUse hook (`scripts/attribution-guard.py`) that inspects
`git commit` commands and blocks any that author a message without an `Assisted-by:`
trailer, or that try to add an AI `Signed-off-by` / `Co-Authored-By: Claude`. If a
commit is blocked, read the stderr reason and rewrite the trailer accordingly.
