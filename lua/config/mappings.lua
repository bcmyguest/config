-- Central source of truth for all plugin-bound keymaps. Loaded from init.lua
-- after config.lazy, so every plugin trigger is registered. mapleader is set in
-- config/lazy.lua (before lazy.nvim setup). Plugin specs own zero `keys` blocks;
-- they stay lazy via `cmd`/`event`, or (dap) via the inline `require` in the
-- keymap body, which lazy.nvim's require-hook loads on first press.
--
-- LSP buffer-local maps live in config/mappings/lsp.lua (applied on LspAttach)
-- because they depend on bufnr context; plugin-free maps live in
-- config/mappings/misc.lua. The `<leader>a` which-key group label lives in
-- plugins/which-key.lua opts.spec (which-key config, not a keymap).
--
-- Sections by <leader> prefix range:
--   Finders:     <leader>f   (+ <leader>gl for keymaps)
--   Git:         <leader>g
--   Dap:         <leader>d   (+ <F5>, <leader>b/B, <leader>lp)
--   Diagnostics: <leader>x
--   Minuet:      <leader>m
--   Claude:      <leader>a   (+ <M-,>)
--   Sessions:    <leader>q
--   Other:       <leader>?   (which-key)

vim.opt.foldmethod = "expr"
-- Native treesitter foldexpr. The old `nvim_treesitter#foldexpr()` is the
-- master-branch API and does not exist on the `main` (rewrite) branch we use.
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false

-- Plugin-free maps (window nav, indenting, buffers, format, explorer).
require("config.mappings.misc")

local set = vim.keymap.set

-- Finders: <leader>f (telescope) ---------------------------------------------
local function builtin(name, opts)
	return function()
		require("telescope.builtin")[name](opts)
	end
end
set("n", "<Leader>ff", builtin("find_files"), { desc = "Find files" })
set("n", "<Leader>fg", builtin("git_files"), { desc = "Find git files" })
set("n", "<Leader>fc", builtin("git_commits"), { desc = "Find git commits" })
set("n", "<Leader>fs", builtin("grep_string"), { desc = "Grep current string in files" })
set("n", "<Leader>fw", builtin("live_grep"), { desc = "Find grep string in files" })
set("n", "<Leader>fh", builtin("help_tags"), { desc = "Find help tags" })
set("n", "<Leader>fb", builtin("buffers"), { desc = "Find buffers" })
set("n", "<Leader>fo", builtin("oldfiles"), { desc = "Find old files" })
set("n", "<Leader>fu", builtin("lsp_references"), { desc = "Find usages" })
set("n", "<Leader>gl", builtin("keymaps"), { desc = "Find keymaps" })
set("n", "<Leader>fn", function()
	require("telescope.builtin").find_files({
		prompt_title = "Find nearby files",
		cwd = vim.fn.expand("%:p:h"),
		find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
	})
end, { desc = "Find nearby files" })

-- Git: <leader>g (diffview) --------------------------------------------------
set("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Diffview: open (working tree)" })
set("n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Diffview: close" })
set("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "Diffview: history (current file)" })
set("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Diffview: history (whole repo)" })

-- Dap: <leader>d (+ <F5>, <leader>b/B, <leader>lp) ---------------------------
set("n", "<Leader>dc", function()
	require("dap").run_to_cursor()
end, { desc = "Run to cursor" })
set("n", "<F5>", function()
	require("dap").continue()
end, { desc = "Continue debugger" })
set("n", "<Leader>do", function()
	require("dap").step_over()
end, { desc = "Step over" })
set("n", "<Leader>di", function()
	require("dap").step_into()
end, { desc = "Step into" })
set("n", "<Leader>b", function()
	require("dap").toggle_breakpoint()
end, { desc = "Toggle breakpoint" })
set("n", "<Leader>B", function()
	require("dap").toggle_breakpoint()
end, { desc = "Toggle breakpoint" })
set("n", "<Leader>dw", function()
	require("dapui").eval(nil, { enter = true })
end, { desc = "Eval word under cursor" })
set("n", "<Leader>dr", function()
	require("dap").restart()
end, { desc = "Restart debugger" })
set("n", "<Leader>lp", function()
	require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end, { desc = "Log point" })
set("n", "<Leader>dt", function()
	require("dap").repl.open()
end, { desc = "Open dap repl" })
set("n", "<Leader>dl", function()
	require("dap").run_last()
end, { desc = "Run last debug config" })
set({ "n", "v" }, "<Leader>dh", function()
	require("dap.ui.widgets").hover()
end, { desc = "Debug hover" })
set({ "n", "v" }, "<Leader>dp", function()
	require("dap.ui.widgets").preview()
end, { desc = "Debug preview" })
set("n", "<Leader>df", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.frames)
end, { desc = "Debug window float" })
-- <Leader>dS (capital): scopes float. <Leader>ds stays the LSP diagnostic float
-- (mappings/lsp.lua) — that mapping wins on LspAttach.
set("n", "<Leader>dS", function()
	local widgets = require("dap.ui.widgets")
	widgets.centered_float(widgets.scopes)
end, { desc = "Show debug scopes" })

-- Diagnostics: <leader>x (trouble) -------------------------------------------
set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble: diagnostics (workspace)" })
set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Trouble: diagnostics (buffer)" })
set("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Trouble: symbols" })
set(
	"n",
	"<leader>xl",
	"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
	{ desc = "Trouble: LSP defs/refs" }
)
set("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Trouble: location list" })
set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Trouble: quickfix list" })

-- Minuet: <leader>m (minuet-ai) ----------------------------------------------
set("n", "<leader>mt", "<cmd>Minuet virtualtext toggle<cr>", { desc = "Minuet: toggle auto-complete (buffer)" })
set("n", "<leader>mm", "<cmd>Minuet change_model<cr>", { desc = "Minuet: change model" })
set("n", "<leader>mp", "<cmd>Minuet change_provider<cr>", { desc = "Minuet: change provider" })

-- Claude: <leader>a (claudecode) (+ <M-,>) -----------------------------------
-- The <leader>a group label lives in plugins/which-key.lua opts.spec.
set({ "n", "t" }, "<M-,>", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
set("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude" })
set("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Focus Claude" })
set("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude" })
set("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue Claude" })
set("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", { desc = "Select Claude model" })
set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", { desc = "Add current buffer" })
set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Send to Claude" })
set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff" })
set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff" })
-- ft-local n-mode <leader>as ("Add file") in file-explorer buffers. Distinct
-- from the v-mode <leader>as above (different mode, no conflict).
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
	callback = function(ev)
		set("n", "<leader>as", "<cmd>ClaudeCodeTreeAdd<cr>", { buffer = ev.buf, desc = "Add file" })
	end,
})

-- Sessions: <leader>q (persistence) ------------------------------------------
set("n", "<leader>qs", function()
	require("persistence").load()
end, { desc = "Session: restore (this dir)" })
set("n", "<leader>ql", function()
	require("persistence").load({ last = true })
end, { desc = "Session: restore last" })
set("n", "<leader>qd", function()
	require("persistence").stop()
end, { desc = "Session: stop saving" })

-- Other: <leader>? (which-key) -----------------------------------------------
set("n", "<leader>?", function()
	require("which-key").show({ global = false })
end, { desc = "Buffer Local Keymaps (which-key)" })
