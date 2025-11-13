-- package manager by configurations
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup {
	ensure_installed = { "lua_ls", "rust_analyzer", "jsonls", "ruff", "basedpyright", "grammarly", "eslint", "ts_ls", "yamlls" },
	automatic_install = true,
}

-- -- despite changes to lsp in 0.11, this is still needed.
-- mason_lspconfig.setup_handlers {
-- 	-- The first entry (without a key) will be the default handler
-- 	-- and will be called for each installed server that doesn't have
-- 	-- a dedicated handler.
-- 	function(server_name) -- default handler (optional)
-- 		require("lspconfig")[server_name].setup {}
-- 	end,
--
-- }

-- LSP attach and capabilities
local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
lsp_capabilities = require('cmp_nvim_lsp').default_capabilities(lsp_capabilities)
local nvim_lsp = require("lspconfig")
local util = nvim_lsp.util
local path = util.path

local function get_python_path()
	-- Use activated virtualenv.
	if vim.env.VIRTUAL_ENV then
		return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
	end

	-- Fallback to system Python.
	return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

-- Formatting for hover and signature help
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
})
vim.lsp.config["lua_ls"] = {
	capabilities = lsp_capabilities,
	filetypes = { "lua" },

	settings = {
		Lua = {
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
			diagnostics = { globals = { 'vim' } }, -- Get the language server to recognize the `vim` global
			completion = {
				callSnippets = "Both", -- "Disable", "Replace"
				displayContext = 6,
			},
			-- hint.enable -> hint = { enable … }
			hint = {
				enable = true,
				arrayIndex = 'Enable',
				setType = true,
			},
		}
	}
}
vim.lsp.config["yamlls"] = {
	capabilities = lsp_capabilities,
	filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
	setings = {
		yaml = {
			filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yml" },
			{
				redhat = {
					telemetry = {
						enabled = false
					}
				}
			},
			single_file_support = true
		}
	}
}
vim.lsp.config["jsonls"] = {
	capabilities = lsp_capabilities,
	settings = { filetypes = { "json", "jsonc" }, }
}
vim.lsp.config["ts_ls"] = {
	capabilities = lsp_capabilities,
	-- https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
	settings = {
		init_options = {
			plugins = {
				{
					name = "@vue/typescript-plugin",
					location = "/usr/local/lib/node_modules/@vue/typescript-plugin",
					languages = { "javascript", "typescript", "vue" },
				},
			},
			hostInfo = "neovim"
		},
		filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue" },
		includeInlayParameterNameHintsWhenArgumentMatchesName = true,
		includeInlayFunctionParameterTypeHints = true,
		includeInlayVariableTypeHints = true,
		includeInlayPropertyDeclarationTypeHints = true,
		includeInlayFunctionLikeReturnTypeHints = true,
		includeInlayEnumMemberValueHints = true,
		includeInlayParameterNameHints = 'all',
		format = {
			baseIndentSize = 2,
			indentSize = 1,
			indentStyle = 'Smart',
			insertSpaceAfterCommaDelimiter = true,
			insertSpaceAfterConstructor = true,
			insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
			insertSpaceAfterKeywordsInControlFlowStatements = true,
			semicolons = 'Insert',

		}
	}
}
vim.lsp.config["eslint"] = {
	capabilities = lsp_capabilities,
	settings = {
		bin = 'eslint', -- or `eslint_d`
		-- https://github.com/LazyVim/LazyVim/issues/3383
		useFlatConfig = false, -- set if using flat config
		experimental = {
			useFlatConfig = nil, -- option not in the latest eslint-lsp
		},
		code_actions = {
			enable = true,
			apply_on_save = {
				enable = true,
				types = { "directive", "problem", "suggestion", "layout" },
			},
			disable_rule_comment = {
				enable = true,
				location = "separate_line", -- or `same_line`
			},
		},
		diagnostics = {
			enable = true,
			report_unused_disable_directives = false,
			run_on = "type", -- or `save`
		},
		completion = {
			enable = true
		}
	}
}

vim.lsp.config["ruff"] = {
	--	disabled code actions for ruff since we want to use pyright
	capabilities = lsp_capabilities,
	settings = {
		filetypes = { "python" },
		code_actions = {
			enable = false
		}
	}
}
-- vim.api.nvim_create_user_command(
-- 	'Ruff',
-- 	function()
-- 		vim.lsp.buf.code_action {
-- 			context = {
-- 				only = { 'source.fixAll.ruff' }
-- 			},
-- 			apply = true,
-- 		}
-- 		vim.lsp.buf.format { async = true }
-- 	end,
-- 	{ desc = "Reformat python with ruff" }
-- )
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup('lsp_attach_disable_ruff_hover', { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client == nil then
			return
		end
		if client.name == 'ruff' then
			-- Disable hover in favor of Pyright
			client.server_capabilities.hoverProvider = false
		end
	end,
	desc = 'LSP: Disable hover capability from Ruff',
})


vim.lsp.config["basedpyright"] = {
	capabilities = lsp_capabilities,
	before_init = function(_, config)
		local python_path = get_python_path()
		config.settings.python.pythonPath = python_path
		vim.notify(python_path)
	end,
	settings = {
		filetypes = { "python", "juptyer", "ipynb", "py", "pyc" },
		basedpyright = {
			-- Using Ruff's import organizer
			disableOrganizeImports = true,
			-- https://docs.basedpyright.com/v1.21.0/configuration/language-server-settings/
			analysis = {
				autoImportCompletions = true,
				-- Ignore all files for analysis to exclusively use Ruff for linting
				--ignore = { '*' },
				userFileIndexingLimit = 5000,
				code_actions = {
					enable = true,

				},
				autoIndent = true,
				autoSearchPaths = true,
				autoFormatStrings = true,
				diagnoticMode = 'openFilesOnly',
				inlayHints = {
					functionReturnTypes = true,
					genericTypes = true,
					pytestParameters = true,
					callArgumentNames = true,

				},
				typeCheckingMode = "standard",
				useLibraryCodeForTypes = true
			},

		},
		python = {},
		code_action = {
			enable = true,


		}
	},
}

vim.lsp.enable({ "lua_ls", "basedpyright", "ruff", "ts_ls", "jsonls", "yamlls", "eslint", "grammarly" })

-- auto-format on save
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]


vim.api.nvim_create_autocmd('LspAttach', {
	callback = require("config.mappings.lsp").on_attach,
})
