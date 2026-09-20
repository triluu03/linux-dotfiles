---Lazy plugin specification for markview.
-- Markdown preview plugin
return {
	"OXY2DEV/markview.nvim",
	lazy = false,
	opts = {
		preview = {
			filetypes = { "markdown", "codecompanion" },
			ignore_buftypes = {},
		},
	},
}
