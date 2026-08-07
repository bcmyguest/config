-- https://github.com/mfussenegger/nvim-dap
-- like an LSP but for debugging. Loads lazily on first debug keymap; keymaps
-- live in lua/config/mappings.lua and their inline require pulls this in.

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			-- 'mfussenegger/nvim-dap-python',
			"nvim-neotest/nvim-nio",
			"rcarriga/nvim-dap-ui",
		},
		-- Keymaps (<leader>d*, <F5>, <leader>b/B, <leader>lp) live in
		-- lua/config/mappings.lua. dap has no cmd/event; the keymaps' inline
		-- `require("dap")` triggers lazy.nvim's require-hook on first press, so
		-- the dap/dapui/nio stack stays cold until debugging starts.
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
