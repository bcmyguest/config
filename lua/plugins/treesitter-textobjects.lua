-- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
-- Treesitter-aware text objects + motions. Pinned to `branch = "main"` to match
-- the nvim-treesitter `main` (rewrite) pin in plugins/treesitter.lua — the main
-- branch has a different API (explicit setup + manual keymaps) than master.
--
-- Keymaps avoid the <leader>a* namespace (owned by Claude Code) for swaps, and
-- ]c/[c are free here (gitsigns defines no hunk-nav maps in this config).
return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	event = { "BufReadPost", "BufNewFile" },
	config = function()
		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true,
				selection_modes = {
					["@function.outer"] = "V",
					["@class.outer"] = "V",
				},
				include_surrounding_whitespace = false,
			},
			move = { set_jumps = true },
		})

		-- Select: af/if function, ac/ic class, aa/ia parameter.
		-- x = visual, o = operator-pending (e.g. `dif`, `vac`, `caa`).
		local select = require("nvim-treesitter-textobjects.select")
		local objects = {
			af = "@function.outer",
			["if"] = "@function.inner",
			ac = "@class.outer",
			ic = "@class.inner",
			aa = "@parameter.outer",
			ia = "@parameter.inner",
		}
		for lhs, obj in pairs(objects) do
			vim.keymap.set({ "x", "o" }, lhs, function()
				select.select_textobject(obj, "textobjects")
			end, { desc = "TS select " .. obj })
		end

		-- Move: ]f/[f function start, ]c/[c class start (n/x/o).
		local move = require("nvim-treesitter-textobjects.move")
		vim.keymap.set({ "n", "x", "o" }, "]f", function()
			move.goto_next_start("@function.outer", "textobjects")
		end, { desc = "Next function start" })
		vim.keymap.set({ "n", "x", "o" }, "[f", function()
			move.goto_previous_start("@function.outer", "textobjects")
		end, { desc = "Prev function start" })
		vim.keymap.set({ "n", "x", "o" }, "]c", function()
			move.goto_next_start("@class.outer", "textobjects")
		end, { desc = "Next class start" })
		vim.keymap.set({ "n", "x", "o" }, "[c", function()
			move.goto_previous_start("@class.outer", "textobjects")
		end, { desc = "Prev class start" })

		-- Swap the parameter under the cursor with the next / previous one.
		local swap = require("nvim-treesitter-textobjects.swap")
		vim.keymap.set("n", "<leader>na", function()
			swap.swap_next("@parameter.inner")
		end, { desc = "Swap parameter next" })
		vim.keymap.set("n", "<leader>pa", function()
			swap.swap_previous("@parameter.inner")
		end, { desc = "Swap parameter prev" })
	end,
}
