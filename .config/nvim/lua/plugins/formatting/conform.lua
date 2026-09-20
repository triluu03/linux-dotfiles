return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	opts = {
		formatters_by_ft = {
			-- Elixir built-in formatter
			elixir = { "mix" },
			heex = { "mix" },
			-- JavaScript/TypeScript Biome formatter
			javascript = { "biome", "biome-organize-imports" },
			javascriptreact = { "biome", "biome-organize-imports" },
			typescript = { "biome", "biome-organize-imports" },
			typescriptreact = { "biome", "biome-organize-imports" },
			--
			vue = { "prettierd" },
			css = { "prettierd" },
			scss = { "prettierd" },
			--
			html = { "prettierd" },
			json = { "prettierd" },
			json5 = { "prettierd" },
			jsonc = { "prettierd" },
			yaml = { "prettierd" },
			--
			markdown = { "prettierd" },
			["markdown.mdx"] = { "prettierd" },
			--
			lua = { "stylua" },
			python = { "ruff_fix", "ruff_format" },
			rust = { "rustfmt" },
		},
		formatters = {
			ruff_fix = {
				append_args = { "--extend-select", "I" },
			},
			rustfmt = { -- Use rustup's project-aware proxy instead of another rustfmt injected into PATH.
				command = vim.fn.expand("~/.cargo/bin/rustfmt"),
			},
		},
		format_on_save = {
			-- These options will be passed to conform.format()
			timeout_ms = 1000,
			lsp_format = "never",
		},
	},
}
