---Lazy plugin specification for typescript tools.
return {
	"pmizio/typescript-tools.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	opts = {
		filetypes = {
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"vue",
		},
		settings = {
			tsserver_plugins = {
				"@vue/typescript-plugin",
			},
		},
	},
}
