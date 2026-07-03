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
	keys = {
		{ "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open (working tree)" },
		{ "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
		{ "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: history (current file)" },
		{ "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: history (whole repo)" },
	},
	opts = {},
}
