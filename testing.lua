local lsp_log = require("vim.lsp.log")
local server_name = vim.env.SECRET_SERVER_NAME
local username = vim.env.SECRET_DB_USER
local db_name = vim.env.SECRET_DB_NAME
local password = vim.env.SECRET_DB_PASS
local connection_id = nil
local buffer_uri = nil
local query_id = 0
local tmp_dir = "/var/tmp/mssql-results/"

local query_complete = function(err, result, ctx, config)
	if result then
		vim.print(result)
		vim.print("Query returned succesfully")
	end

	if err then
		vim.print(err)
	end
end

local query_message = function(err, result, ctx, config)
	vim.print("Query message: ")
	if result.message.message then
		vim.print(result.message.message)
	end

	if err then
		vim.print(err)
	end
end

local connection_complete = function(err, result, ctx, config)
	if result then
		vim.print(err)
		vim.print(result)
		vim.print(ctx)
	end
	if err then
		vim.notify(err)
		return result, err
	end
	if result.errorMessage then
		vim.notify(result.errorMessage)
		return result, err
	end
	connection_id = result.connectionId
	vim.print("connection_id: " .. connection_id)
	return result, err
end

lsp_log.set_level("DEBUG")
local client_id = vim.lsp.start_client({
	name = "mssql-lsp",
	-- cmd = { '/home/zeke/.vscode/extensions/ms-mssql.mssql-1.22.0/sqltoolsservice/4.10.1.1/Ubuntu16/MicrosoftSqlToolsServiceLayer' },
	cmd = { "/home/zeke/Projects/sqltoolsservice/MicrosoftSqlToolsServiceLayer" },
	handlers = {
		["connection/complete"] = connection_complete,
		["query/complete"] = query_complete,
		["query/message"] = query_message,
	},
	-- capabilities = capabilities,
	settings = {
		mssql = {
			azureActiveDirectory = "AuthCodeGrant",
			logDebugInfo = true,
			maxRecentConnections = 5,
			messagesDefaultOpen = true,
			resultsFontFamily = "-apple-system,BlinkMacSystemFont,Segoe WPC,Segoe UI,HelveticaNeue-Light,Ubuntu,Droid Sans,sans-serif",
			resultsFontSize = 13,
			saveAsCsv = {
				includeHeaders = true,
				delimiter = ",",
				lineSeparator = nil,
				textIdentifier = '"',
				encoding = "utf-8",
			},
			copyIncludeHeaders = false,
			copyRemoveNewLine = true,
			showBatchTime = false,
			splitPaneSelection = "next",
			enableSqlAuthenticationProvider = true,
			enableConnectionPooling = true,
			format = {
				alignColumnDefinitionsInColumns = false,
				datatypeCasing = "uppercase",
				keywordCasing = "uppercase",
				placeCommasBeforeNextStatement = false,
				placeSelectStatementReferencesOnNewLine = false,
			},
			applyLocalization = false,
			intelliSense = {
				enableIntelliSense = true,
				enableErrorChecking = true,
				enableSuggestions = true,
				enableQuickInfo = true,
				lowerCaseSuggestions = false,
			},
			persistQueryResultTabs = false,
			enableQueryHistoryCapture = true,
			enableQueryHistoryFeature = true,
			tracingLevel = "Verbose",
			piiLogging = false,
			logRetentionMinutes = 10080,
			logFilesRemovalLimit = 100,
			query = {
				displayBitAsNumber = true,
				maxCharsToStore = 65535,
				maxXmlCharsToStore = 2097152,
				rowCount = 0,
				textSize = 2147483647,
				executionTimeout = 0,
				noCount = false,
				noExec = false,
				parseOnly = false,
				arithAbort = true,
				statisticsTime = false,
				statisticsIO = false,
				xactAbortOn = false,
				transactionIsolationLevel = "READ COMMITTED",
				deadlockPriority = "Normal",
				lockTimeout = -1,
				queryGovernorCostLimit = -1,
				ansiDefaults = false,
				quotedIdentifier = true,
				ansiNullDefaultOn = true,
				implicitTransactions = false,
				cursorCloseOnCommit = false,
				ansiPadding = true,
				ansiWarnings = true,
				ansiNulls = true,
				alwaysEncryptedParameterization = false,
			},
			queryHistoryLimit = 20,
			ignorePlatformWarning = false,
			objectExplorer = {
				groupBySchema = false,
				expandTimeout = 45,
			},
		},
	},
})

if not client_id then
	vim.notify("No client found")
	return
end

Mssql_rebuild_intellisense = function()
	local client = vim.lsp.get_client_by_id(client_id)
	if client == nil then
		vim.notify("No client with given client id" .. client_id)
		return
	end
	client.request("intellisense/rebuild", {
		ownerUri = buffer_uri,
	}, function(results)
		vim.print(results)
	end)
end

Mssql_execute_query_doc = function()
	local client = vim.lsp.get_client_by_id(client_id)
	if client == nil then
		vim.notify("No client with given client id" .. client_id)
		return
	end
	client.request("query/executeDocumentSelection", {
		ownerUri = buffer_uri,
	}, function(err, result, ctx, config)
		vim.print(result)
		query_id = query_id + 1
	end)
end

Mssql_cancel_query = function()
	local client = vim.lsp.get_client_by_id(client_id)
	if client == nil then
		vim.notify("No client with given client id" .. client_id)
		return
	end
	client.request("query/cancel", {
		ownerUri = buffer_uri,
	}, function(results)
		vim.print(results)
	end)
end

Mssql_open_vd = function()
	local client = vim.lsp.get_client_by_id(client_id)
	if client == nil then
		vim.notify("No client with given client id" .. client_id)
		return
	end
	local csv_path = tmp_dir .. connection_id .. "_" .. query_id .. ".csv"
	client.request("query/saveCsv", {
		includeHeaders = true,
		delimiter = ",",
		lineSeperator = nil,
		textIdentifier = '"',
		encoding = "utf-8",
		ownerUri = buffer_uri,
		resultSetIndex = 0,
		batchIndex = 0,
		filePath = csv_path,
	}, function(results)
		vim.print(results)
		vim.print("csv saved to " .. csv_path)
		os.execute("mkdir -p " .. tmp_dir)
		Create_vd_term(csv_path)
	end)
end

Mssql_connect_to_database = function()
	if not username or not server_name or not password or not db_name then
		vim.notify("Environment Variables not set")
		return
	end
	local client = vim.lsp.get_client_by_id(client_id)
	if client == nil then
		vim.notify("No client with given client id" .. client_id)
		return
	end
	vim.print("started connection")
	client.request("connection/connect", {
		ownerUri = buffer_uri,
		connection = {
			options = {
				server = server_name,
				database = db_name,
				databaseDisplayName = db_name,
				user = username,
				password = password,
				authenticationType = "SqlLogin",
			},
		},
	}, function(err, result, ctx, config)
		vim.print("result: " .. tostring(result))
		vim.print("ctx: ")
		vim.print(ctx)
		vim.print("config: ")
		vim.print(config)
	end)
end

vim.keymap.set("n", "<leader>cb", ":lua Mssql_connect_to_database()<CR>", { desc = "Connect to Database" })
vim.keymap.set("n", "<leader>eq", ":lua Mssql_execute_query_doc()<CR>", { desc = "Execute Query" })
vim.keymap.set("n", "<leader>cvd", ":lua Mssql_open_vd()<CR>", { desc = "Open Results in visidata" })
vim.keymap.set("n", "<leader>cq", ":lua Mssql_cancel_query()<CR>", { desc = "Cancel Query" })
vim.keymap.set("n", "<leader>rbi", ":lua Mssql_rebuild_intellisense()<CR>", { desc = "Rebuild Intellisense" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "sql",
	callback = function()
		buffer_uri = "file://" .. vim.api.nvim_buf_get_name(0)
		vim.print("mssql-lsp client attached")
		-- vim.print('buffer uri: ' .. buffer_uri)
		vim.lsp.buf_attach_client(0, client_id)
		-- vim.notify('Log filename ' .. lsp_log.get_filename())
	end,
})
