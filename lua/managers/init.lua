local M = {}
local buffer_managers = {}

function M.new_manager(buffer_id, buffer_name)
	local buf_name
	local buf_id = buffer_id
	if not buffer_name then
		buf_name = "file://" .. vim.api.nvim_buf_get_name(buf_id)
	else
		buf_name = buffer_name
	end
	if buf_id == 0 then
		buf_id = vim.api.nvim_get_current_buf()
	end

	if not buf_name then
		vim.print("Buffer " .. buf_id .. " must have a name")
		return
	end
	local buffer_manager = {
		owner_uri = buf_name,
		is_connected = false,
		result_id = 0,
		connection = nil,
		connection_id = nil,
		result_file_path = nil,
	}
	buffer_managers[buf_id] = buffer_manager
	return buffer_manager
end

function M.get_manager(buffer_id)
	vim.print(buffer_managers)
	return buffer_managers[buffer_id]
end

function M.get_manager_by_owner_uri(owner_uri)
	for _, manager in ipairs(buffer_managers) do
		if manager.owner_uri == owner_uri then
			return manager
		end
	end
end

return M
