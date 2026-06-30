-- https://github.com/echasnovski/mini.surround
-- Add/change/delete surrounding pairs. Default mini.surround keymaps (all
-- `s`-prefixed, normal + visual):
--   sa{motion}{char}  add      e.g. saiw"  / visual: select then sa"
--   sd{char}          delete   e.g. sd(
--   sr{old}{new}      replace  e.g. sr"'
--   sf / sF           find right / left surrounding
--   sh                highlight surrounding
-- The `s` prefix shadows native substitute (`c` covers that).
return {
	"echasnovski/mini.surround",
	version = "*",
	event = "VeryLazy",
	opts = {},
}
