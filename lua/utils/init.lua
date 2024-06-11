local M = {}

-- The end column when using visual line mode and visual mode returns a different value
-- TODO change function to remove extra lines around query and return the true end column
-- regardless if using visual mode or visual line mode.
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

return M
