local Split = require("nui.split")
local connections = require("connections")
local managers = require("managers")
local NuiTree = require("nui.tree")

local M = {}
local buffer
local connection
M.bufnr = nil
M.session_id = nil
M.expanding_node = nil
---@type NuiTree
M.tree = nil

function M.create_oe()
	local client_id = managers.client_id

	if not client_id then
		vim.print("Sqltoolsservice client not started.")
		return
	end

	buffer = Split({
		relative = "win",
		position = "left",
		size = "20%",
	})

	M.bufnr = buffer.bufnr

	vim.api.nvim_set_option_value("ft", "msoe", {
		buf = M.bufnr,
	})

	vim.lsp.buf_attach_client(M.bufnr, client_id)

	M.choose_connection() -- TODO Comment this out when choose connection functionality is added

	buffer:mount()

	return M.bufnr
end

---@return NuiSplit
function M.get_buffer()
	return buffer
end

function M.get_connection()
	return connection
end

--TODO Add functionality to choose connection
function M.choose_connection()
	connection = connections.get_connection("Prod")
	return connection
end

return M
