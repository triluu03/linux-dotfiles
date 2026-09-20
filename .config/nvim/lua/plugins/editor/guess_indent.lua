---Lazy plugin specification for guess indent.
return {
	"NMAC427/guess-indent.nvim", -- Detect tabstop and shiftwidth automatically
	lazy = false,
	config = function()
		require("guess-indent").setup({})
	end,
}
