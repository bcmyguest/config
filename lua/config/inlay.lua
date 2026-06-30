-- Native LSP inlay hints (Neovim 0.10+) — replaces MysticalDevil/inlay-hints.nvim.
-- Enable hints on attach for any client that advertises textDocument/inlayHint,
-- mirroring the old plugin's autocmd.enable = true behaviour.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("inlay_hints_enable", { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client:supports_method("textDocument/inlayHint") then
			vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
		end
	end,
	desc = "LSP: enable native inlay hints on attach",
})
