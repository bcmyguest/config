-- Global, plugin-free mappings and fold options. mapleader is set in
-- config/lazy.lua (must happen before lazy.nvim setup so `keys` specs
-- resolve <Leader> correctly). Plugin-bound keymaps live in their lazy
-- specs: telescope + dap under lua/plugins/, LSP buffer-local maps in
-- config/mappings/lsp.lua (applied on LspAttach).
vim.opt.foldmethod = "expr"
-- Native treesitter foldexpr. The old `nvim_treesitter#foldexpr()` is the
-- master-branch API and does not exist on the `main` (rewrite) branch we use.
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable = false
require("config.mappings.misc")
