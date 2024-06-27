local Split = require("nui.split")
local M = {}

local message_managers = {}

local function create_autocommands()
	vim.api.nvim_create_autocmd("BufHidden", {
		callback = function(event)
			local bufnr = event.buf
			local manager = message_managers[bufnr]
			local num_wins = #vim.api.nvim_list_wins()

			if manager == nil or manager.buffer == nil or num_wins <= 2 then
				return
			end

			vim.api.nvim_win_hide(manager.buffer.winid)
		end,
	})
end

function M.new_message_manager(query_buffer, owner_uri)
	local buffer = Split({
		relative = "win",
		position = "bottom",
		size = "10%",
		enter = false,
	})

	local bufrn = buffer.bufnr

	vim.api.nvim_set_option_value("ft", "msmsg", {
		buf = bufrn,
	})

	message_managers[query_buffer] = {
		buffer = buffer,
		owner_uri = owner_uri,
		buffer_num = bufrn,
		win_id = nil,
	}

	create_autocommands()

	return bufrn
end

function M.start_new_messages(query_buffer, owner_uri)
	local manager = message_managers[query_buffer]
	local win_id = vim.api.nvim_get_current_win()

	if not manager then
		M.new_message_manager(query_buffer, owner_uri)
		manager = message_managers[query_buffer]
	end

	manager.win_id = win_id
	local bufrn = manager.buffer_num

	vim.bo[bufrn].modifiable = true

	--Clear all lines in the buffer
	vim.api.nvim_buf_set_lines(manager.buffer_num, 0, -1, false, {})
	vim.api.nvim_buf_set_lines(manager.buffer_num, 0, -1, false, { "Query Started" })
	vim.bo[bufrn].modifiable = false

	manager.buffer:mount()
end

function M.write_message(message, owner_uri)
	local manager = M.get_manager_by_uri(owner_uri)
	if not manager then
		vim.print("No result message available")
		return
	end

	local bufrn = manager.buffer_num

	local lines = {}
	for line in message:gmatch("([^\n]*)\n?") do
		table.insert(lines, line)
	end

	vim.bo[bufrn].modifiable = true
	vim.api.nvim_buf_set_lines(manager.buffer_num, -1, -1, false, lines)
	vim.bo[bufrn].modifiable = false
end

function M.get_manager_by_uri(owner_uri)
	for _, manager in pairs(message_managers) do
		if manager.owner_uri == owner_uri then
			return manager
		end
	end
end

return M
