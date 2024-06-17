local client = require("sqltoolsservice.client")
local managers = require("managers")
local utils = require("utils")
local M = {}

function M.connect_to_database(on_connection_attempt)
	local client_id = client.get_client_id()
	if not client_id then
		print("Client was not started. No id generated.")
		return
	end
	local lsp = vim.lsp.get_client_by_id(client_id)
	if lsp == nil then
		print("Client was not started. ID: " .. client.client_id)
		return
	end
	local manager = managers.get_manager(vim.api.nvim_get_current_buf())
	local buffer_uri = manager.owner_uri

	if not manager.connection then
		vim.print("No connection selected")
		return
	end

	lsp.request("connection/connect", {
		ownerUri = buffer_uri,
		connection = {
			options = manager.connection,
		},
	}, function()
		if on_connection_attempt then
			on_connection_attempt()
		end
	end)
end

function M.execute_query_doc(on_query_attempt)
	local client_id = client.get_client_id()
	if not client_id then
		print("Client was not started. No id generated.")
		return
	end
	local lsp = vim.lsp.get_client_by_id(client_id)
	if lsp == nil then
		print("Client was not started. ID: " .. client.client_id)
		return
	end
	local manager = managers.get_manager(vim.api.nvim_get_current_buf())
	local buffer_uri = manager.owner_uri

	lsp.request("query/executeDocumentSelection", {
		ownerUri = buffer_uri,
	}, function()
		if on_query_attempt then
			on_query_attempt()
		end
	end)
end

function M.execute_query_partial(document_partial, on_query_attempt)
	local client_id = client.get_client_id()
	if not client_id then
		print("Client was not started. No id generated.")
		return
	end
	local lsp = vim.lsp.get_client_by_id(client_id)
	if lsp == nil then
		print("Client was not started. ID: " .. client.client_id)
		return
	end
	local manager = managers.get_manager(vim.api.nvim_get_current_buf())
	local buffer_uri = manager.owner_uri

	vim.print(document_partial)

	lsp.request("query/executeDocumentSelection", {
		ownerUri = buffer_uri,
		querySelection = document_partial,
	}, function()
		if on_query_attempt then
			on_query_attempt()
		end
	end)
end

--Currently only works well when using visual line mode. Doesn't work well for visual mode
--Selection only works if only the query is selected, not any extra line breaks.
function M.execute_query_selection(on_query_attempt)
	M.execute_query_partial(utils.get_visual_selection(), on_query_attempt)
end

function M.cancel_query()
	local client_id = client.get_client_id()
	if not client_id then
		print("Client was not started. No id generated.")
		return
	end
	local lsp = vim.lsp.get_client_by_id(client_id)
	if lsp == nil then
		print("Client was not started. ID: " .. client.client_id)
		return
	end
	local manager = managers.get_manager(vim.api.nvim_get_current_buf())
	local buffer_uri = manager.owner_uri

	lsp.request("query/cancel", {
		ownerUri = buffer_uri,
	}, function(results)
		vim.print(results)
	end)
end

function M.refresh_intellisense()
	local client_id = client.get_client_id()
	if not client_id then
		print("Client was not started. No id generated.")
		return
	end
	local lsp = vim.lsp.get_client_by_id(client_id)
	if lsp == nil then
		print("Client was not started. ID: " .. client.client_id)
		return
	end
	local manager = managers.get_manager(vim.api.nvim_get_current_buf())
	local buffer_uri = manager.owner_uri

	lsp.request("textDocument/rebuildIntelliSense", {
		ownerUri = buffer_uri,
	}, function(results)
		vim.print(results)
	end)
end

function M.save_to_csv(csv_path, on_save)
	local client_id = client.get_client_id()
	if not client_id then
		print("Client was not started. No id generated.")
		return false, nil
	end
	local lsp = vim.lsp.get_client_by_id(client_id)
	if lsp == nil then
		print("Client was not started. ID: " .. client.client_id)
		return false, nil
	end
	local manager = managers.get_manager(vim.api.nvim_get_current_buf())
	local buffer_uri = manager.owner_uri

	return lsp.request("query/saveCsv", {

		includeHeaders = true,
		delimiter = ",",
		lineSeperator = nil,
		textIdentifier = '"',
		encoding = "utf-8",
		ownerUri = buffer_uri,
		resultSetIndex = 0,
		batchIndex = 0,
		filePath = csv_path,
	}, function()
		manager.result_file_path = csv_path
		if on_save then
			vim.print("Running after save " .. csv_path)
			on_save(csv_path)
		end
	end)
end

return M
