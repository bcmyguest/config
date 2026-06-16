-- folke/trouble.nvim — pretty list for diagnostics, references, quickfix, etc.
return {
	"folke/trouble.nvim",
	cmd = "Trouble",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {},
	keys = {
		{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Trouble: diagnostics (workspace)" },
		{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Trouble: diagnostics (buffer)" },
		{ "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",                desc = "Trouble: symbols" },
		{ "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "Trouble: LSP defs/refs" },
		{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                            desc = "Trouble: location list" },
		{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                             desc = "Trouble: quickfix list" },
	},
}
