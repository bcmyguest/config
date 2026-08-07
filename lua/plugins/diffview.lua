-- https://github.com/sindrets/diffview.nvim
-- Side-by-side git diffs + file/branch history in a dedicated tab. Complements
-- gitsigns (inline hunks) and fugitive (porcelain). Self-contained — only an
-- optional nvim-web-devicons dep, which is already installed.
--
-- Keymaps live under <leader>g (gl=find-keymaps, gf=format are already taken;
-- gd/gD/gh/gH are free).
return {
	"sindrets/diffview.nvim",
	cmd = {
		"DiffviewOpen",
		"DiffviewClose",
		"DiffviewToggleFiles",
		"DiffviewFocusFiles",
		"DiffviewFileHistory",
	},
	-- Keymaps (<leader>g[dDhH]) live in lua/config/mappings.lua; `cmd` keeps this lazy.
	opts = {},
}
