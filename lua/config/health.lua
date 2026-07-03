-- :checkhealth config — external dependencies this config assumes but nvim
-- itself won't complain about until something breaks mid-session. Mirrors
-- the resolution logic in config/lsp.lua (venv-first pyrefly) rather than
-- re-inventing it, so the report matches what the LSP setup will do.
local M = {}

local health = vim.health

local function has_exe(name)
	return vim.fn.executable(name) == 1
end

local function bin(name, why, opts)
	opts = opts or {}
	if has_exe(name) then
		health.ok(("%s: %s"):format(name, vim.fn.exepath(name)))
		return true
	end
	local report = opts.severity == "error" and health.error or health.warn
	report(("%s not found — %s"):format(name, why), opts.advice)
	return false
end

-- Same venv discovery as config/lsp.lua: explicit $VIRTUAL_ENV, else walk up
-- from cwd for a .venv directory (checkhealth has no "current file" context).
local function find_venv()
	if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
		return vim.env.VIRTUAL_ENV
	end
	return vim.fs.find(".venv", { path = vim.fn.getcwd(), upward = true, type = "directory" })[1]
end

function M.check()
	health.start("core")
	if vim.fn.has("nvim-0.11") == 1 then
		health.ok("nvim >= 0.11 (" .. tostring(vim.version()) .. ")")
	else
		health.error(
			"nvim < 0.11 — this config uses the native vim.lsp.config/vim.lsp.enable API, vim.hl and winborder",
			"update Neovim (ansible role: ansible/roles/nvim)"
		)
	end
	bin("git", "lazy.nvim, gitsigns and fugitive all need it", { severity = "error" })

	health.start("search (telescope / snacks picker)")
	bin("rg", "find_files/live_grep are configured to shell out to ripgrep", { severity = "error" })
	-- snacks tries both binary names (picker/source/files.lua: cmd = {"fd","fdfind"}).
	if has_exe("fd") or has_exe("fdfind") then
		health.ok("fd: " .. (vim.fn.exepath("fd") ~= "" and vim.fn.exepath("fd") or vim.fn.exepath("fdfind")))
	else
		health.warn("fd/fdfind not found — snacks picker falls back to slower file listing", "apt install fd-find")
	end

	health.start("treesitter (main branch: parsers compile on install)")
	bin("tree-sitter", "nvim-treesitter main branch needs the CLI to install parsers", {
		severity = "error",
		advice = "ansible role: ansible/roles/tree-sitter (release binary into ~/.local/bin)",
	})
	bin("cc", "parsers are compiled with the system C compiler", { severity = "error" })
	bin("curl", "parser sources are fetched over HTTP", { severity = "error" })
	bin("make", "telescope-fzf-native builds with make on first install")

	health.start("clipboard (vim.opt.clipboard = unnamedplus)")
	if vim.env.WAYLAND_DISPLAY and vim.env.WAYLAND_DISPLAY ~= "" then
		bin("wl-copy", "no Wayland clipboard provider; yanks won't reach the system clipboard", {
			advice = "apt install wl-clipboard",
		})
	elseif not (has_exe("xclip") or has_exe("xsel")) then
		health.warn("no X11 clipboard provider (xclip/xsel) — yanks won't reach the system clipboard")
	else
		health.ok("X11 clipboard provider present")
	end

	health.start("language toolchains")
	bin("node", "ts_ls/eslint (mason-installed) run on node")
	local venv = find_venv()
	if venv then
		health.info("python venv: " .. venv)
		local pyrefly = vim.fs.joinpath(venv, "bin", "pyrefly")
		if vim.fn.executable(pyrefly) == 1 then
			health.ok("pyrefly (venv): " .. pyrefly)
		elseif has_exe("pyrefly") then
			health.ok("pyrefly (PATH): " .. vim.fn.exepath("pyrefly"))
		else
			health.warn(
				"venv found but no pyrefly — Python type-checking is off in this project",
				"uv add --dev pyrefly"
			)
		end
	else
		health.info("no python venv here — pyrefly enablement follows $PATH (see config/lsp.lua)")
	end

	health.start("repo dev tooling (only needed when hacking on this config)")
	bin("stylua", "formatter; CI enforces stylua --check")
	bin("selene", "lua lint; the pre-commit hook skips without it, CI still enforces", {
		advice = "release binary from github.com/Kampfkarren/selene into ~/.local/bin, or cargo install selene",
	})
	bin("pre-commit", "commit-time hygiene hooks (pre-commit install once per clone)")
end

return M
