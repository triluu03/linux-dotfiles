---Lazy plugin specification for Kanagawa.
return {
	"rebelot/kanagawa.nvim",
	name = "kanagawa",
	priority = 1000, -- Make sure to load this before all the other start plugins.
	config = function()
		---@diagnostic disable-next-line: missing-fields
		require("kanagawa").setup({
			commentStyle = { italic = true },
			theme = "wave",
		})

		-- Load the colorscheme here.
		vim.cmd.colorscheme("kanagawa")
	end,
}
