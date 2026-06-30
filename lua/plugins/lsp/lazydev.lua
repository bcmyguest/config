-- https://github.com/folke/lazydev.nvim
-- Configures lua_ls on demand for editing THIS Neovim config: full vim/nvim API
-- types, completion, and go-to-definition into the runtime. Modern replacement
-- for neodev.nvim. The manual `diagnostics.globals = { 'vim' }` in
-- lua/config/lsp.lua stays as a fallback for non-config Lua buffers.
-- A blink.cmp source is registered in lua/plugins/lsp/blink.lua.
return {
	"folke/lazydev.nvim",
	ft = "lua",
	opts = {
		library = {
			-- vim.uv typings (libuv) load when "vim.uv" appears in the buffer.
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		},
	},
}
