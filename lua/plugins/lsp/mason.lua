-- https://github.com/williamboman/mason.nvim
-- Mason is an lsp package manager for nvim
-- https://github.com/mhartington/formatter.nvim
-- Formatter automatically formats your code on save
-- https://github.com/neovim/nvim-lspconfig
-- collection of lsp configurations
-- https://github.com/williamboman/mason-lspconfig.nvim
-- mason-lspconfig plugin that maps between mason packages and lsp names
-- https://github.com/mfussenegger/nvim-lint
-- nvim lint is like a reporting tool for linters to push info to diagnostics
-- https://github.com/stevanmilic/nvim-lspimport
-- helps with auto-imports for pyright (since pyright doesn't support auto-imports)
return {
	{
		"williamboman/mason.nvim",
		lazy = false
	},
	{

		"mhartington/formatter.nvim"
	},
	{
		"neovim/nvim-lspconfig",
		lazy = true,
		--opts = {
		--	inlay_hints = {
		--		enabled = true
		--	}
		--}
	}, { "williamboman/mason-lspconfig.nvim", }, { "mfussenegger/nvim-lint" }
, { "stevanmilic/nvim-lspimport" } }
