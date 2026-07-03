-- https://github.com/mfussenegger/nvim-dap
-- like an LSP but for debugging. Loads lazily on first debug keymap; the
-- keymaps (formerly lua/config/mappings/dap.lua) live here as `keys` so the
-- dap/dapui/nio stack stays cold until debugging starts.

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			-- 'mfussenegger/nvim-dap-python',
			"nvim-neotest/nvim-nio",
			"rcarriga/nvim-dap-ui",
		},
		keys = {
			{
				"<Leader>dc",
				function()
					require("dap").run_to_cursor()
				end,
				desc = "Run to cursor",
			},
			{
				"<F5>",
				function()
					require("dap").continue()
				end,
				desc = "Continue debugger",
			},
			{
				"<Leader>do",
				function()
					require("dap").step_over()
				end,
				desc = "Step over",
			},
			{
				"<Leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Step into",
			},
			{
				"<Leader>b",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle breakpoint",
			},
			{
				"<Leader>B",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle breakpoint",
			},
			{
				"<Leader>dw",
				function()
					require("dapui").eval(nil, { enter = true })
				end,
				desc = "Eval word under cursor",
			},
			{
				"<Leader>dr",
				function()
					require("dap").restart()
				end,
				desc = "Restart debugger",
			},
			{
				"<Leader>lp",
				function()
					require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
				end,
				desc = "Log point",
			},
			{
				"<Leader>dt",
				function()
					require("dap").repl.open()
				end,
				desc = "Open dap repl",
			},
			{
				"<Leader>dl",
				function()
					require("dap").run_last()
				end,
				desc = "Run last debug config",
			},
			{
				"<Leader>dh",
				function()
					require("dap.ui.widgets").hover()
				end,
				mode = { "n", "v" },
				desc = "Debug hover",
			},
			{
				"<Leader>dp",
				function()
					require("dap.ui.widgets").preview()
				end,
				mode = { "n", "v" },
				desc = "Debug preview",
			},
			{
				"<Leader>df",
				function()
					local widgets = require("dap.ui.widgets")
					widgets.centered_float(widgets.frames)
				end,
				desc = "Debug window float",
			},
			-- <Leader>dS (capital): scopes float. <Leader>ds stays the LSP
			-- diagnostic float (mappings/lsp.lua) — that mapping wins on LspAttach.
			{
				"<Leader>dS",
				function()
					local widgets = require("dap.ui.widgets")
					widgets.centered_float(widgets.scopes)
				end,
				desc = "Show debug scopes",
			},
		},
		config = function()
			local dap, dapui = require("dap"), require("dapui")
			--			dap.configurations.python = {
			--				type = "python",
			--				request = "launch",
			--				name = "Launch file",
			--				program = "${file}",
			--			}
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
			dapui.setup()

			-- https://github.com/mfussenegger/nvim-dap-python?tab=readme-ov-file#custom-configuration
			-- local python_dap = require("dap-python")
			--
			-- python_dap.opts.rocks.enabled = false
			-- python_dap.setup("uv")
			--
			-- python_dap.test_runner = 'pytest'
			-- nvim-dap-python
		end,
	},
}
