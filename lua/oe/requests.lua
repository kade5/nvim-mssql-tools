local managers = require("managers")
local oe_manager = require("oe.manager")

local M = {}
function M.create_session(connection, on_attempt)
	local client_id = managers.client_id
	if not client_id then
		print("Client was not started. No id generated.")
		return
	end
	local lsp = vim.lsp.get_client_by_id(client_id)
	if lsp == nil then
		print("Client closed. ID: " .. managers.client_id)
		return
	end

	if not connection then
		vim.print("No connection selected")
		return
	end

	lsp.request("objectexplorer/createsession", {
		options = connection,
	}, function()
		if on_attempt then
			on_attempt()
		end
	end)
end

function M.expand_node_request(node, on_attempt)
	vim.print("Entered expand node request")
	local client_id = managers.client_id
	if not client_id then
		print("Client was not started. No id generated.")
		return
	end
	local lsp = vim.lsp.get_client_by_id(client_id)
	if lsp == nil then
		print("Client has already been closed. ID: " .. managers.client_id)
		return
	end
	local session_id = oe_manager.session_id
	if not session_id then
		vim.print("An object explorer session has not been started")
	end

	if oe_manager.expanding_node then
		vim.print("A node is already expanding")
	end

	oe_manager.expanding_node = node:get_id()

	lsp.request("objectexplorer/expand", {

		sessionId = session_id,
		nodePath = node.data.nodePath,
	}, function()
		if on_attempt then
			on_attempt()
		end
	end)
end

function M.script_as(options, on_success)
	vim.print("Entered expand node request")
	vim.print(options)
	local client_id = managers.client_id
	if not client_id then
		print("Client was not started. No id generated.")
		return
	end
	local lsp = vim.lsp.get_client_by_id(client_id)
	if lsp == nil then
		print("Client has already been closed. ID: " .. managers.client_id)
		return
	end

	lsp.request("scripting/script", options, function(err, result)
		vim.print("Entering script_as")
		if err then
			vim.print(err)
		end
		vim.print(result)
		if on_success then
			on_success(result)
		end
	end)
end

return M
