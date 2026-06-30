-- https://github.com/kylechui/nvim-surround
-- Add/change/delete surrounding pairs (vim-surround mnemonics):
--   ys{motion}{char}  add      e.g. ysiw"  -> wrap word in "
--   cs{old}{new}      change   e.g. cs"'   -> "x" becomes 'x'
--   ds{char}          delete   e.g. ds(    -> remove ( )
-- visual mode: S{char} surrounds the selection.
return {
	"kylechui/nvim-surround",
	version = "*",
	event = "VeryLazy",
	opts = {},
}
