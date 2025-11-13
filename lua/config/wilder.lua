local wilder = require('wilder')
wilder.setup({
	modes = { ':', '/', '?' },
	next_key = '<Tab>',
	previous_key = '<S-Tab>',
	accept_key = '<Up>',
})

-- Disable Python remote plugin
wilder.set_option('use_python_remote_plugin', 0)

wilder.set_option('pipeline', {
	wilder.branch(
		wilder.cmdline_pipeline({
			fuzzy = 1,
			fuzzy_filter = wilder.lua_fzy_filter(),
		}),
		wilder.vim_search_pipeline()
	)
})

wilder.set_option('renderer', wilder.renderer_mux({
	[':'] = wilder.popupmenu_renderer({
		highlighter = wilder.lua_fzy_highlighter(),
		highlights = {
			accent = wilder.make_hl('WilderAccent', 'Pmenu',
				{ { a = 1 }, { a = 1 }, { foreground = '#f4468f' } }),
		},
		left = {
			' ',
			wilder.popupmenu_devicons()
		},
		right = {
			' ',
			wilder.popupmenu_scrollbar()
		},
		theme = wilder.set_option('renderer', wilder.popupmenu_renderer({
			-- highlighter applies highlighting to the candidates
			highlighter = wilder.basic_highlighter(),
		})),
	}),
	['/'] = wilder.wildmenu_renderer({
		theme = wilder.set_option('renderer', wilder.popupmenu_renderer({
			-- highlighter applies highlighting to the candidates
			highlighter = wilder.basic_highlighter(),
		})),
		highlighter = wilder.lua_fzy_highlighter(),
		highlights = {
			accent = wilder.make_hl('WilderAccent', 'Pmenu',
				{ { a = 1 }, { a = 1 }, { foreground = '#f4468f' } }),
		},
	}),
}))
