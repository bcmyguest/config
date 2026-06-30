-- https://github.com/stevearc/conform.nvim
-- Format-on-save manager. Replaces mhartington/formatter.nvim (which only
-- stripped trailing whitespace) AND the bespoke LSP BufWritePre autocmd that
-- used to live in lua/config/lsp.lua.
--
-- lsp_format = "last": run conform's formatters (trim_whitespace) first, then
-- the attached LSP's formatter — so every buffer still gets LSP formatting on
-- save exactly like before, with trailing whitespace stripped on top. Add
-- real CLI formatters per-filetype below (stylua, prettier, ruff_format, …) as
-- you install them; pair with nvim-lint for diagnostics.
return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	opts = {
		formatters_by_ft = {
			["*"] = { "trim_whitespace" },
		},
		format_on_save = {
			timeout_ms = 2000,
			lsp_format = "last",
		},
	},
}
