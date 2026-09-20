---Shared keymap dispatcher for the AI agents that share `<leader>a*` keys.
---
---Pi and Claude Code both bind `<leader>af`/`<leader>ab`/`<leader>as`. Only one
---agent should own those keys at a time. Each agent's toggle keymap calls the
---matching `activate_*` function here first, which rebinds the shared keys to
---that agent before the agent itself toggles open.
local M = {}

---Bind the shared AI keymaps to Pi.
function M.activate_pi()
	local pi = require("custom.pi")
	vim.keymap.set("n", "<leader>af", pi.focus, { desc = "Pi: focus", silent = true })
	vim.keymap.set("n", "<leader>ab", pi.add_current_buffer, { desc = "Pi: add current buffer", silent = true })
	vim.keymap.set("v", "<leader>as", pi.send_visual_selection, { desc = "Pi: attach selection", silent = true })
end

---Bind the shared AI keymaps to Claude Code.
function M.activate_claude()
	vim.keymap.set("n", "<leader>af", "<cmd>ClaudeCodeFocus<cr>", { desc = "Claude: focus", silent = true })
	vim.keymap.set(
		"n",
		"<leader>ab",
		"<cmd>ClaudeCodeAdd %<cr>",
		{ desc = "Claude: add current buffer", silent = true }
	)
	vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "Claude: send selection", silent = true })

	vim.keymap.set("n", "<leader>ar", "<cmd>ClaudeCode --resume<cr>", { desc = "Resume Claude", silent = true })
	vim.keymap.set("n", "<leader>aC", "<cmd>ClaudeCode --continue<cr>", { desc = "Continue Claude", silent = true })
	vim.keymap.set("n", "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", { desc = "Accept diff", silent = true })
	vim.keymap.set("n", "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", { desc = "Deny diff", silent = true })

	-- Re-registered on every activate so re-toggling Claude refreshes the binding.
	local tree_augroup = vim.api.nvim_create_augroup("agent-switch-claude-tree", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = tree_augroup,
		pattern = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
		callback = function(event)
			vim.keymap.set(
				"n",
				"<leader>as",
				"<cmd>ClaudeCodeTreeAdd<cr>",
				{ desc = "Add file", buf = event.buf, silent = true }
			)
		end,
	})
end

return M
