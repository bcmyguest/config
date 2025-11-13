-- https://github.com/windwp/nvim-autopairs
-- automatically pair things like brackets, quotes, etc.

return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},
	{
		"echasnovski/mini.pairs",
		enabled = false,
	},
}
