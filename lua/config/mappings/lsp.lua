local Map = require("config.mappings.util").Map
-- uses nvim-lspimport to import using pyright

local function on_attach()
	Map("n", "<Leader>i", require("lspimport").import, { desc = "Import" })

	-- lsp actions https://github.com/linguini1/nvim/blob/main/after/plugin/lsp.lua
	Map("n", "K", vim.lsp.buf.hover, { buffer = 0, desc = "Show documentation in hover window." })
	Map("n", "gd", vim.lsp.buf.definition, { buffer = 0, desc = "Jump to definition." })
	Map("n", "gD", vim.lsp.buf.declaration, { buffer = 0, desc = "Jump to declaration." })
	Map("n", "gi", vim.lsp.buf.implementation, { buffer = 0, desc = "Jump to implementation." })
	Map("n", "go", vim.lsp.buf.type_definition, { buffer = 0, desc = "Jump to type definition." })
	Map("n", "gs", vim.lsp.buf.signature_help, { buffer = 0, desc = "Jump to signature help." })
	Map(
		"n",
		"gq",
		function() vim.lsp.buf.format({ async = true }) end,
		{ buffer = 0, desc = "Jump to signature help." }
	)
	Map("n", "rn", vim.lsp.buf.rename, { buffer = 0, desc = "Rename symbol under cursor." })
	Map(
		"n",
		"gr",
		require("telescope.builtin").lsp_references,
		{ buffer = 0, desc = "Show references in a Telescope window." }
	)
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
		end,
		{ desc = "Show diagnostic information in hover." })

	-- Code actions
	if vim.lsp.buf.range_code_action then
		Map("n", "<Leader>la", vim.lsp.buf.range_code_action,
			{ buffer = 0, desc = "Range code action." })
	else
		Map("n", "<Leader>la", "<cmd>lua vim.lsp.buf.code_action()<CR>")
	end
end
return { on_attach = on_attach }
