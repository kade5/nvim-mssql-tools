local Split = require("nui.split")
local event = require("nui.utils.autocmd")
local NuiTree = require("nui.tree")
local oe_manager = require("oe.manager")
local oe_requests = require("oe.requests")
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

-- local split = Split({
-- 	relative = "win",
-- 	position = "left",
-- 	size = "20%",
-- })
--
-- local btree = NuiTree.Node({ text = "b" }, {
-- 	NuiTree.Node({ text = "b-1" }),
-- 	NuiTree.Node({ text = "b-2" }),
-- })
--
-- local tree = NuiTree({
-- 	bufnr = split.bufnr,
-- 	nodes = {
-- 		NuiTree.Node({ text = "a" }),
-- 		btree,
-- 	},
-- })

function M.open_object_explorer()
	if not oe_manager.bufnr then
		oe_manager.create_oe()
		oe_requests.create_session()
	end
	local split = oe_manager.get_buffer()
	-- split:show()
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

return M
