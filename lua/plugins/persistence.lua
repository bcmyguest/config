-- folke/persistence.nvim — session save/restore per working directory.
-- Sessions auto-save on exit; restore manually so a fresh nvim stays empty.
return {
	"folke/persistence.nvim",
	event = "BufReadPre",
	opts = {},
	keys = {
		{ "<leader>qs", function() require("persistence").load() end,                desc = "Session: restore (this dir)" },
		{ "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Session: restore last" },
		{ "<leader>qd", function() require("persistence").stop() end,                desc = "Session: stop saving" },
	},
}
