local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values

local M = {}

local live_multigrep = function(opts)
	opts = opts or {}
	opts.cwd = opts.cwd or vim.uv.cwd()

	local inverted = false
	local vimgrep_entry_maker = make_entry.gen_from_vimgrep(opts)
	local file_entry_maker = make_entry.gen_from_file(opts)
	local finder = finders.new_async_job({
		command_generator = function(prompt)
			if not prompt or prompt == "" then
				return nil
			end

			local pieces = vim.split(prompt, "  ")
			local search_text = pieces[1]
			inverted = vim.startswith(search_text, "!")
			if inverted then
				search_text = search_text:sub(2)
			end
			if inverted and search_text == "" then
				return nil
			end

			local args = { "rg" }
			if inverted then
				table.insert(args, "--files-without-match")
			end
			table.insert(args, "-e")
			table.insert(args, search_text)

			if pieces[2] then
				table.insert(args, "-g")
				table.insert(args, pieces[2])
			end

			return vim.list_extend(
				args,
				{ "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" }
			)
		end,
		entry_maker = function(line)
			-- Inverted searches return filenames instead of vimgrep-formatted matches.
			return inverted and file_entry_maker(line) or vimgrep_entry_maker(line)
		end,
		cwd = opts.cwd,
	})

	pickers
		.new(opts, {
			debounce = 100,
			prompt_title = "Multi Grep",
			finder = finder,
			previewer = conf.grep_previewer(opts),
			sorter = require("telescope.sorters").empty(),
		})
		:find()
end

M.setup = function()
	vim.keymap.set("n", "<leader>sg", live_multigrep, { desc = "[S]earch by [G]rep" })
end

return M
