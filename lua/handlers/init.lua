local M = {}
local managers = require("managers")
local result_messages = require("results.messages")
function M.connection_complete(err, result, ctx, config)
	if err then
		vim.notify(err)
		return result, err
	end
	if result.errorMessage then
		vim.notify(result.errorMessage)
		return result, err
	end
	local connection_id = result.connectionId
	local owner_uri = result.ownerUri
	local buffer_manager = managers.get_manager_by_owner_uri(owner_uri)
	buffer_manager.connection_id = connection_id
	buffer_manager.is_connected = true

	vim.print("Succesfully connected to connection_id: " .. connection_id)
	return result, err
end

function M.query_complete(err, result, ctx, config)
	if result.batchSummaries and result.batchSummaries[1].hasError == false then
		local buffer_manager = managers.get_manager_by_owner_uri(result.ownerUri)
		buffer_manager.result_id = buffer_manager.result_id + 1
		vim.print("Query result is ready")
	else
		vim.print("Query failed")
		vim.print(result.batchSummaries[1].hasError)
		return
	end

	if err then
		vim.print(err)
	end
end

function M.query_message(err, result, ctx, config)
	if result.message.message then
		result_messages.write_message(result.message.message, result.ownerUri)
	end

	if err then
		vim.print(err)
	end
end

return M
