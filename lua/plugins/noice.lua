-- folke/noice.nvim — replaces the cmdline / popupmenu UI.
-- Swapped in for wilder.nvim, which broke on nvim 0.12.x (mispositioned
-- popup + invisible ':' prefix). fidget still owns notifications + LSP
-- progress, so noice is scoped to the cmdline and completion popup only.
return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = { "MunifTanjim/nui.nvim" },
	opts = {
		cmdline = { enabled = true, view = "cmdline_popup" }, -- floating cmdline, prefix always visible
		popupmenu = { enabled = false }, -- blink.cmp owns the cmdline completion menu
		notify = { enabled = false }, -- leave vim.notify to fidget
		messages = { enabled = false }, -- don't hijack :messages / search count
		lsp = {
			progress = { enabled = false }, -- fidget handles LSP progress
			hover = { enabled = true },
			signature = { enabled = true },
		},
	},
}
