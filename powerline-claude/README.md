# powerline-claude

A powerline-style status line for [Claude Code](https://code.claude.com), as a
single Rust binary. Reads the statusline JSON Claude Code writes to stdin,
prints an ANSI bar. No starship, no jq, no subprocesses on the hot path.

Successor to the vendored [starship-claude](https://github.com/martinemde/starship-claude)
setup (`ansible/roles/starship-claude`), rewritten from scratch with a
[powerline-go](https://github.com/justjanne/powerline-go)-style interface.

## Usage

`~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "padding": 0,
    "command": "~/.local/bin/powerline-claude"
  }
}
```

Flags go on that command string:

| Flag | Default | Meaning |
|------|---------|---------|
| `--modules` | `logo,dir,git,model,context,cost,stats,effort` | Segments to render, in order |
| `--theme` | `catppuccin-mocha` | Also: `catppuccin-frappe`, `dracula`, `gruvbox-dark`, `nord`, `tokyonight` |
| `--mode` | `patched` | `patched` (nerd-font separators), `compatible` (plain Unicode), `flat` (none) |
| `--no-progress` | off | Suppress the OSC 9;4 terminal progress bar |
| `--width` | `$COLUMNS`, then parent TTY, then 200 | Terminal width (drives dir truncation) |

## Segments

- `logo` — Claude glyph
- `dir` — workspace dir, last two path components (one below 80 columns)
- `git` — current branch (read from `.git/HEAD`, worktree-aware) plus the
  session's `+added -removed` line counts from the payload
- `model` — nerd icon + lowercased model name
- `context` — exact tokens in the context window (`150,697 tok`), `~~ tok`
  before the first API call
- `cost` — session cost, `$X.XX`
- `stats` — session duration (`1h 12m`)
- `effort` — reasoning effort level; hidden when the model doesn't support it

Segments whose data is absent from the payload disappear rather than render
placeholders (except `context`, which shows `~~` like the old bar did).

The OSC 9;4 progress bar mirrors context usage: green below 40%, yellow to
60%, red above, full at the 80% compact threshold.

## Development

```bash
cargo test          # the suite: unit + fixture-driven integration tests
cargo clippy --all-targets -- -D warnings
cargo fmt
cargo build --release
```

Rendering is pure (`powerline_claude::run`: JSON in, ANSI out), so everything
is testable without a terminal; fixtures live in `tests/fixtures/`.

## Releasing

CI (`.github/workflows/powerline-claude-release.yml`) builds a static
`x86_64-unknown-linux-musl` binary and publishes a GitHub release when you
push a tag:

```bash
git tag powerline-claude-v0.1.0 && git push origin powerline-claude-v0.1.0
```

Provisioning (`ansible/roles/powerline-claude`) downloads the latest release
asset to `~/.local/bin/powerline-claude`, falling back to `cargo install
--path` from this checkout when no release is reachable, points the
`statusLine` key in `~/.claude/settings.json` here, registers this repo as a
plugin marketplace, and removes the artifacts the retired starship-claude
role installed.

## Plugin

`plugin/` is a small Claude Code plugin (registered via the repo-root
`.claude-plugin/marketplace.json`) providing `/powerline-claude:configure`:
an interactive way to pick a theme, choose and order segments, or change the
separator mode — it previews candidates by piping a sample payload through
the binary, then rewrites the `statusLine.command` flags.

## License

AGPL-3.0-only.
