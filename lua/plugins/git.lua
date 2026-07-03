-- https://github.com/lewis6991/gitsigns.nvim — inline git hunks/signs
-- https://github.com/tpope/vim-fugitive — git porcelain (:Git)
return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {},
	},
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "G", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite", "Gedit", "Gclog" },
	},
}
