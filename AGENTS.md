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
- **Hooks**: `.pre-commit-config.yaml` (hygiene hooks + stylua). `pre-commit install`
  once per clone; `pre-commit run --all-files` to run manually.
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
