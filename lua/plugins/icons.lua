-- https://github.com/nvim-tree/nvim-web-devicons
-- Filetype icons used by telescope, bufferline, lualine, trouble, etc.
-- Loaded only as a dependency of those plugins (formerly set up eagerly via
-- lua/config/icons.lua).
return {
	'nvim-tree/nvim-web-devicons',
	lazy = true,
	opts = {
		default = true,
	},
}
