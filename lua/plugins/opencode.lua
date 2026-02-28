local opencode_cmd = 'opencode --port'
local snacks_terminal_opts = {
	win = {
		position = 'right',
		enter = false,
		on_win = function(win)
			-- Set up keymaps and cleanup for an arbitrary terminal
			require('opencode.terminal').setup(win.win)
		end,
	},
}
return {
	"nickjvandyke/opencode.nvim",
	dependencies = {
		-- Recommended for `ask()` and `select()`.
		-- Required for `snacks` provider.
		---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	},
	config = function()
		---@type opencode.Opts
		vim.g.opencode_opts = {
			server = {
				start = function()
					require('snacks.terminal').open(opencode_cmd, snacks_terminal_opts)
				end,
				stop = function()
					require('snacks.terminal').get(opencode_cmd, snacks_terminal_opts):close()
				end,
				toggle = function()
					require('snacks.terminal').toggle(opencode_cmd, snacks_terminal_opts)
				end,
			},
		}

		-- Required for `opts.events.reload`.
		vim.o.autoread = true

		-- Recommended/example keymaps.
		vim.keymap.set({ "n", "x" }, "<C-a>",
			function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
		vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,
			{ desc = "Execute opencode action…" })
		vim.keymap.set({ "n", "t" }, "<M-,>", function() require("opencode").toggle() end,
			{ desc = "Toggle opencode" })

		vim.keymap.set({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end,
			{ desc = "Add range to opencode", expr = true })
		vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end,
			{ desc = "Add line to opencode", expr = true })

		vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,
			{ desc = "Scroll opencode up" })
		vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end,
			{ desc = "Scroll opencode down" })

		-- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o…".
		vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
		vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
	end,
}
