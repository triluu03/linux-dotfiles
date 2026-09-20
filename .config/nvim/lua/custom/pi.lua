---Neovim integration for the Pi terminal coding agent.
---
---The module owns a single persistent terminal buffer running `pi` and exposes
---helpers that mirror the Claude Code keymaps used elsewhere in this config.
local M = {}

---@class CustomPiConfig
---@field command string|string[] Command used to launch Pi.
---@field width number Width for the Pi side split. Fractions are treated as a percentage of columns.
---@field startup_delay_ms integer Delay before pasting into a newly-created terminal.

---@class CustomPiState
---@field buf integer|nil Terminal buffer handle.
---@field win integer|nil Terminal window handle.
---@field job integer|nil Terminal job/channel id.

---@type CustomPiConfig
local config = {
	command = { "pi" },
	width = 0.30,
	startup_delay_ms = 150,
}

---@type CustomPiState
local state = {
	buf = nil,
	win = nil,
	job = nil,
}

local augroup_name = "custom-pi"

---Show a Pi-specific notification with consistent titles.
---@param message string Message to display.
---@param level integer|nil vim.log.levels value.
local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, { title = "Pi" })
end

---Return whether a buffer handle is live.
---@param bufnr integer|nil Buffer handle to check.
---@return boolean is_valid True when the buffer can still be used.
local function is_valid_buffer(bufnr)
	return bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr)
end

---Return whether a window handle is live.
---@param win integer|nil Window handle to check.
---@return boolean is_valid True when the window can still be used.
local function is_valid_window(win)
	return win ~= nil and vim.api.nvim_win_is_valid(win)
end

---Return whether the tracked Pi terminal job is still running.
---@return boolean is_running True when the terminal process can receive input.
local function is_job_running()
	return state.job ~= nil and vim.fn.jobwait({ state.job }, 0)[1] == -1
end

---Resolve the configured split width for the current editor size.
---@return integer width Window width in columns.
local function resolve_width()
	if config.width >= 1 then
		return math.floor(config.width)
	end

	-- Keep the pane usable on narrow terminals while still honoring percentages.
	return math.max(40, math.floor(vim.o.columns * config.width))
end

---Return the command executable when the command is an argv table.
---@return string|nil executable Executable name/path, or nil for shell-string commands.
local function command_executable()
	return type(config.command) == "table" and config.command[1] or nil
end

---Validate that the configured Pi command can be started.
---@return boolean is_valid True when the command passes local validation.
local function validate_command()
	local executable = command_executable()
	if executable == nil or vim.fn.executable(executable) == 1 then
		return true
	end

	notify(
		string.format(
			"Could not start Pi: executable '%s' was not found. Install @earendil-works/pi-coding-agent or configure custom.pi.setup({ command = ... }).",
			executable
		),
		vim.log.levels.ERROR
	)
	return false
end

---Reset all tracked state when the terminal buffer is destroyed.
local function reset_state()
	state.buf = nil
	state.win = nil
	state.job = nil
end

---Close the Pi window without killing the running terminal job.
local function close_window()
	if not is_valid_window(state.win) then
		state.win = nil
		return
	end

	local ok, err = pcall(vim.api.nvim_win_close, state.win, true)
	state.win = nil
	if not ok then
		notify(string.format("Failed to close Pi window: %s", err), vim.log.levels.ERROR)
	end
end

---Create and start a fresh Pi terminal buffer in the current window.
---@return boolean did_start True when the terminal job was started successfully.
local function start_terminal_buffer()
	if not validate_command() then
		return false
	end

	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(0, bufnr)
	vim.bo[bufnr].bufhidden = "hide"

	local ok, job = pcall(vim.fn.jobstart, config.command, {
		term = true,
		cwd = vim.fn.getcwd(),
		on_exit = function(job_id, code)
			-- Schedule UI cleanup so the terminal callback can finish before its window is closed.
			vim.schedule(function()
				if state.job ~= job_id then
					return
				end

				state.job = nil
				if code ~= 0 then
					notify(string.format("Pi exited with code %s.", code), vim.log.levels.WARN)
				end
				close_window()
			end)
		end,
	})

	if not ok or job <= 0 then
		notify(
			string.format("Failed to start Pi terminal with command: %s", vim.inspect(config.command)),
			vim.log.levels.ERROR
		)
		return false
	end

	state.buf = bufnr
	state.job = job
	vim.bo[bufnr].filetype = "pi"
	vim.b[bufnr].custom_pi_terminal = true
	return true
end

---Place the existing Pi buffer in the current window, or start a new one.
---@return boolean is_ready True when the current window contains a live Pi terminal.
local function attach_or_start_terminal()
	if is_valid_buffer(state.buf) and is_job_running() then
		vim.api.nvim_win_set_buf(0, state.buf)
		return true
	end

	return start_terminal_buffer()
end

---Open the Pi side split, optionally focusing it.
---@param focus boolean Whether to leave focus in the Pi terminal.
---@return boolean is_ready True when Pi is open and ready for input.
local function open_window(focus)
	local origin_win = vim.api.nvim_get_current_win()

	if is_valid_window(state.win) then
		vim.api.nvim_set_current_win(state.win)
		local is_ready = attach_or_start_terminal()
		if not focus and is_valid_window(origin_win) then
			vim.api.nvim_set_current_win(origin_win)
		end
		if focus then
			vim.cmd.startinsert()
		end
		return is_ready
	end

	vim.cmd("botright vertical split")
	state.win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_width(state.win, resolve_width())

	local is_ready = attach_or_start_terminal()
	if not focus and is_valid_window(origin_win) then
		vim.api.nvim_set_current_win(origin_win)
	end
	if focus then
		vim.cmd.startinsert()
	end
	return is_ready
end

---Send raw bytes to the Pi terminal channel.
---@param bytes string Bytes to send to the terminal.
---@param delay_ms integer|nil Delay before sending, useful immediately after startup.
local function send_bytes(bytes, delay_ms)
	local sender = function()
		if not is_job_running() then
			notify("Cannot send to Pi: the terminal job is not running.", vim.log.levels.ERROR)
			return
		end

		vim.api.nvim_chan_send(state.job, bytes)
	end

	if delay_ms and delay_ms > 0 then
		vim.defer_fn(sender, delay_ms)
		return
	end

	sender()
end

---Paste text into the Pi editor using bracketed paste to preserve newlines.
---@param text string Text to paste.
---@param submit boolean Whether to submit the editor after pasting.
---@param delay_ms integer|nil Delay before sending.
local function paste_to_pi(text, submit, delay_ms)
	local normalized = text:gsub("\r\n", "\n"):gsub("\r", "\n")
	local enter = submit and "\r" or ""
	send_bytes("\27[200~" .. normalized .. "\27[201~" .. enter, delay_ms)
end

---Return a display path for the current buffer, preferring cwd-relative paths.
---@param file_path string Absolute file path.
---@return string display_path Path suitable for showing/sending to Pi.
local function to_display_path(file_path)
	local relative_path = vim.fn.fnamemodify(file_path, ":.")
	return relative_path ~= "" and relative_path or file_path
end

---Format a Pi `@file` reference, quoting paths that contain whitespace.
---@param file_path string Absolute file path.
---@param line_start integer|nil First line to attach, or nil for the full file.
---@param line_end integer|nil Last line to attach, or nil for the full file.
---@return string reference Text that can be pasted into Pi's editor.
local function format_file_reference(file_path, line_start, line_end)
	local display_path = to_display_path(file_path)
	local line_suffix = ""
	if line_start ~= nil and line_end ~= nil then
		-- Use GitHub-style line anchors because they are the common `@file#Lx-Ly` convention.
		line_suffix = line_start == line_end and string.format("#L%s", line_start)
			or string.format("#L%s-L%s", line_start, line_end)
	end

	if display_path:match("%s") or display_path:find('"', 1, true) then
		local escaped = display_path:gsub("\\", "\\\\"):gsub('"', '\\"')
		return '@"' .. escaped .. '"' .. line_suffix .. " "
	end

	return "@" .. display_path .. line_suffix .. " "
end

---Return the current buffer path or report a contextual validation error.
---@return string|nil file_path Absolute file path when the current buffer is file-backed.
local function current_file_path()
	local file_path = vim.api.nvim_buf_get_name(0)
	if file_path == "" then
		notify(
			"Cannot add buffer to Pi: current buffer has no file name. Save it first or switch to a file-backed buffer.",
			vim.log.levels.ERROR
		)
		return nil
	end

	if vim.fn.filereadable(file_path) ~= 1 then
		notify(string.format("Cannot add buffer to Pi: file is not readable: %s", file_path), vim.log.levels.ERROR)
		return nil
	end

	return file_path
end

---Return the line range from the latest visual selection.
---@return integer|nil line_start First selected line, or nil when marks are unavailable.
---@return integer|nil line_end Last selected line, or nil when marks are unavailable.
local function visual_selection_line_range()
	local start_line = vim.fn.getpos("'<")[2]
	local end_line = vim.fn.getpos("'>")[2]
	if start_line <= 0 or end_line <= 0 then
		notify("Cannot attach selection to Pi: visual selection marks are unavailable.", vim.log.levels.ERROR)
		return nil, nil
	end

	return math.min(start_line, end_line), math.max(start_line, end_line)
end

---Toggle the Pi terminal side panel.
function M.toggle()
	if is_valid_window(state.win) then
		close_window()
		return
	end

	open_window(true)
end

---Open and focus the Pi terminal side panel.
function M.focus()
	open_window(true)
end

---Paste the current file as an `@file` reference into Pi.
function M.add_current_buffer()
	local file_path = current_file_path()
	if file_path == nil then
		return
	end

	local had_running_job = is_job_running()
	if not open_window(false) then
		return
	end

	local delay_ms = had_running_job and 0 or config.startup_delay_ms
	paste_to_pi(format_file_reference(file_path), false, delay_ms)
	notify(string.format("Added %s to Pi.", to_display_path(file_path)))
end

---Paste the current visual selection as an `@file#Lx-Ly` reference without submitting it.
function M.send_visual_selection()
	local mode = vim.api.nvim_get_mode().mode
	if mode == "v" or mode == "V" or mode == "\22" then
		-- Visual marks are finalized only after Visual mode exits, so defer the real send.
		local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
		vim.api.nvim_feedkeys(esc, "i", true)
		vim.schedule(M.send_visual_selection)
		return
	end

	local file_path = current_file_path()
	local line_start, line_end = visual_selection_line_range()
	if file_path == nil or line_start == nil or line_end == nil then
		return
	end

	local had_running_job = is_job_running()
	if not open_window(false) then
		return
	end

	local delay_ms = had_running_job and 0 or config.startup_delay_ms
	paste_to_pi(format_file_reference(file_path, line_start, line_end), false, delay_ms)
	notify(string.format("Attached %s#L%s-L%s to Pi.", to_display_path(file_path), line_start, line_end))
end

---Install Pi keymaps and lifecycle autocmds.
---@param opts CustomPiConfig|nil Optional configuration overrides.
function M.setup(opts)
	config = vim.tbl_deep_extend("force", config, opts or {})

	local augroup = vim.api.nvim_create_augroup(augroup_name, { clear = true })
	vim.api.nvim_create_autocmd("BufWipeout", {
		group = augroup,
		callback = function(event)
			if event.buf == state.buf then
				reset_state()
			end
		end,
	})
	vim.api.nvim_create_autocmd("WinClosed", {
		group = augroup,
		callback = function(event)
			if tonumber(event.match) == state.win then
				state.win = nil
			end
		end,
	})
	vim.api.nvim_create_autocmd("WinEnter", {
		group = augroup,
		callback = function(event)
			local entered_buf = event.buf

			-- Defer the mode change so temporary visits used for background sends can return first.
			vim.schedule(function()
				local is_pi_window = is_valid_window(state.win)
					and vim.api.nvim_get_current_win() == state.win
					and entered_buf == state.buf
				if not is_pi_window or not is_job_running() or vim.api.nvim_get_mode().mode == "t" then
					return
				end

				vim.cmd.startinsert()
			end)
		end,
	})

	-- Toggling Pi claims the shared `<leader>a{f,b,s}` keys away from Claude Code.
	vim.keymap.set("n", "<leader>ap", function()
		require("custom.agent_switch").activate_pi()
		M.toggle()
	end, { desc = "Toogle Pi", silent = true })
end

return M
