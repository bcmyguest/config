-- coder/claudecode.nvim — Claude Code IDE integration over the same
-- WebSocket MCP protocol as the official VS Code / JetBrains extensions.
return {
	"coder/claudecode.nvim",
	dependencies = { "folke/snacks.nvim" },
	config = true,
	cmd = {
		"ClaudeCode",
		"ClaudeCodeFocus",
		"ClaudeCodeSelectModel",
		"ClaudeCodeAdd",
		"ClaudeCodeSend",
		"ClaudeCodeTreeAdd",
		"ClaudeCodeStatus",
		"ClaudeCodeStart",
		"ClaudeCodeStop",
		"ClaudeCodeOpen",
		"ClaudeCodeClose",
		"ClaudeCodeDiffAccept",
		"ClaudeCodeDiffDeny",
		"ClaudeCodeCloseAllDiffs",
	},
	-- Keymaps (<leader>a*, <M-,>) live in lua/config/mappings.lua; `cmd` keeps
	-- this lazy. The <leader>a which-key group label lives in which-key.lua
	-- opts.spec.
}
