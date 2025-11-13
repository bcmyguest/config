-- https://github.com/ya2s/nvim-cursorline
-- Highlights the current line and the current word

return {
	{
		"yamatsum/nvim-cursorline",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		--		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			require('nvim-cursorline').setup {
				cursorline = {
					enable = true,
					timeout = 1000,
					number = false,
				},
				cursorword = {
					enable = false,
					min_length = 3,
					hl = { underline = false },
				}
			}
		end,
	}

}
