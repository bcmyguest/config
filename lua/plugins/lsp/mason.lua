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
--
-- The whole LSP stack hangs off nvim-lspconfig: it loads on the first real
-- buffer (BufReadPre/BufNewFile) and its config runs lua/config/lsp.lua,
-- which does mason-lspconfig setup, per-server vim.lsp.config, and
-- vim.lsp.enable. Opening nvim without a file keeps all of this cold.
return {
	{
		"mason-org/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUpdate" },
		opts = {},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"mason-org/mason-lspconfig.nvim",
			"saghen/blink.cmp",
			"b0o/SchemaStore.nvim",
		},
		config = function()
			require("config.lsp")
		end,
	},
	-- setup() is called from lua/config/lsp.lua, after mason is ready
	{ "mason-org/mason-lspconfig.nvim", lazy = true },
	{ "mfussenegger/nvim-lint", lazy = true },
	-- required on demand inside the LspAttach on_attach (<Leader>i)
	{ "stevanmilic/nvim-lspimport", lazy = true },
}
