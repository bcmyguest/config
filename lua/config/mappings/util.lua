-- mapping convenience function for keymaps
function Map(mode, lhs, rhs, opts)
	local options = { noremap = true, silent = false }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

return {
	Map = Map,
}
