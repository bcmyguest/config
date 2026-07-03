local M = {}

function M.toggle()
	require("opencode").toggle()
end

function M.ask(prompt)
	require("opencode").ask(prompt, { submit = true })
end

function M.select()
	require("opencode").select()
end

vim.api.nvim_create_user_command("OpenCode", function()
	require("opencode").toggle()
end, { desc = "Toggle opencode.nvim", nargs = 0 })

vim.api.nvim_create_user_command("OpenCodeAsk", function(args)
	local prompt = args.args or "@this: "
	require("opencode").ask(prompt, { submit = true })
end, { desc = "Ask opencode in the prompt", nargs = "?" })

vim.api.nvim_create_user_command("OpenCodeSelect", function()
	require("opencode").select()
end, { desc = "Select opencode action", nargs = 0 })

return M
