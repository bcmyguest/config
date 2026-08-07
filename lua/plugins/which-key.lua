-- https://github.com/folke/which-key.nvim
-- shows possible keymaps when you press a key

return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	-- Keymaps (<leader>?) live in lua/config/mappings.lua. `spec` here only
	-- registers group labels for the which-key popup, not keymaps.
	opts = {
		spec = {
			{ "<leader>a", group = "AI/Claude Code" },
		},
	},
}
