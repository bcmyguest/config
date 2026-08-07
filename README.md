# nvim config

Neovim 0.12 configuration. Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim)
and load lazily (keys/cmd/event triggers); a bare `nvim` start loads only the
colorscheme, treesitter, snacks, and the opencode/puppeteer integrations.

## Installing

Install nvim and its toolchain with [ansible](./ansible/README.md) (`nvim.yml`), or manually.
The AI inference stack (docker, llama.cpp, lemond, Open WebUI) is separate — see
`ai-inference.yml` in the same ansible setup. Old manual notes: [docs/machine-setup.md](./docs/machine-setup.md).

## Structure

```
├── init.lua              # options, diagnostics config, autocmds; requires config.*
├── lazy-lock.json        # lazy.nvim lockfile (like package-lock.json)
├── lua
│   ├── config            # cross-plugin config: lazy bootstrap, lsp, treesitter, mappings
│   └── plugins           # one lazy.nvim spec per plugin (setup + keymaps live here)
│       ├── lsp/          # mason, blink.cmp, lazydev, schemastore
│       ├── formatting/   # conform, autopairs, guess-indent, indent-blankline, puppeteer
│       └── themes/       # tokyonight (active), catppuccin
├── .github/workflows     # CI: stylua --check, headless startup smoke test
└── ansible               # machine provisioning (editor toolchain + AI stack)
```

Conventions:

- A plugin's entire setup — `opts`/`config` **and its keymaps** (`keys`) — lives in its
  spec under `lua/plugins/`. Nothing plugin-related is required from `init.lua`.
- `lua/config/` holds what spans plugins: `lsp.lua` (server configs + enablement),
  `treesitter.lua`, `mappings*.lua` (plugin-free global maps), `lazy.lua` (bootstrap).
- New spec subdirectories must be imported in [lua/config/lazy.lua](./lua/config/lazy.lua).

## Plugins

lazy.nvim installs itself and all plugins on first `nvim` run. Manage with `:Lazy`
(install/update/restore). `lazy-lock.json` pins versions; CI restores from it.

nvim-treesitter is pinned to the `main` rewrite branch — it has a different API than
`master` (no `ensure_installed`/declarative setup). Parser install + per-buffer
highlighting live in [lua/config/treesitter.lua](./lua/config/treesitter.lua).

## LSP

Language servers are installed by Mason (`:Mason`) and configured in
[lua/config/lsp.lua](./lua/config/lsp.lua) via the native `vim.lsp.config` /
`vim.lsp.enable` API (Neovim 0.11+). The whole stack loads on the first real buffer.

Python has two type checkers wired up:

- **pyrefly** is the default — enabled whenever its binary resolves (project venv
  first, then PATH). If missing you get a one-time warning.
- **basedpyright** runs additionally only when the project opts in
  (`pyrightconfig.json`, or `[tool.basedpyright]`/`[tool.pyright]` in `pyproject.toml`).

Formatting on save is owned by conform.nvim (`lua/plugins/formatting/conform.lua`),
running trim_whitespace then the attached LSP formatter.

## Keymaps

`<Space>` is the leader. Global plugin-free maps:
[lua/config/mappings.lua](./lua/config/mappings.lua) + `lua/config/mappings/misc.lua`.
LSP buffer-local maps (applied on attach): `lua/config/mappings/lsp.lua`.
Plugin maps live in each plugin's spec (`keys = …`) — telescope under `<Space>f…`,
dap under `<Space>d…`, diffview under `<Space>g…`, trouble under `<Space>x…`.
Search all of them with `<Space>gl` (`:Telescope keymaps`).

## Colorscheme

tokyonight is the active colorscheme ([lua/plugins/themes/tokyotonight.lua](./lua/plugins/themes/tokyotonight.lua));
catppuccin is installed and configured as an alternate
([lua/plugins/themes/catpuccin.lua](./lua/plugins/themes/catpuccin.lua)).

## Development

- Format: `stylua .` (config in [.stylua.toml](./.stylua.toml) — hard tabs).
- Hooks: `pre-commit install` once; hygiene hooks + stylua run per commit.
- CI ([.github/workflows/ci.yml](./.github/workflows/ci.yml)) checks formatting and
  boots nvim headless (plugin restore from the lockfile, bare startup, file open) so a
  broken config fails the build instead of the next editing session.
- Quick local smoke test:

  ```bash
  nvim --headless "+lua io.write('STARTUP_OK\n')" +qa
  ```

Note: if wifi performance is an issue, consider editing NetworkManager's wifi.powersave setting.
