local oe_manager = require("oe.manager")
local oe_ui = require("oe.ui")
local M = {}
function M.session_created(err, result, ctx, config)
	if err then
		vim.notify(err)
		return result, err
	end
	if result.errorMessage then
		vim.notify(result.errorMessage)
		return result, err
	end
	local session_id = result.sessionId

	oe_manager.session_id = session_id
	oe_ui.create_root_node(result.rootNode)

	vim.print("Succesfully connected to session_id: " .. session_id)
	return result, err
end

function M.expand_completed(err, result, ctx, config)
	vim.print("Entered expand completed")
	if err then
		vim.notify(err)
		oe_manager.expanding_node = nil
		return result, err
	end
	if result.errorMessage then
		vim.notify(result.errorMessage)
		oe_manager.expanding_node = nil
		return result, err
	end

	if oe_manager.session_id ~= result.sessionId then
		vim.notify("Session Id mismatch \n" .. oe_manager.session_id .. "\n" .. result.sessionId)
		oe_manager.expanding_node = nil
		return
	end

	local nodes = result.nodes

	if not nodes then
		vim.notify("No children nodes")
		oe_manager.expanding_node = nil
		return
	end

	local node_id = oe_manager.expanding_node
	local children = oe_ui.create_children(nodes)
	oe_manager.tree:set_nodes(children, node_id)
	oe_manager.tree:render()

	oe_manager.expanding_node = nil

	return result, err
end

return M
