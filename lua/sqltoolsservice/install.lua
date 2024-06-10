local M = {}

local version_num = "5.0.20240603.5"
local package_name = "Microsoft.SqlTools.ServiceLayer-linux-x64-net8.0.tar.gz"
local install_url = "https://github.com/microsoft/sqltoolsservice/releases/download/"
	.. version_num
	.. "/"
	.. package_name

-- TODO add support for installing with different architectures and operating systems
--
M.executable_name = "MicrosoftSqlToolsServiceLayer"

function M.install_dir()
	local install_path = vim.fn.stdpath("data") .. "/mssql-tools/bin"
	os.execute("mkdir -p " .. install_path)
	return install_path
end

function M.is_installed()
	return vim.fn.executable(M.install_dir() .. M.executable_name)
end

local function download_file(url, cwd, output, on_success)
	local job_id = vim.fn.jobstart({ "curl", "-L", url, "-o", output }, {
		on_exit = function(job_id, exit_code, event)
			if exit_code == 0 then
				print("Download completed: " .. output)
				if on_success then
					on_success()
				end
			else
				print("Download failed with exit code: " .. exit_code)
			end
		end,
		cwd = cwd,
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(job_id, data, event)
			for _, line in ipairs(data) do
				print(line)
			end
		end,
		on_stderr = function(job_id, data, event)
			for _, line in ipairs(data) do
				print(line)
			end
		end,
	})
end

-- Function to extract a tar.gz file
local function extract_file(cwd, file)
	local job_id = vim.fn.jobstart({ "tar", "-xzf", file }, {
		on_exit = function(job_id, exit_code, event)
			if exit_code == 0 then
				print("Extraction completed: " .. file)
			else
				print("Extraction failed with exit code: " .. exit_code)
			end
		end,
		stdout_buffered = true,
		stderr_buffered = true,
		cwd = cwd,
		on_stdout = function(job_id, data, event)
			for _, line in ipairs(data) do
				print(line)
			end
		end,
		on_stderr = function(job_id, data, event)
			for _, line in ipairs(data) do
				print(line)
			end
		end,
	})
end

M.install_sqltools = function()
	local output_file = package_name
	download_file(install_url, M.install_dir(), output_file, function()
		extract_file(M.install_dir(), output_file)
	end)
end

return M
