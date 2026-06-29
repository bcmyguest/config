-- nvim-treesitter `main` branch (the rewrite). Unlike `master`, setup() does
-- NOT accept ensure_installed / highlight / indent — those are silently
-- ignored. On `main`: install parsers with install(), and start highlighting
-- per-buffer with vim.treesitter.start() (here via a FileType autocmd).

local ts = require("nvim-treesitter")

-- Keep all available parsers installed (replaces `ensure_installed = "all"`).
-- install() is async + idempotent: already-installed parsers are skipped.
ts.install(ts.get_available())

-- Enable treesitter highlighting + indentation for any buffer whose filetype
-- maps to an installed parser.
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
	callback = function(ev)
		local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
		if not lang then
			return
		end
		-- start() creates the parser and throws if none is installed for this
		-- language (e.g. plugin buffers like NvimTree) — pcall and bail quietly.
		if not pcall(vim.treesitter.start, ev.buf, lang) then
			return
		end
		vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})

vim.filetype.add({
	extension = {
		gotmpl = 'gotmpl',
	},
	pattern = {
		[".*/templates/.*%.tpl"] = "helm",
		[".*/templates/.*%.ya?ml"] = "helm",
		["helmfile.*%.ya?ml"] = "helm",
	},
})
