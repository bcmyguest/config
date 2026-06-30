-- https://github.com/NMAC427/guess-indent.nvim
-- Detects each buffer's indentation (tabs vs spaces + width) from its content and
-- sets expandtab/shiftwidth/tabstop to match. Lighter than vim-sleuth; no deps.
-- The init.lua fallback (tabstop/shiftwidth = 4) only applies to empty/new buffers
-- guess-indent can't sample.
return {
	"NMAC427/guess-indent.nvim",
	event = { "BufReadPost", "BufNewFile" },
	opts = {},
}
