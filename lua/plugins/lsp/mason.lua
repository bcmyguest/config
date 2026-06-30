-- https://github.com/mason-org/mason.nvim
-- Mason is an lsp package manager for nvim
-- (repo moved from williamboman/ to mason-org/ in 2025; old namespace archived)
-- https://github.com/neovim/nvim-lspconfig
-- collection of lsp configurations
-- https://github.com/mason-org/mason-lspconfig.nvim
-- mason-lspconfig plugin that maps between mason packages and lsp names (v2 API)
-- https://github.com/mfussenegger/nvim-lint
-- nvim lint is like a reporting tool for linters to push info to diagnostics
-- https://github.com/stevanmilic/nvim-lspimport
-- helps with auto-imports for pyright (since pyright doesn't support auto-imports)
return {
	{
		"mason-org/mason.nvim",
		lazy = false
	},
	{
		"neovim/nvim-lspconfig",
		lazy = true,
		--opts = {
		--	inlay_hints = {
		--		enabled = true
		--	}
		--}
	}, { "mason-org/mason-lspconfig.nvim", }, { "mfussenegger/nvim-lint" }
, { "stevanmilic/nvim-lspimport" } }
