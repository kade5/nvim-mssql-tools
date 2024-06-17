local M = {}

local install = require("sqltoolsservice.install")
local client = require("sqltoolsservice.client")
local connections = require("connections")
local requests = require("requests")
local managers = require("managers")

M.install = install
M.client = client
M.connections = connections
M.requests = requests
M.managers = managers
M.oe = {
	ui = require("oe.ui"),
	requests = require("oe.requests"),
}

function M.attach_client()
	vim.print("mssql-lsp client attached")
	-- vim.print('Tried to create a new manager for buffer: ' .. vim.api.nvim_get_current_buf())
	local client_id = client.get_client_id()
	if not client_id then
		vim.print("Client has not been started")
		return
	end
	vim.print(vim.lsp.buf_attach_client(0, client_id))
	local manager = managers.new_manager(vim.api.nvim_get_current_buf())
	manager.connection = connections.get_connection("Prod")
end

function M.setup()
	if not install.is_installed() then
		install.install_sqltools()
	else
		print("SQL Tools Service already installed")
	end

	local client_id = client.start_client()

	if client_id then
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "sql",
			callback = function()
				vim.lsp.buf_attach_client(0, client_id)
				vim.print("mssql-lsp client attached")
				local manager = managers.new_manager(vim.api.nvim_get_current_buf())
				manager.connection = connections.get_connection("Prod")
			end,
		})
	end
end

return M
