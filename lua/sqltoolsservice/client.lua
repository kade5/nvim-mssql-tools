local M = {}
local sqltools = require("sqltoolsservice.install")
local handlers = require("handlers")
local oe_handlers = require("oe.handlers")
local managers = require("managers")
local client_id = nil

function M.start_client()
	client_id = vim.lsp.start_client({
		name = "mssql-lsp",
		cmd = { sqltools.install_dir() .. "/" .. sqltools.executable_name },
		handlers = {
			["connection/complete"] = handlers.connection_complete,
			["query/complete"] = handlers.query_complete,
			["query/message"] = handlers.query_message,
			["objectexplorer/sessioncreated"] = oe_handlers.session_created,
			["objectexplorer/expandCompleted"] = oe_handlers.expand_completed,
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
		print("No client found")
		return
	else
		print("Client returned with ID: " .. client_id)
	end
	managers.client_id = client_id
	return client_id
end

function M.get_client_id()
	return client_id
end

return M
