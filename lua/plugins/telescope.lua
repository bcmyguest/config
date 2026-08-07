-- https://github.com/nvim-telescope/telescope.nvim
-- nvim fuzzy finder and associated plugins. Loads lazily on first keymap or
-- :Telescope; setup + fzf extension (formerly lua/config/telescope.lua) live
-- here. Keymaps (<leader>f*, <leader>gl) live in lua/config/mappings.lua; both
-- `cmd` and the keymaps' inline require keep the plugin cold until used.

return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		cmd = "Telescope",
		config = function()
			require("telescope").setup({
				extensions = {
					fzf = {
						fuzzy = true, -- false will only do exact matching
						override_generic_sorter = true, -- override the generic sorter
						override_file_sorter = true, -- override the file sorter
						case_mode = "smart_case", -- or "ignore_case" or "respect_case"
					},
				},
				pickers = {
					find_files = {
						find_command = { "rg", "--files", "--iglob", "!.git/*", "--hidden" },
					},
					grep_string = {
						additional_args = { "--hidden" },
					},
					live_grep = {
						additional_args = { "--hidden" },
					},
				},
			})
			-- fzf extension must be loaded after setup
			require("telescope").load_extension("fzf")
		end,
	},
}
