vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.number = true -- absolute line number for the line you are on
vim.opt.relativenumber = false -- relative line numbers

-- Indentation fallback for buffers guess-indent.nvim can't sample (new/empty
-- files). Keeps hard tabs (expandtab unset) but renders them 4-wide, not the
-- native 8. guess-indent overrides expandtab/shiftwidth/tabstop per buffer.
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Editing creature comforts
vim.opt.undofile = true -- persistent undo across sessions
vim.opt.ignorecase = true -- case-insensitive search...
vim.opt.smartcase = true -- ...unless the query has uppercase
vim.opt.scrolloff = 8 -- keep context above/below the cursor
vim.opt.signcolumn = "yes" -- always show sign column (no gutter jitter)
vim.opt.splitright = true -- vertical splits open to the right
vim.opt.splitbelow = true -- horizontal splits open below
vim.opt.mouse = "a" -- mouse in all modes
vim.opt.cursorline = true -- highlight current line (native; replaced nvim-cursorline)
vim.opt.termguicolors = true -- 24-bit color (was set in the old config/theme.lua)
vim.opt.winborder = "rounded" -- default border for all floats (hover, signature, etc.)

vim.diagnostic.config({
	virtual_lines = {
		current_line = true,
		severity = { min = vim.diagnostic.severity.WARN },
		spacing = 8,
	},
	virtual_text = {

		current_line = false,
		severity = { min = vim.diagnostic.severity.WARN },
		spacing = 8,
	},
	signs = true,
	underline = true,
	update_in_insert = true,
	float = {
		border = "rounded",
		source = true,
	},
	severity_sort = true,
})
vim.opt.clipboard = "unnamedplus" -- use system clipboard (Ctrl-C/V interop on Linux)

-- Briefly highlight yanked text (vim.hl.on_yank; vim.highlight was renamed to
-- vim.hl in 0.11). Visual confirmation of what the yank grabbed.
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	desc = "Highlight yanked text",
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Plugin setup is owned entirely by lazy.nvim specs under lua/plugins/
-- (telescope/dap/LSP load lazily via keys/cmd/event triggers). Only
-- plugin-free config is required here.
require("config.lazy")
require("config.mappings") -- global keymaps + fold options
require("config.inlay") -- native inlay hints on LspAttach
require("config.opencode") -- :OpenCode* user commands
