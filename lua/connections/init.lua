local M = {}

local connection_path = vim.fn.stdpath("data") .. "/mssql-tools"
local file_path = connection_path .. "/connections.json"
local connections

function M.read_connections()
	local file = io.open(file_path, "r")
	if not file then
		print("connections.json not found")
		return {}
	end
	local content = file:read("*a")
	file:close()

	local json_connections = vim.json.decode(content)
	if not json_connections then
		print("Error decoding JSON")
		return {}
	end
	connections = json_connections
	return json_connections
end

function M.get_connection(connection_name)
	if not connections then
		M.read_connections()
	end

	for _, connection in ipairs(connections) do
		if connection.databaseDisplayName == connection_name then
			return connection
		end
	end

	print("Connection " .. connection_name .. " not found.")
end

return M
