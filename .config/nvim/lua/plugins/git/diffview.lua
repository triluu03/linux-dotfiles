---Lazy plugin specification for diffview.
return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
	config = function()
		vim.keymap.set("n", "<leader>gd", function()
			vim.cmd("DiffviewOpen origin/main")
		end, { desc = "Diffview: compare with main" })
		vim.keymap.set("n", "<leader>gc", function()
			vim.cmd("DiffviewClose")
		end, { desc = "Diffview: close the view" })
	end,
}
