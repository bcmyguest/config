vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- Shim: galaxyline.nvim (unmaintained) calls the deprecated
-- vim.lsp.buf_get_clients(), which warns on nvim 0.12. Redirect it to the
-- modern get_clients(). `bufnr or 0` preserves the old "current buffer when
-- nil" semantics; all galaxyline callsites only test emptiness / iterate by
-- value, so the list return is compatible.
vim.lsp.buf_get_clients  = function(bufnr)
	return vim.lsp.get_clients({ bufnr = bufnr or 0 })
end

-- Shim: galaxyline.nvim also calls the deprecated vim.lsp.get_active_clients(),
-- renamed to get_clients() in 0.10 with an identical filter argument. Alias it
-- directly so the deprecation warning stops.
vim.lsp.get_active_clients = function(filter)
	return vim.lsp.get_clients(filter)
end

vim.opt.number           = true  -- absolute line number for the line you are on
vim.opt.relativenumber   = false -- relative line numbers

-- Editing creature comforts
vim.opt.undofile         = true     -- persistent undo across sessions
vim.opt.ignorecase       = true     -- case-insensitive search...
vim.opt.smartcase        = true     -- ...unless the query has uppercase
vim.opt.scrolloff        = 8        -- keep context above/below the cursor
vim.opt.signcolumn       = "yes"    -- always show sign column (no gutter jitter)
vim.opt.splitright       = true     -- vertical splits open to the right
vim.opt.splitbelow       = true     -- horizontal splits open below
vim.opt.mouse            = "a"      -- mouse in all modes
vim.opt.winborder        = "rounded" -- default border for all floats (hover, signature, etc.)

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
require("config.lazy")
require("config.telescope")  -- require telescope
require("mason").setup()     -- require mason
require("config.tree")       -- file tree
require("config.treesitter") -- require syntax highlighting
require("config.mappings")   -- require local mappings file
require("config.formatter")  -- require local formatter file
require("config.lsp")        -- require local lsp file
require("config.theme")
require("config.inlay")
require("config.comment")
require("config.fidget")
require("config.git")
require("bufferline").setup {}
require("config.icons")
require("plugins.opencode")
require("config.opencode")
