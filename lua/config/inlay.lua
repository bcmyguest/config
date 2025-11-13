require("inlay-hints").setup({
	commands = { enable = true }, -- Enable InlayHints commands, include `InlayHintsToggle`, `InlayHintsEnable` and `InlayHintsDisable`
	autocmd = { enable = true } -- Enable the inlay hints on `LspAttach` event
})

-- https://github.com/MysticalDevil/inlay-hints.nvim
