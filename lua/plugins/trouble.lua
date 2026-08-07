-- folke/trouble.nvim — pretty list for diagnostics, references, quickfix, etc.
return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {},
	-- Keymaps (<leader>x*) live in lua/config/mappings.lua; `cmd` keeps this lazy.
}
