-- https://github.com/b0o/SchemaStore.nvim
-- Bundles the schemastore.org JSON/YAML schema catalog so jsonls and yamlls
-- validate + complete known files (package.json, tsconfig, GitHub Actions,
-- docker-compose, etc). Wired into both servers in lua/config/lsp.lua via
-- require("schemastore").json.schemas() / .yaml.schemas().
return {
	"b0o/SchemaStore.nvim",
	lazy = true,
	version = false, -- track the latest schema catalog, not a pinned release
}
