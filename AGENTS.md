# AGENTS.md

## Repo Setup

1. Install Neovim (recommended 0.10+).  
2. Run `nvim` once – the repo will automatically install `lazy.nvim` and all plugins.  
3. Install Neovim LSP servers with `:Mason` inside Neovim.  
4. You can run the included playbook: `ansible-playbook -i localhost, ansible/nvim.yml` to set up system‑wide dependencies.

## Lua Project Layout

- `lua/init.lua` is the main entry point that loads `lua/config/lazy.lua` and all plugin configs.  
- All third‑party plugins are under `lua/plugins`; keep user‑written configs under `lua/config`.  
- `lua/config` contains modular configuration files for each plugin (e.g. `theme.lua`, `mason.lua`).  
- `lua/plugins/<plugin>.lua` holds the plugin’s configuration block used by `lazy.nvim`.

## Build/Lint/Test Commands

- **Formatting**: Run `stylua -s -w .` to format all Lua files. Use 2‑space indentation, spaces, no trailing whitespace.
- **Linting**: Check for code style issues and formatting errors.
- **Testing**: No dedicated test runner yet; plugins are tested via manual verification in Neovim.
- **Installation**: Run `nvim` once to trigger lazy.nvim plugin installation.

## Code Style Guidelines

- **Imports**: Use `require("module.name")`. Avoid other quoting styles or module.table patterns. Always require lazy.nvim configs at the top level of plugin files.
- **Formatting**: Run `stylua -s -w .` when making code changes. Configuration files should be separate per plugin where possible.
- **Indentation**: Use 2‑space indentation consistently throughout all Lua files.
- **Spacing**: No trailing whitespace, use spaces instead of tabs, separate logic with blank lines for readability.
- **Naming Conventions**:
  - Functions/variables: camelCase
  - Modules: PascalCase
  - Constants: UPPER_SNAKE_CASE
  - Configuration keys: camelCase
- **Error Handling**: Always use `pcall()` or `xpcall()` for potentially failing operations. Return the pattern `nil, err` from any function that may fail. Wrap init logic in error handlers.
- **Documentation**: Add brief LuaDoc comments at the top of modules and before public functions to explain purpose and usage.
- **Plugin Configs**: Keep plugin configurations isolated in `lua/plugins/<plugin>.lua` files. Use `lazy = true` for most plugins to delay loading.
- **LSP Setup**: Configure LSP servers via `lua/config/mason.lua` and register them in `lua/plugins/lsp.lua` using the `Mason` management pattern.
- **Tree-sitter**: Use consistent node patterns and avoid complex patterns without proper error handling.
- **Telescope**: Follow the telescope.nvim pattern for custom pickers and fuzzy finding configurations.

