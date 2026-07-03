-- https://github.com/lukas-reineke/indent-blankline.nvim
-- Auto indentation lines. Config lives here (lazy calls require("ibl").setup
-- with these opts); the old lua/config/indent.lua was never required, so this
-- customization previously didn't apply.
local highlight = { "CursorColumn", "Whitespace" }

return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		indent = { highlight = highlight, char = "" },
		whitespace = {
			highlight = highlight,
			remove_blankline_trail = false,
		},
		scope = { enabled = false },
	},
}
