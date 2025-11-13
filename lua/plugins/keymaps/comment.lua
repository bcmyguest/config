-- https://github.com/numToStr/Comment.nvim
-- comment keymaps (eg. gcc)

return { {
	'numToStr/Comment.nvim',
	opts = {
		-- add any options here
	}
}, {
	"folke/ts-comments.nvim",
	event = "VeryLazy",
	opts = {},
} }
