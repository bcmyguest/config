local Map = require("config.mappings.util").Map
-- switching windows with <C-hjkl>
Map("n", "<C-h>", "<C-w>h", { desc = "move to the left window" })
Map("n", "<C-j>", "<C-w>j", { desc = "move to the bottom window" })
Map("n", "<C-k>", "<C-w>k", { desc = "move to the top window" })
Map("n", "<C-l>", "<C-w>l", { desc = "move to the right window" })
-- indenting
Map("v", "<", "<gv", { desc = "indent left" })
Map("v", ">", ">gv", { desc = "indent right" })
-- alt + bs to delete current word
Map("i", "<M-BS>", "<C-o>diw", { desc = "delete current word" })
-- Toggle comment on the current line via Neovim's built-in commenting (gcc,
-- available since 0.10). `:normal gcc` applies the built-in <Plug> mapping and
-- <Cmd> keeps insert mode intact. Replaces the removed Comment.nvim.
Map({ "i", "n" }, "<C-_>", "<Cmd>normal gcc<CR>", { desc = "Toggle comment" })

-- nvim-tree
Map('n', '<Leader>t', '<Cmd>NvimTreeToggle<CR>', { desc = "Toggle tree view" })
-- buffers
Map('n', '<A-h>', '<Cmd>bprev<CR>', { desc = "Previous buffer" })
Map('n', '<A-l>', '<Cmd>bnext<CR>', { desc = "Next buffer" })
Map('n', '<Leader>bd', '<cmd>bdelete<CR>', { desc = "Delete buffer" })
-- format
Map('n', '<Leader>gf', vim.lsp.buf.format, { desc = "Format buffer" })
