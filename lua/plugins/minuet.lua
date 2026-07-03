-- minuet-ai.nvim — LLM code completion, pointed at the local lemonade server.
-- Manual only: nothing completes as-you-type. Trigger a suggestion with <A-y>
-- (insert mode), or flip on auto-as-you-type per buffer with <leader>mt.
return {
	"milanglacier/minuet-ai.nvim",
	cmd = "Minuet",
	keys = {
		{ "<leader>mt", "<cmd>Minuet virtualtext toggle<cr>", desc = "Minuet: toggle auto-complete (buffer)" },
		{ "<leader>mm", "<cmd>Minuet change_model<cr>", desc = "Minuet: change model" },
		{ "<leader>mp", "<cmd>Minuet change_provider<cr>", desc = "Minuet: change provider" },
	},
	config = function()
		require("minuet").setup({
			provider = "openai_compatible",
			request_timeout = 5, -- ~0.5s/response with thinking off; headroom for cold buffers
			n_completions = 1, -- one request to the single local GPU
			provider_options = {
				openai_compatible = {
					name = "Lemonade",
					end_point = "http://127.0.0.1:13305/api/v1/chat/completions",
					api_key = function()
						return "lemonade"
					end, -- lemonade ignores auth
					model = "Qwen3.6-35B-A3B-ThinkingCoder",
					stream = true,
					optional = {
						max_tokens = 256,
						temperature = 0.2, -- steadier completions than the server's 0.6 default
						top_p = 0.9,
						-- Kill chain-of-thought: 5s -> 0.5s. Reasoning is useless for FIM.
						chat_template_kwargs = { enable_thinking = false },
					},
				},
			},
			virtualtext = {
				auto_trigger_ft = {}, -- empty = never auto-fire; manual control only
				keymap = {
					accept = "<A-A>", -- accept whole suggestion
					accept_line = "<A-a>", -- accept one line
					accept_n_lines = "<A-z>", -- accept N lines (prompts for count)
					prev = "<A-Y>", -- cycle back (rarely needed at n_completions=1)
					next = "<A-y>", -- TRIGGER: press in insert mode to request a suggestion
					dismiss = "<A-e>",
				},
			},
		})
	end,
}
