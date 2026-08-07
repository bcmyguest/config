-- folke/persistence.nvim — session save/restore per working directory.
-- Sessions auto-save on exit; restore manually so a fresh nvim stays empty.
return {
	"folke/persistence.nvim",
	event = "BufReadPre",
	opts = {},
	-- Keymaps (<leader>q*) live in lua/config/mappings.lua; `event` keeps this lazy.
}
