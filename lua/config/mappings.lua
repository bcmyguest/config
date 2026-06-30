-- map the leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.foldmethod = "expr"
-- Native treesitter foldexpr. The old `nvim_treesitter#foldexpr()` is the
-- master-branch API and does not exist on the `main` (rewrite) branch we use.
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false
require("config.mappings.lsp")
require("config.mappings.telescope")
require("config.mappings.dap")
require("config.mappings.misc")
