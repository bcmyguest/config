-- https://github.com/nvim-telescope/telescope.nvim
-- nvim fuzzy finder and associated plugins
return {
	{
		'nvim-telescope/telescope.nvim',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
	{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' }
}
