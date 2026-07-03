local Map = require("config.mappings.util").Map
-- uses nvim-lspimport to import using pyright

local function on_attach()
	Map("n", "<Leader>i", require("lspimport").import, { desc = "Import" })

	-- lsp actions https://github.com/linguini1/nvim/blob/main/after/plugin/lsp.lua
	-- K (hover), grr (references), grn (rename) come from Neovim's built-in
	-- LSP defaults (0.11+) — not remapped here.
	Map("n", "gd", vim.lsp.buf.definition, { buffer = 0, desc = "Jump to definition." })
	Map("n", "gD", vim.lsp.buf.declaration, { buffer = 0, desc = "Jump to declaration." })
	Map("n", "gi", vim.lsp.buf.implementation, { buffer = 0, desc = "Jump to implementation." })
	Map("n", "go", vim.lsp.buf.type_definition, { buffer = 0, desc = "Jump to type definition." })
	Map("n", "gs", vim.lsp.buf.signature_help, { buffer = 0, desc = "Jump to signature help." })
	Map("n", "gq", function()
		vim.lsp.buf.format({ async = true })
	end, { buffer = 0, desc = "Jump to signature help." })
	-- Diagnostics
	Map("n", "<Leader>ds", function()
		vim.diagnostic.open_float({
			scope = "line",
			focusable = false,
			close_events = {
				"CursorMoved",
				"CursorMovedI",
				"BufHidden",
				"InsertCharPre",
				"WinLeave",
			},
		})
	end, { desc = "Show diagnostic information in hover." })

	-- Code actions (handles visual-mode ranges natively; the removed
	-- range_code_action API was deleted in Neovim 0.7).
	Map({ "n", "v" }, "<Leader>la", vim.lsp.buf.code_action, { buffer = 0, desc = "Code action." })
end
return { on_attach = on_attach }
