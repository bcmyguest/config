-- map the leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false
require("config.mappings.lsp")
require("config.mappings.telescope")
require("config.mappings.dap")
require("config.mappings.misc")
require("config.mappings.refactoring")
