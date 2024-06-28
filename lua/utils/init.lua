local M = {}

-- The end column when using visual line mode and visual mode returns a different value
-- TODO change function to remove extra lines around query and return the true end column
-- regardless if using visual mode or visual line mode.
local icons = {
	Database = "",
	Folder = "󰉋",
	Table = "󰓫",
	View = "󱂔",
	StoredProcedure = "󱐁",
	TableValuedFunction = "󰡱",
	ScalarValuedFunction = "󰡱",
	Column = "󰠵",
}

function M.get_visual_selection()
	local start_pos = vim.fn.getcharpos("'<")
	local end_pos = vim.fn.getcharpos("'>")

	return {
		startLine = start_pos[2] - 1,
		startColumn = start_pos[3] - 1,
		endLine = end_pos[2] - 1,
		endColumn = end_pos[3],
	}
end

function M.create_and_save_buffer(text, window, filename)
	local bufrn = vim.api.nvim_create_buf(true, true)
	if not window then
		vim.print("No previous window")
		return
	end

	vim.api.nvim_win_set_buf(window, bufrn)

	local lines = {}
	for line in text:gmatch("([^\n]*)\n?") do
		table.insert(lines, line)
	end

	vim.api.nvim_buf_set_lines(bufrn, 0, -1, false, lines)

	vim.api.nvim_buf_call(bufrn, function()
		vim.cmd("write " .. filename)
	end)

	vim.api.nvim_buf_set_name(bufrn, filename)

	return bufrn
end

function M.get_icon(node)
	local icon = icons[node.nodeType]
	if not icon then
		return node.label
	end

	return icon .. " " .. node.label
end

return M
