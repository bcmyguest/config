-- https://github.com/folke/snacks.nvim
-- File explorer (leader + t). Replaces nvim-tree, mirroring its settings.
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		explorer = {
			replace_netrw = true,
		},
		picker = {
			sources = {
				explorer = {
					hidden = true,        -- show dotfiles (nvim-tree filters.dotfiles = false)
					ignored = true,       -- show git-ignored files (nvim-tree filters.git_ignored = false)
					exclude = { ".git" }, -- hide .git (nvim-tree filters.custom = { "^.git$" })
					follow_file = true,   -- nvim-tree update_focused_file.enable = true
					diagnostics = true,   -- nvim-tree diagnostics.enable = true
					git_status = true,        -- show git status on files
					git_status_open = false,  -- collapsed folders show aggregate status (nvim-tree diagnostics.show_on_dirs)
					matcher = { fuzzy = true }, -- fuzzy search (explorer default is fuzzy = false)
					win = {
						input = {
							keys = {
								-- type a filter, then <CR>/<Esc> drops into the tree
								-- (keeping the search term) instead of opening/closing.
								["<CR>"] = { "toggle_focus", mode = "i" },
								["<Esc>"] = { "toggle_focus", mode = "i" },
							},
						},
					},
					layout = {
						preset = "sidebar",
						preview = false,
						layout = {
							width = 30,     -- nvim-tree view.width = 30
							min_width = 30,
						},
					},
				},
			},
		},
	},
}
