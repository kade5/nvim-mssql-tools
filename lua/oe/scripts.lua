local oe_manager = require("oe.manager")
local managers = require("managers")
local Menu = require("nui.menu")
local oe_requests = require("oe.requests")
local utils = require("utils")
local M = {}

local temp_path = "/var/tmp/mssql-scripts/"

local function get_script_options(data, script_type, owner_uri, operation_num)
	local options = {
		scriptDestination = "ToEditor",
		scriptingObjects = {
			{
				type = data.nodeType,
				schema = data.metadata.schema,
				name = data.metadata.name,
				parentName = nil,
				parentTypeName = nil,
			},
		},
		scriptOptions = {
			scriptCreateDrop = script_type,
			typeOfDataToScript = "SchemaOnly",
			scriptStatistics = "ScriptStatsNone",
			targetDatabaseEngineEdition = "SqlAzureDatabaseEdition",
			targetDatabaseEngineType = "SqlAzure",
		},
		ownerURI = owner_uri,
		operation = operation_num,
	}
	return options
end

local script_actions = {
	Table = { "select_top_1000", "create", "drop" },
	View = { "select_top_1000", "create", "alter", "drop" },
	StoredProcedure = { "create", "execute", "alter", "drop" },
	UserDefinedFunction = { "create", "alter", "drop" },
}

local script_types = {
	select_top_1000 = { type = "ScriptSelect", operation = 0 },
	create = { type = "ScriptCreate", operation = 1 },
	alter = { type = "ScriptCreate", operation = 6 },
	drop = { type = "ScriptDrop", operation = 4 },
	execute = { type = "ScriptCreate", operation = 5 },
}

local function create_script(result)
	if not result.operationId or not result.script then
		vim.print("No script created")
		return
	end
	local filename = temp_path .. result.operationId .. ".sql"

	os.execute("mkdir -p " .. temp_path)

	local bufrn = utils.create_and_save_buffer(result.script, oe_manager.previous_window, filename)

	vim.api.nvim_set_option_value("ft", "sql", {
		buf = bufrn,
	})
end

local function choose_menu(lines)
	local menu = Menu({
		position = "50%",
		size = {
			width = 25,
			height = 5,
		},
		border = {
			style = "single",
			text = {
				top = "[Script as ]",
				top_align = "center",
			},
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:Normal",
		},
	}, {
		lines = lines,
		max_width = 20,
		keymap = {
			focus_next = { "j", "<Down>", "<C-n>" },
			focus_prev = { "k", "<Up>", "<C-p>" },
			close = { "<Esc>", "<C-c>" },
			submit = { "<CR>", "<C-y>" },
		},
		on_close = function() end,
		on_submit = function(item)
			local options =
				get_script_options(item.data.node.data, item.data.type, item.data.owner_uri, item.data.operation)
			oe_requests.script_as(options, create_script)
		end,
	})

	return menu
end

local function choose_action(node, action_table, owner_uri)
	local lines = {}

	for _, action in ipairs(action_table) do
		local script_type = script_types[action]
		local data = { type = script_type.type, operation = script_type.operation, node = node, owner_uri = owner_uri }
		local item = Menu.item(action)
		item.data = data
		table.insert(lines, item)
	end

	local menu = choose_menu(lines)
	menu:mount()
end

function M.script_action(node)
	vim.print("Entering script_children")
	local manager = managers.get_manager(oe_manager.bufnr)
	local owner_uri = manager.owner_uri

	if not owner_uri or not manager.is_connected then
		vim.print("No connection set for object explorer")
	end

	local action_table = script_actions[node.data.nodeType]
	if not action_table then
		vim.print("Object type " .. node.data.nodeType .. " does not have any scripts.")
		return
	end

	choose_action(node, action_table, owner_uri)
end

return M
