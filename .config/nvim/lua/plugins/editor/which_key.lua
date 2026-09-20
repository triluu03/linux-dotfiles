---Lazy plugin specification for which-key.nvim.
return { -- Useful plugin to show you pending keybinds.
	"folke/which-key.nvim",
	event = "VimEnter", -- Sets the loading event to 'VimEnter'
	opts = {
		-- delay between pressing a key and opening which-key (milliseconds)
		-- this setting is independent of vim.o.timeoutlen
		delay = 0,
		icons = {
			-- set icon mappings to true if you have a Nerd Font
			mappings = vim.g.have_nerd_font,
			-- If you are using a Nerd Font: set icons.keys to an empty table which will use the
			-- default which-key.nvim defined Nerd Font icons, otherwise define a string table
			keys = vim.g.have_nerd_font and {} or {
				Up = "<Up> ",
				Down = "<Down> ",
				Left = "<Left> ",
				Right = "<Right> ",
				C = "<C-…> ",
				M = "<M-…> ",
				D = "<D-…> ",
				S = "<S-…> ",
				CR = "<CR> ",
				Esc = "<Esc> ",
				ScrollWheelDown = "<ScrollWheelDown> ",
				ScrollWheelUp = "<ScrollWheelUp> ",
				NL = "<NL> ",
				BS = "<BS> ",
				Space = "<Space> ",
				Tab = "<Tab> ",
				F1 = "<F1>",
				F2 = "<F2>",
				F3 = "<F3>",
				F4 = "<F4>",
				F5 = "<F5>",
				F6 = "<F6>",
				F7 = "<F7>",
				F8 = "<F8>",
				F9 = "<F9>",
				F10 = "<F10>",
				F11 = "<F11>",
				F12 = "<F12>",
			},
		},

		-- Document existing key chains
		spec = {
			{ "<leader>s", group = "[S]earch" },
			{ "<leader>t", group = "[T]oggle" },
			{ "<leader>d", group = "[D]ebug" },
			-- Iron keymap description
			{ "<leader>r", group = "I[R]on" },
			{ "<leader>rr", group = "Toggle Repl" },
			{ "<leader>rv", group = "Toggle Repl [V]ertical" },
			{ "<leader>rh", group = "Iron [H]ide" },
			{ "<leader>rR", group = "[R]estart Repl" },
			{ "<leader>rs", group = "[S]end to Repl" },
			{ "<leader>rf", group = "Send [F]ile" },
			{ "<leader>rl", group = "Send [L]ine" },
			{ "<leader>rp", group = "Send [P]aragraph" },
			{ "<leader>ru", group = "Send [U]ntil Cursor" },
			{ "<leader>rm", group = "Send [M]ark" },
			{ "<leader>rb", group = "Send Code [B]lock" },
			{ "<leader>mc", group = "Iron [M]ark" },
			{ "<leader>md", group = "[M]ark [D]elete" },
			{ "<leader>ri<leader>", group = "I[R]on [I]nterrupt" },
			{ "<leader>rq", group = "Iron [Q]uit" },
			{ "<leader>rc", group = "Iron [C]lear" },
			-- End Iron Keymap description
			{ "<leader>p", group = "Copy [P]ath" },
			{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
		},
	},
}
