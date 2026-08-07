# Refactor: centralise all keymaps in `lua/config/mappings.lua`

## Current problem

Keymaps are scattered across 20+ plugin spec files. Each plugin's `keys` block is
a few lines in a spec that's already doing other things (opts, config, dependencies).
There's no single file that shows all bindings, no declared ownership of `<leader>`
prefix ranges (which resolve by alphabetical file order), and no way to see which
commands collide before adding a new plugin.

## Goal

All user-facing keymaps live in one file. Plugin specs own zero `keys` blocks — only
`cmd` or `event` for lazy loading. The mappings file is structured as a single table
keyed by `<leader>` prefix range, with each section ordered consistently.

## Rules

1. **Specs drop `keys`** — every plugin spec in `lua/plugins/*.lua` and `lua/plugins/lsp/*.lua`
   must remove its `keys` block. Lazy-loading is preserved *without adding new triggers*:
   - Plugins that already have `cmd`/`event` keep them (telescope, trouble, claudecode,
     diffview, persistence, which-key). Their `<cmd>...>` keymaps fire the command, which
     triggers the load.
   - dap has no `cmd`/`event` and needs none: its keymap bodies call `require("dap")`,
     and lazy.nvim's require-hook loads the plugin on first press. Do **not** add an
     artificial `event`/`cmd` to dap — that would make it load eagerly (a regression).

2. **Keymaps move to `lua/config/mappings.lua`** — single source of truth for all keybindings.
   Loaded from `init.lua` after `config.lazy`, so every plugin with a trigger is available.

3. **Structure by prefix range** — top-level comment sections, one per `<leader>` range:

   ```
   -- Finders:  <leader>f
   -- Git:      <leader>g
   -- Dap:      <leader>d
   -- LSP:      <leader>l  (already handled by mappings/lsp.lua; don't duplicate)
   -- Diagnostics: <leader>x
   -- Claude:   <leader>a
   -- Sessions: <leader>q[sp]
   -- Explorer: <leader>t
   -- Other:    <leader>? (which-key), <leader>gl (telescope keymaps)
   ```

4. **Use `vim.keymap.set`** — consistent with `mappings/lsp.lua`. Group by mode (`n`, `v`, `t`)
   and use `{ desc = "..." }` for which-key.

5. **Keep function bodies inline** — non-LSP keymaps reference their require calls directly:
   `function() require("dap").continue() end`. No helper files. (Telescope's `builtin(name)`
   wrapper is trivial and may stay as a local helper in `mappings.lua`.)

6. **Two things are NOT flat global keymaps — handle explicitly:**
   - **`<leader>a` group label** (`{ "<leader>a", nil, desc = "AI/Claude Code" }`) is a
     which-key *group*, not a keymap. Register it in `which-key.lua` via
     `opts.spec = { { "<leader>a", group = "AI/Claude Code" } }`. This is which-key config,
     not a `keys` block, so it does not violate rule 1.
   - **ft-local `<leader>as`** ("Add file", `ft = { neo-tree, oil, minifiles, netrw,
     snacks_picker_list }`) is a buffer-local `n`-mode map. The global `<leader>as` is the
     `v`-mode "Send to Claude" — different modes, no conflict. Replicate the ft-local one in
     `mappings.lua` with a single `FileType` autocmd setting a buffer-local map. This is the
     one allowed autocmd in the file.

## Plugins to touch — remove `keys` from these:

| File | Keymaps to extract |
|------|--------------------|
| `lua/plugins/dap.lua` | All `keys` entries (dc, F5, do, di, b, B, dw, dr, lp, dt, dl, dh, dp, df, dS) |
| `lua/plugins/telescope.lua` | All `keys` entries (ff … fn) |
| `lua/plugins/persistence.lua` | All `keys` entries (qs, ql, qd) |
| `lua/plugins/trouble.lua` | All `keys` entries (xx, xX, xs, xl, xL, xQ) |
| `lua/plugins/claudecode.lua` | All `keys` entries (`<M-,>`, ac, af, ar, aC, am, ab, as×2, aa, ad); move `<leader>a` group label to `opts.spec` |
| `lua/plugins/diffview.lua` | All `keys` entries (gd, gD, gh, gH) |
| `lua/plugins/which-key.lua` | `<leader>?` keymap (owns `<leader>?`); add `opts.spec` group for `<leader>a` |
| `lua/plugins/minuet.lua` | All `keys` entries (`<leader>mt`, `mm`, `mp`); `cmd = "Minuet"` keeps it lazy |

**Notes:**
- `figet.lua` is fidget.nvim (LSP notifications) and owns **no** keymaps — do not touch it.
  `<leader>?` is defined only in `which-key.lua`. There is no `<leader>?` collision.
- `snacks.lua` has a `keys =` table but it is a nested picker-window *config option*
  (`win.input.keys`), not a lazy `keys` trigger. Leave it untouched.
- A new `Minuet: <leader>m` prefix range is added to `mappings.lua`.

## Keymap reference (current trigger → destination desc)

| Trigger | Source | Destination desc |
|---------|--------|-----------------|
| `<leader>ff` | telescope | Find files |
| `<leader>fg` | telescope | Find git files |
| `<leader>fc` | telescope | Find git commits |
| `<leader>fs` | telescope | Grep current string |
| `<leader>fw` | telescope | Live grep |
| `<leader>fh` | telescope | Help tags |
| `<leader>fb` | telescope | Find buffers |
| `<leader>fo` | telescope | Find old files |
| `<leader>fu` | telescope | LSP references |
| `<leader>gl` | telescope | Find keymaps |
| `<leader>fn` | telescope | Find nearby files |
| `<leader>gd` | diffview | Diffview: open (working tree) |
| `<leader>gD` | diffview | Diffview: close |
| `<leader>gh` | diffview | Diffview: history (current file) |
| `<leader>gH` | diffview | Diffview: history (whole repo) |
| `<leader>dc` | dap | Run to cursor |
| `<F5>` | dap | Continue debugger |
| `<leader>do` | dap | Step over |
| `<leader>di` | dap | Step into |
| `<leader>b` | dap | Toggle breakpoint |
| `<leader>B` | dap | Toggle breakpoint |
| `<leader>dw` | dap | Eval word under cursor |
| `<leader>dr` | dap | Restart debugger |
| `<leader>lp` | dap | Log point |
| `<leader>dt` | dap | Open dap repl |
| `<leader>dl` | dap | Run last debug config |
| `<leader>dh` | dap | Debug hover |
| `<leader>dp` | dap | Debug preview |
| `<leader>df` | dap | Debug window float |
| `<leader>dS` | dap | Show debug scopes |
| `<leader>xx` | trouble | Trouble: diagnostics (workspace) |
| `<leader>xX` | trouble | Trouble: diagnostics (buffer) |
| `<leader>xs` | trouble | Trouble: symbols |
| `<leader>xl` | trouble | Trouble: LSP defs/refs |
| `<leader>xL` | trouble | Trouble: location list |
| `<leader>xQ` | trouble | Trouble: quickfix list |
| `<leader>qs` | persistence | Session: restore (this dir) |
| `<leader>ql` | persistence | Session: restore last |
| `<leader>qd` | persistence | Session: stop |
| `<leader>?` | which-key | Buffer Local Keymaps |
| `<M-,>` | claudecode | Toggle Claude (normal + terminal) |
| `<leader>ac` | claudecode | Toggle Claude |
| `<leader>af` | claudecode | Focus Claude |
| `<leader>ar` | claudecode | Resume Claude |
| `<leader>aC` | claudecode | Continue Claude |
| `<leader>am` | claudecode | Select Claude model |
| `<leader>ab` | claudecode | Add current buffer |
| `<leader>as` (v mode) | claudecode | Send to Claude |
| `<leader>as` (neo-tree/oil/etc) | claudecode | Add file |
| `<leader>aa` | claudecode | Accept diff |
| `<leader>ad` | claudecode | Deny diff |

## What stays unchanged

- `lua/config/mappings/lsp.lua` — LSP-specific mappings sourced by the `LspAttach` hook.
  Separated because it depends on `bufnr` context.
- `config = function()` blocks in specs (dap listener registration, telescope fzf extension,
  snacks opts, etc.) — these are config, not keymaps. They stay in specs.
- `cmd` triggers in specs — these keep plugins lazy before any keymap fires. Do not remove.

## What not to do

- Don't create a `mappings/` subdirectory — too few keymaps to warrant it.
- Don't extract helpers for keymap bodies — keep inline.
- Don't change existing `<leader>` prefix ranges — preserve <leader>fs convention.

## Verification

- **No `keys` blocks remain**: `grep -rn 'keys =' lua/plugins/` returns nothing. This is the
  objective pass/fail for "specs own zero keys blocks."
- `stylua .` passes.
- `nvim --headless "+q"` starts cleanly (no keymap errors).
- `:checkhealth config` passes.
- `which-key` shows all keys (and the `<leader>a` group label) properly after `VeryLazy`.
- No keymap overlaps between sections (verify grep for exact `<leader>` patterns).
- Update `mappings.lua`'s header comment — it currently says plugin keymaps live in their
  lazy specs, which becomes false after this refactor.
