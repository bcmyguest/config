-- https://github.com/nvim-telescope/telescope.nvim
-- nvim fuzzy finder and associated plugins
return {
	{
		'nvim-telescope/telescope.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
	{ "nvim-telescope/telescope-file-browser.nvim", dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" } },
{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }

}

