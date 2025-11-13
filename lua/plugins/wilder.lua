-- https://github.com/gelguy/wilder.nvim
-- code completion nvim command line

return {
	{
		"gelguy/wilder.nvim",
		dependencies = {
			'roxma/nvim-yarp',
			'roxma/vim-hug-neovim-rpc',
			'romgrk/fzy-lua-native'
		}
	},
	'roxma/vim-hug-neovim-rpc', 'roxma/nvim-yarp', 'romgrk/fzy-lua-native'
}
