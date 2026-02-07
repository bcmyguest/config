return {
	{
		'ggml-org/llama.vim',
		init = function()
			-- https://github.com/ggml-org/llama.vim/blob/master/doc/llama.txt
			vim.g.llama_config = {
				-- endpoint = 'http://127.0.0.1:8000',
				n_prefix = 1024,
				n_suffix = 1024,
				auto_fim = true,
				keymap_accept_full = "<C-S>",
				enable_at_startup = true,
				show_info = true,
				--[[ 	model = 'ggml-org_gpt-oss-20b-GGUF_gpt-oss-20b-mxfp4.gguf' ]]

			}
		end,

	}
}
