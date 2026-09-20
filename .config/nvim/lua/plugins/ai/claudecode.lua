---Lazy plugin specification for claudecode.
return {
	"coder/claudecode.nvim",
	dependencies = { "folke/snacks.nvim" },
	config = true,
	keys = {
		{ "<leader>a", nil, desc = "AI/Claude Code/Pi" },
		-- Toggling Claude claims the shared `<leader>a{f,b,s}` keys away from Pi.
		{
			"<leader>ac",
			function()
				require("custom.agent_switch").activate_claude()
				vim.cmd("ClaudeCode")
			end,
			desc = "Toggle Claude",
		},
	},
}
