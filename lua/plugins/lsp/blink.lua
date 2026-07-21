-- https://github.com/saghen/blink.cmp
-- Completion engine. Replaces nvim-cmp + cmp-nvim-lsp + cmp-buffer + cmp-path
-- + cmp-cmdline + cmp_luasnip + LuaSnip — blink ships lsp/path/buffer/snippet
-- sources, cmdline completion, and a snippet engine in one plugin. friendly-
-- snippets is read directly by blink's `snippets` source.
--
-- version = "1.*" pulls a tagged release with a prebuilt Rust fuzzy-matcher
-- binary, so no cargo toolchain is needed to build it.
--
-- LSP capabilities are wired in lua/config/lsp.lua via
-- require('blink.cmp').get_lsp_capabilities(), replacing the old
-- cmp_nvim_lsp.default_capabilities() call.
return {
	"saghen/blink.cmp",
	dependencies = { "rafamadriz/friendly-snippets" },
	version = "1.*",
	event = "InsertEnter",
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		-- 'enter' preset: <CR> accepts, <C-space> opens/toggles docs, <C-e>
		-- hides, <C-n>/<C-p> select, <C-b>/<C-f> scroll docs, <Tab>/<S-Tab>
		-- jump snippet stops — mirrors the old nvim-cmp keymap (incl. <CR>).
		keymap = { preset = "enter" },
		appearance = { nerd_font_variant = "mono" },
		completion = {
			-- preselect first item so <CR> confirms it (old `confirm{select=true}`)
			list = { selection = { preselect = true, auto_insert = false } },
			menu = { border = "rounded" },
			documentation = { auto_show = true, window = { border = "rounded" } },
		},
		-- signature help stays off here — noice.nvim owns the signature popup.
		signature = { enabled = false },
		sources = {
			-- lazydev feeds nvim-API completions in Lua config buffers; score_offset
			-- ranks it above LSP so `vim.*` items surface first. No-op elsewhere.
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
		-- live as-you-type cmdline menu (old cmp-cmdline / cmp-path behaviour).
		-- Override the global preselect: in cmdline we want NO preselection so
		-- <Tab> selects+inserts the first match instead of skipping to the second
		-- (auto_insert fills the cmdline as you cycle — classic wildmenu feel).
		cmdline = {
			completion = {
				menu = { auto_show = true },
				list = { selection = { preselect = false, auto_insert = true } },
			},
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
	},
	opts_extend = { "sources.default" },
}
