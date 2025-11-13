-- dap options
local Map = require("config.mappings.util").Map
local dap = require("dap")
Map("n", "<Leader>dc", dap.run_to_cursor, { desc = "Run to cursor" })

Map('n', '<F5>', function() dap.continue() end,
	{ desc = "Continue debugger" })
Map('n', '<Leader>do', function() dap.step_over() end,
	{ desc = "Step over" })
Map('n', '<Leader>di', function() dap.step_into() end,
	{ desc = "Step into" })
Map('n', '<Leader>b', function() dap.toggle_breakpoint() end,
	{ desc = "Toggle breakpoint" })
Map('n', '<Leader>B', function() dap.toggle_breakpoint() end,
	{ desc = "Toggle breakpoint" })
Map('n', '<Leader>dw', function() require('dapui').eval(nil, { enter = true }) end,
	{ desc = "Eval word under cursor" })
Map('n', '<Leader>dr', function() dap.restart() end,
	{ desc = "Restart debugger" })
Map('n', '<Leader>lp',
	function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
	{ desc = "Log point" })
Map('n', '<Leader>dr', function() dap.repl.open() end,
	{ desc = "Open dap repl" })
Map('n', '<Leader>dl', function() dap.run_last() end,
	{ desc = "Run last debug config" })
Map({ 'n', 'v' }, '<Leader>dh', function()
	require('dap.ui.widgets').hover()
end, { desc = "Debug hover" })
Map({ 'n', 'v' }, '<Leader>dp', function()
	require('dap.ui.widgets').preview()
end)
Map('n', '<Leader>df', function()
	local widgets = require('dap.ui.widgets')
	widgets.centered_float(widgets.frames)
end, { desc = "Debug window float" })
Map('n', '<Leader>ds', function()
	local widgets = require('dap.ui.widgets')
	widgets.centered_float(widgets.scopes)
end, { desc = "Show debug widgets" })
