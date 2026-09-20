---Lazy plugin specification for iron.
return {
	"Vigemus/iron.nvim",
	config = function()
		local iron = require("iron.core")
		local common = require("iron.fts.common")
		local view = require("iron.view")

		iron.setup({
			config = {
				-- Whether a repl should be discarded or not
				scratch_repl = true,
				-- Your repl definitions come here
				repl_definition = {
					sh = {
						-- Can be a table or a function that
						-- returns a table (see below)
						command = { "zsh" },
					},
					python = {
						command = { "python3" }, -- or { "ipython", "--no-autoindent" }
						format = common.bracketed_paste_python,
						block_dividers = { "# %%", "#%%" },
					},
				},
				-- set the file type of the newly created repl to ft
				-- bufnr is the buffer id of the REPL and ft is the filetype of the
				-- language being used for the REPL.
				repl_filetype = function(bufnr, ft)
					return ft
					-- or return a string name such as the following
					-- return "iron"
				end,
				-- How the repl window will be displayed
				-- See below for more information
				-- repl_open_cmd = view.bottom(40),

				-- repl_open_cmd can also be an array-style table so that multiple
				-- repl_open_commands can be given.
				-- When repl_open_cmd is given as a table, the first command given will
				-- be the command that `IronRepl` initially toggles.
				-- Moreover, when repl_open_cmd is a table, each key will automatically
				-- be available as a keymap (see `keymaps` below) with the names
				-- toggle_repl_with_cmd_1, ..., toggle_repl_with_cmd_k
				-- For example,
				--
				repl_open_cmd = {
					view.split.vertical.rightbelow("%45"), -- cmd_1: open a repl to the right
					view.split.rightbelow("%25"), -- cmd_2: open a repl below
				},
			},
			-- Iron doesn't set keymaps by default anymore.
			-- You can set them here or manually add keymaps to the functions in iron.core
			keymaps = {
				toggle_repl = "<leader>rr", -- toggles the repl open and closed.
				-- If repl_open_command is a table as above, then the following keymaps are
				-- available
				toggle_repl_with_cmd_1 = "<leader>rv",
				-- toggle_repl_with_cmd_2 = "<leader>rh",
				restart_repl = "<leader>rR", -- calls `IronRestart` to restart the repl
				send_motion = "<leader>rs",
				visual_send = "<leader>rs",
				send_file = "<leader>rf",
				send_line = "<leader>rl",
				send_paragraph = "<leader>rp",
				send_until_cursor = "<leader>ru",
				send_mark = "<leader>rm",
				send_code_block = "<leader>rb",
				send_code_block_and_move = "<leader>rn",
				mark_motion = "<leader>mc",
				mark_visual = "<leader>mc",
				remove_mark = "<leader>md",
				-- cr = "<leader>s<cr>",
				interrupt = "<leader>ri<leader>",
				exit = "<leader>rq",
				clear = "<leader>rc",
			},
			-- If the highlight is on, you can change how it looks
			-- For the available options, check nvim_set_hl
			highlight = {
				italic = true,
			},
			ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
		})

		-- One can always use the default commands from vim directly
		repl_open_cmd = "vertical botright 80 split"

		-- But iron provides some utility functions to allow you to declare that dynamically,
		-- based on editor size or custom logic, for example.

		-- Vertical 50 columns split
		-- Split has a metatable that allows you to set up the arguments in a "fluent" API
		-- you can write as you would write a vim command.
		-- It accepts:
		--   - vertical
		--   - leftabove/aboveleft
		--   - rightbelow/belowright
		--   - topleft
		--   - botright
		-- They'll return a metatable that allows you to set up the next argument
		-- or call it with a size parameter
		repl_open_cmd = view.split.vertical.botright(50)

		-- If the supplied number is a fraction between 1 and 0,
		-- it will be used as a proportion
		repl_open_cmd = view.split.vertical.botright(0.61903398875)

		-- The size parameter can be a number, a string or a function.
		-- When it's a *number*, it will be the size in rows/columns
		-- If it's a *string*, it requires a "%" sign at the end and is calculated
		-- as a percentage of the editor size
		-- If it's a *function*, it should return a number for the size of rows/columns

		repl_open_cmd = view.split("40%")

		-- You can supply custom logic
		-- to determine the size of your
		-- repl's window
		repl_open_cmd = view.split.topleft(function()
			if some_check then
				return vim.o.lines * 0.4
			end
			return 20
		end)

		-- An optional set of options can be given to the split function if one
		-- wants to configure the window behavior.
		-- Note that, by default `winfixwidth` and `winfixheight` are set
		-- to `true`. If you want to overwrite those values,
		-- you need to specify the keys in the option map as the example below

		repl_open_cmd = view.split("40%", {
			winfixwidth = false,
			winfixheight = false,
			-- any window-local configuration can be used here
			number = true,
		})

		-- iron also has a list of commands, see :h iron-commands for all available commands
		-- vim.keymap.set("n", "<leader>rf", "<cmd>IronFocus<cr>")
		vim.keymap.set("n", "<leader>rh", "<cmd>IronHide<cr>")
	end,
}
