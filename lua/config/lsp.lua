-- package manager by configurations
local mason_lspconfig = require("mason-lspconfig")
mason_lspconfig.setup {
	ensure_installed = { "lua_ls", "rust_analyzer", "jsonls", "ruff", "basedpyright", "eslint", "ts_ls", "yamlls", "clangd" },
	automatic_install = true,
	-- mason auto-enables every installed server by default. Exclude the Python
	-- type checkers so they aren't force-enabled behind our backs — the
	-- conditional vim.lsp.enable() below picks exactly one (pyrefly when the
	-- venv provides it, else basedpyright).
	automatic_enable = { exclude = { "basedpyright", "pyrefly" } },
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

-- LSP attach and capabilities. blink.cmp supplies the completion capabilities
-- (replaces cmp_nvim_lsp.default_capabilities); get_lsp_capabilities() already
-- merges Neovim's defaults.
local lsp_capabilities = require('blink.cmp').get_lsp_capabilities()
local nvim_lsp = require("lspconfig")
local util = nvim_lsp.util
local path = util.path

-- Locate a Python virtualenv even when it isn't activated: prefer an explicit
-- $VIRTUAL_ENV, otherwise walk up from the current file (or cwd) for a `.venv`
-- directory (the uv / common layout). This is why pyrefly used to stay off —
-- launching nvim without activating the venv hid the project-local pyrefly.
local function find_venv()
	if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
		return vim.env.VIRTUAL_ENV
	end
	local from = vim.fn.expand("%:p:h")
	if from == "" then
		from = vim.fn.getcwd()
	end
	return vim.fs.find(".venv", { path = from, upward = true, type = "directory" })[1]
end

local function get_python_path()
	local venv = find_venv()
	if venv then
		return path.join(venv, "bin", "python")
	end

	-- Fallback to system Python.
	return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

-- Hover/signature/float borders are set globally via `vim.o.winborder` in
-- init.lua (the old `vim.lsp.handlers[...] = vim.lsp.with(...)` API is deprecated).
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
	settings = {
		-- redhat.telemetry is a top-level yamlls setting, NOT under `yaml`.
		-- It previously sat at array index [1] inside `yaml`, making that
		-- table a mixed list+dict — which nvim_exec_autocmds can't serialize
		-- for the LspNotify autocmd ("Cannot convert given Lua table").
		redhat = {
			telemetry = {
				enabled = false
			}
		},
		yaml = {
			filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yml" },
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
		filetypes = { "python", "jupyter", "ipynb", "py", "pyc" },
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
				diagnosticMode = 'openFilesOnly',
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

-- Resolve a binary from the project virtualenv when it actually provides it,
-- else fall back to PATH. Mirrors get_python_path()'s venv-first assumption.
local function get_venv_bin(name)
	local venv = find_venv()
	if venv then
		local candidate = path.join(venv, "bin", name)
		if vim.fn.executable(candidate) == 1 then
			return candidate
		end
	end
	local found = vim.fn.exepath(name)
	return found ~= "" and found or name
end

-- Resolved once at startup (from the launch-time venv/cwd), reused for both the
-- pyrefly cmd and the enable-gate below.
local pyrefly_bin = get_venv_bin("pyrefly")

-- pyrefly — fast Rust-based Python type checker. filetypes/root_markers come
-- from nvim-lspconfig's bundled config; we point cmd at the project venv's
-- pyrefly (installed per-project, e.g. `uv add --dev pyrefly`) and add
-- completion caps + inlay hints.
-- NOTE: overlaps with basedpyright (both type-check Python) — expect duplicate
-- diagnostics until one is disabled.
vim.lsp.config["pyrefly"] = {
	cmd = { pyrefly_bin, "lsp" },
	capabilities = lsp_capabilities,
	-- pyrefly reads inlay-hint config from workspace/configuration (i.e. nvim's
	-- `settings`), under a top-level `analysis.inlayHints`. variableTypes /
	-- functionReturnTypes default true; callArgumentNames defaults "off".
	settings = {
		analysis = {
			inlayHints = {
				variableTypes = true,
				functionReturnTypes = true,
				callArgumentNames = "all", -- "all" | "partial" | "off"
				pytestParameters = true,
			},
		},
	},
}

-- Python type checker: pyrefly is the default and is always enabled.
-- basedpyright runs ADDITIONALLY only when a project explicitly configures it
-- (a pyrightconfig.json, or a [tool.basedpyright]/[tool.pyright] table in
-- pyproject.toml). When both run, expect overlapping diagnostics/hover.
local function basedpyright_configured()
	local root = vim.fn.getcwd()
	if vim.fn.filereadable(root .. "/pyrightconfig.json") == 1 then
		return true
	end
	local pyproject = root .. "/pyproject.toml"
	if vim.fn.filereadable(pyproject) == 1 then
		local content = table.concat(vim.fn.readfile(pyproject), "\n")
		if content:match("%[tool%.basedpyright%]") or content:match("%[tool%.pyright%]") then
			return true
		end
	end
	return false
end

local servers = { "lua_ls", "ruff", "ts_ls", "jsonls", "yamlls", "eslint", "clangd" }

-- pyrefly is the default Python type checker — enable it whenever its binary is
-- resolvable. If it isn't, warn once instead of failing silently per-buffer
-- (lspconfig's pyrefly config notifies on every failed spawn otherwise).
if vim.fn.executable(pyrefly_bin) == 1 then
	table.insert(servers, "pyrefly")
else
	vim.schedule(function()
		vim.notify(
			("pyrefly not found (%s) — Python type-checking via pyrefly is off. Install it, e.g. `uv add --dev pyrefly`.")
			:format(pyrefly_bin),
			vim.log.levels.WARN
		)
	end)
end

if basedpyright_configured() then
	table.insert(servers, "basedpyright")
end

vim.lsp.enable(servers)
-- Format-on-save is owned by conform.nvim (lua/plugins/formatting/conform.lua),
-- which runs the attached LSP formatter via lsp_format = "last". The old
-- bespoke BufWritePre autocmd lived here.


vim.api.nvim_create_autocmd('LspAttach', {
	callback = require("config.mappings.lsp").on_attach,
})
