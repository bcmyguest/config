-- https://github.com/nvim-telescope/telescope.nvim
-- nvim fuzzy finder and associated plugins. Loads lazily on first keymap or
-- :Telescope; setup + fzf extension (formerly lua/config/telescope.lua) and
-- the keymaps (formerly lua/config/mappings/telescope.lua) live here so the
-- plugin stays cold until used.

local function builtin(name, opts)
	return function()
		require("telescope.builtin")[name](opts)
	end
end

return {
	{
		'nvim-telescope/telescope.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
		},
		cmd = "Telescope",
		keys = {
			{ "<Leader>ff", builtin("find_files"),     desc = "Find files" },
			{ "<Leader>fg", builtin("git_files"),      desc = "Find git files" },
			{ "<Leader>fc", builtin("git_commits"),    desc = "Find git commits" },
			{ "<Leader>fs", builtin("grep_string"),    desc = "Grep current string in files" },
			{ "<Leader>fw", builtin("live_grep"),      desc = "Find grep string in files" },
			{ "<Leader>fh", builtin("help_tags"),      desc = "Find help tags" },
			{ "<Leader>fb", builtin("buffers"),        desc = "Find buffers" },
			{ "<Leader>fo", builtin("oldfiles"),       desc = "Find old files" },
			{ "<Leader>fu", builtin("lsp_references"), desc = "Find usages" },
			{ "<Leader>gl", builtin("keymaps"),        desc = "Find keymaps" },
			{
				"<Leader>fn",
				function()
					require("telescope.builtin").find_files({
						prompt_title = "Find nearby files",
						cwd = vim.fn.expand("%:p:h"),
						find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
					})
				end,
				desc = "Find nearby files",
			},
		},
		config = function()
			require('telescope').setup {
				extensions = {
					fzf = {
						fuzzy = true,                   -- false will only do exact matching
						override_generic_sorter = true, -- override the generic sorter
						override_file_sorter = true,    -- override the file sorter
						case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
					}
				},
				pickers = {
					find_files = {
						find_command = { 'rg', '--files', '--iglob', '!.git/*', '--hidden' },
					},
					grep_string = {
						additional_args = { '--hidden' }
					},
					live_grep = {
						additional_args = { '--hidden' }
					}
				}
			}
			-- fzf extension must be loaded after setup
			require('telescope').load_extension('fzf')
		end,
	},
}
