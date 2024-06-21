local NuiTree = require("nui.tree")
local oe_manager = require("oe.manager")
local oe_requests = require("oe.requests")
local managers = require("managers")
local requests = require("requests")
local scripts = require("oe.scripts")
local M = {}
local root_node

local function create_tree()
	if not oe_manager.bufnr then
		vim.print("Object Explorer buffer has not been created yet.")
		return
	end
	local tree = NuiTree({
		bufnr = oe_manager.bufnr,
		nodes = { root_node },
	})
	oe_manager.tree = tree

	return tree
end

function M.create_root_node(rootNode)
	local label = rootNode.label
	-- local type = rootNode.nodeType --TODO use for nerd font symbol
	root_node = NuiTree.Node({
		text = label,
		data = rootNode,
	})

	if not oe_manager.tree then
		create_tree()
	else
		oe_manager.tree.nodes = { root_node }
	end

	root_node:get_id()

	oe_manager.tree:render()

	return root_node
end

function M.create_children(children)
	local child_table = {}
	for _, child in ipairs(children) do
		local child_node = NuiTree.Node({
			text = child.label,
			data = child,
		})
		table.insert(child_table, child_node)
	end

	return child_table
end

function M.open_object_explorer()
	if not oe_manager.bufnr then
		oe_manager.create_oe()
		local connection = oe_manager.get_connection()
		local owner_uri = connection.databaseDisplayName .. "_ObjectExplorer"
		local buffer_manager = managers.new_manager(oe_manager.bufnr, owner_uri)
		buffer_manager.connection = connection
		oe_requests.create_session(connection)
		requests.connect_to_database(oe_manager.bufnr)
	end
	if oe_manager.tree then
		oe_manager.tree:render()
	end
end

function M.toggle_node()
	if oe_manager.bufnr ~= vim.api.nvim_get_current_buf() then
		return
	end
	local curpos = vim.fn.getcurpos()
	if not curpos[2] then
		return
	end
	local node = oe_manager.tree:get_node(curpos[2])
	if not node then
		return
	end

	if node:is_expanded() then
		node:collapse()
	else
		oe_manager.tree:set_nodes({ NuiTree.Node({ text = "Expanding.." }) }, node:get_id())
		oe_requests.expand_node_request(node)
		node:expand()
	end

	oe_manager.tree:render()
end

function M.open_script()
	if oe_manager.bufnr ~= vim.api.nvim_get_current_buf() then
		return
	end
	local curpos = vim.fn.getcurpos()
	if not curpos[2] then
		return
	end
	local node = oe_manager.tree:get_node(curpos[2])
	if not node then
		return
	end

	scripts.script_action(node)
end

return M
