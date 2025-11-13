-- https://github.com/nvimdev/galaxyline.nvim
-- Status line plugin

return { "kyazdani42/nvim-web-devicons", {
	"NTBBloodbath/galaxyline.nvim",
	config = function()
		require("galaxyline.themes.eviline")
	end,
	requires = { "kyazdani42/nvim-web-devicons", opt = true }
} }
