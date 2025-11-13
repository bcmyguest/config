-- https://github.com/MysticalDevil/inlay-hints.nvim
-- enables inlay hints for LSP configs
-- note: these are DISABLED by default

return { {
	"MysticalDevil/inlay-hints.nvim",
	event = "LspAttach",
	dependencies = { "neovim/nvim-lspconfig" },
	config = function()
		require("inlay-hints").setup()
	end
} }
