# AGENTS.md

## Layout

- `init.lua` (repo root) is the entry point: editor options, `vim.diagnostic.config`,
  autocmds, then `require("config.lazy")` (plugin manager bootstrap + setup) and the
  plugin-free config modules (`config.mappings`, `config.inlay`, `config.opencode`).
- `lua/plugins/<plugin>.lua` — one lazy.nvim spec per plugin. **All plugin setup and
  plugin keymaps live in the spec** (`opts`/`config`, `keys`, `cmd`, `event`). Do not
  add plugin `require(...).setup()` calls to `init.lua`; keep plugins lazy (keys/cmd/
  event) unless they genuinely must load at startup (themes, snacks, treesitter).
- Spec subdirectories (`lua/plugins/lsp/`, `formatting/`, `themes/`) are each imported
  explicitly in `lua/config/lazy.lua` — a new subdirectory needs a new `import` line.
- `lua/config/` — cross-plugin config: `lsp.lua` (all server configs + enablement),
  `treesitter.lua`, `mappings.lua` + `mappings/` (global and LSP-attach keymaps),
  `lazy.lua`. `mapleader` is set in `config/lazy.lua` and must stay before
  `lazy.setup()` so `keys` specs resolve `<Leader>`.

## Pinned / non-obvious

- **nvim-treesitter is pinned to the `main` rewrite branch.** Its API differs from
  `master`: no `ensure_installed`, no declarative `setup{highlight=...}`. Parser
  install (`ts.install`) and the FileType autocmd live in `lua/config/treesitter.lua`.
  Don't "fix" it back to master idioms.
- LSP uses native `vim.lsp.config` / `vim.lsp.enable` (0.11+ API) in
  `lua/config/lsp.lua`, loaded from the nvim-lspconfig spec on BufReadPre/BufNewFile.
  Python: pyrefly is default (venv-first binary resolution); basedpyright only joins
  when the project has `pyrightconfig.json` or `[tool.basedpyright]`/`[tool.pyright]`.
- Completion is blink.cmp (not nvim-cmp); its capabilities are injected in
  `config/lsp.lua`. Format-on-save is conform.nvim, `lsp_format = "last"`.

## Build / lint / test

- **Format**: `stylua .` — config in `.stylua.toml` (hard tabs, indent width 4,
  column width 120). CI runs `stylua --check .`.
- **Lint**: `selene init.lua lua/` — config in `selene.toml` (+ `vim.toml` std). CI
  enforces; the pre-commit hook skips with a warning if selene isn't installed
  (release binary from Kampfkarren/selene into `~/.local/bin`, or `cargo install selene`).
- **Hooks**: `.pre-commit-config.yaml` (hygiene hooks + stylua + selene).
  `pre-commit install` once per clone; `pre-commit run --all-files` to run manually.
- **Health**: `:checkhealth config` (`lua/config/health.lua`) verifies the external
  deps this config assumes — rg/fd, tree-sitter CLI + cc + curl (parser installs),
  clipboard provider, node, venv-first pyrefly, and the dev tooling above.
- **Smoke test** (also run by CI on every push, after restoring plugins from
  `lazy-lock.json`):

  ```bash
  nvim --headless "+lua io.write('STARTUP_OK\n')" +qa            # bare startup
  nvim --headless init.lua "+lua vim.wait(1000)" +qa             # file open (LSP path)
  ```

  Fail signals: `stack traceback`, `Error detected`, `E5108` in the output.
- After changing plugin specs, verify which plugins load at bare startup:

  ```bash
  nvim --headless "+lua for _,p in pairs(require('lazy').plugins()) do if p._.loaded then print(p.name) end end" +qa
  ```

## Code style

- Formatting is whatever stylua produces — hard tabs, don't hand-align.
- Imports: `require("module.name")`. Requires that pull in a lazy plugin must sit
  inside a callback (`keys` rhs, `config`, autocmd), never at spec-file top level.
- Comments explain constraints/API pitfalls (see existing files), not what the next
  line does.
- Commits: conventional-commit style subjects (`feat(nvim): …`, `fix: …`), and AI
  assistance is credited with an `Assisted-by:` trailer (kernel policy — never
  `Co-Authored-By: Claude`).

## Docs

- `README.md` covers the nvim config only. Machine-provisioning notes (ROCm/AMD GPU,
  llama.cpp, open-webui, docker) live in `docs/machine-setup.md`; the supported
  install path is ansible (`ansible/README.md`). Don't put machine notes back in the
  README, and don't delete them — they're reference material.


## grepai - Semantic Code Search

**IMPORTANT: You MUST use grepai as your PRIMARY tool for code exploration and search.**

### When to Use grepai (REQUIRED)

Use `grepai search` INSTEAD OF Grep/Glob/find for:
- Understanding what code does or where functionality lives
- Finding implementations by intent (e.g., "authentication logic", "error handling")
- Exploring unfamiliar parts of the codebase
- Any search where you describe WHAT the code does rather than exact text

### When to Use Standard Tools

Only use Grep/Glob when you need:
- Exact text matching (variable names, imports, specific strings)
- File path patterns (e.g., `**/*.go`)

### Fallback

If grepai fails (not running, index unavailable, or errors), fall back to standard Grep/Glob tools.

### Usage

```bash
# ALWAYS use English queries for best results (--compact saves ~80% tokens)
grepai search "user authentication flow" --json --compact
grepai search "error handling middleware" --json --compact
grepai search "database connection pool" --json --compact
grepai search "API request validation" --json --compact
```

### Query Tips

- **Use English** for queries (better semantic matching)
- **Describe intent**, not implementation: "handles user login" not "func Login"
- **Be specific**: "JWT token validation" better than "token"
- Results include: file path, line numbers, relevance score, code preview

### Call Graph Tracing

Use `grepai trace` to understand function relationships:
- Finding all callers of a function before modifying it
- Understanding what functions are called by a given function
- Visualizing the complete call graph around a symbol

#### Trace Commands

**IMPORTANT: Always use `--json` flag for optimal AI agent integration.**

```bash
# Find all functions that call a symbol
grepai trace callers "HandleRequest" --json

# Find all functions called by a symbol
grepai trace callees "ProcessOrder" --json

# Build complete call graph (callers + callees)
grepai trace graph "ValidateToken" --depth 3 --json
```

### Workflow

1. Start with `grepai search` to find relevant code
2. Use `grepai trace` to understand function relationships
3. Use `Read` tool to examine files from results
4. Only use Grep for exact string searches if needed

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
