-- https://github.com/nvim-treesitter/nvim-treesitter
-- parser for highlighting

local M = {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	branch = 'main',
	build = ':TSUpdate'
}

return { M }
