-- https://github.com/nvim-treesitter/nvim-treesitter
-- parser for highlighting. Pinned to the `main` rewrite branch — setup lives
-- in lua/config/treesitter.lua (install() + FileType autocmd, not the old
-- declarative ensure_installed API).

local M = {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = "main",
	build = ":TSUpdate",
	config = function()
		require("config.treesitter")
	end,
}

return { M }
