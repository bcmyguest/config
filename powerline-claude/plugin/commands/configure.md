---
description: Configure the powerline-claude status line (theme, modules, separator mode)
---

Reconfigure the powerline-claude Claude Code status line. The binary lives at
`~/.local/bin/powerline-claude`; its flags are the whole configuration surface
and they live on the `statusLine.command` string in `~/.claude/settings.json`.

User request (may be empty): $ARGUMENTS

Steps:

1. Verify `~/.local/bin/powerline-claude --help` runs; if the binary is
   missing, tell the user to provision it (`ansible-playbook ansible/nvim.yml
   --tags powerline-claude` from the config repo) and stop.
2. Read the current `statusLine` entry from `~/.claude/settings.json` and show
   the user their current flags.
3. Ask what they want to change (unless $ARGUMENTS already says), offering:
   - `--theme`: catppuccin-mocha (default), catppuccin-frappe, dracula,
     gruvbox-dark, nord, tokyonight
   - `--modules`: any order/subset of logo,dir,git,model,context,cost,stats,effort
   - `--mode`: patched (nerd font), compatible (plain Unicode), flat
   - `--no-progress`: disable the terminal progress bar
4. To preview a candidate configuration, pipe a sample payload through the
   binary and show the raw output (the user's terminal renders the ANSI):

   ```bash
   echo '{"workspace":{"current_dir":"'"$PWD"'"},"model":{"display_name":"Opus 4.8"},"cost":{"total_cost_usd":0.71,"total_duration_ms":4335000,"total_lines_added":156,"total_lines_removed":23},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":8500,"output_tokens":1200,"cache_creation_input_tokens":5000,"cache_read_input_tokens":2000}},"effort":{"level":"high"}}' \
     | ~/.local/bin/powerline-claude --no-progress --theme <candidate> --modules <candidate>
   ```

5. Apply by updating only `statusLine.command` in `~/.claude/settings.json`
   (preserve every other key — read, merge, write back). Omit flags that match
   the defaults to keep the command string short.
6. Remind the user the change shows up on the next status line refresh, and
   that provisioning won't clobber it unless the ansible vars change.
