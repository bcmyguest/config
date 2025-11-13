local Map = require("config.mappings.util").Map
local telescope = require("telescope.builtin")
Map("n", "<Leader>ff", telescope.find_files, { desc = "Find files" })
Map("n", "<Leader>fg", telescope.git_files, { desc = "Find git files" })
Map("n", "<Leader>fc", telescope.git_commits, { desc = "Find git commits" })
Map("n", "<Leader>fs", telescope.grep_string, { desc = "Grep current string in files" })
Map("n", "<Leader>fw", telescope.live_grep, { desc = "Find grep string in files" })
Map("n", "<Leader>fh", telescope.help_tags, { desc = "Find help tags" })
Map("n", "<Leader>fb", telescope.buffers, { desc = "Find buffers" })
Map("n", "<Leader>fo", telescope.oldfiles, { desc = "Find old files" })
Map("n", "<Leader>fu", telescope.lsp_references, { desc = "Find usages" })
Map("n", "<Leader>gl", telescope.keymaps, { desc = "Find keymaps" })
Map("n", "<Leader>fn", function()
	telescope.find_files({
		prompt_title = "Find nearby files",
		cwd = vim.fn.expand("%:p:h"),
		find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
	})
end, { desc = "Find nearby files" })
