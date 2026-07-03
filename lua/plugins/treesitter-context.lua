-- https://github.com/nvim-treesitter/nvim-treesitter-context
-- Sticky header at the top of the window showing the enclosing scope
-- (function/class/block) once its opening line scrolls off. Uses its own
-- queries, so it's independent of the nvim-treesitter `main`-branch API.
return {
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		max_lines = 3, -- cap header height (0 = unlimited)
		multiline_threshold = 1, -- collapse multi-line contexts to one line
		mode = "cursor", -- context follows the cursor's scope
	},
}
