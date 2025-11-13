vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.number           = true  -- absolute line number for the line you are on
vim.opt.relativenumber   = false -- relative line numbers
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
require("config.wilder")
require("config.telescope")
require("config.git")
require("bufferline").setup {}
require("config.claude")
