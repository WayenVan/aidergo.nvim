local M = {}
local config = require("aidergo.config")
local utils = require("aidergo.utils")
--- Create  new aider terminal
---
local function get_channel(term)
	return vim.api.nvim_get_option_value("channel", { buf = term.buf })
end

local function clean_terminal_input(channel)
	vim.fn.chansend(channel, "\x15")
end

local function smart_get_id()
	local aider_id = nil
	if aider_id == nil then
		--- If no aider_id is provided, use the last opened one
		if _G.AidergoManager.last_opened_id ~= nil then
			aider_id = _G.AidergoManager.last_opened_id
		else
			--- If no last opened id, use the minimal id
			aider_id = utils.find_min_key(_G.AidergoManager.terminals)
		end
	end
	return aider_id
end

--- create a new terminal instance for Aider
---@param position? '"bottom"'|'"top"'|'"left"'|'"right"'|'"float"' # The position of the terminal, defaults to bottom
---@param size? number # The size of the terminal, defaults to 40
---@return number|nil # The created terminal id
M.create = function(position, size)
	position = position or config.position
	size = size or config.size

	local mode_arg = vim.opt.background:get() == "dark" and "--dark-mode" or "--light-mode"
	-- local aider_cmd = "aider" .. mode_arg
	local aider_cmd = string.format("aider %s %s", table.concat(config.args, " "), mode_arg)

	-- assign an id for this terminal
	local assigned_id = nil
	for i = 1, config.max_id do
		if _G.AidergoManager.terminals[i] == nil then
			assigned_id = i
			break
		end
	end

	-- If no id is available, return an error
	if assigned_id == nil then
		vim.notify("aidergo: No available terminal ID", vim.log.levels.ERROR)
		return nil
	end

	-- create new terminal instance
	local aider_term = Snacks.terminal.open(aider_cmd, {
		win = {
			position = position,
			size = size,
		},
		auto_insert = true,
		start_insert = true,
		auto_close = false,
	})
	_G.AidergoManager.terminals[assigned_id] = aider_term
	vim.api.nvim_create_autocmd("TermClose", {
		buffer = aider_term.buf,
		callback = function()
			-- Remove the terminal from the manager when it closes
			_G.AidergoManager.terminals[assigned_id] = nil
			if _G.AidergoManager.last_opened_id == assigned_id then
				_G.AidergoManager.last_opened_id = nil
			end
		end,
	})
	return assigned_id
end

--- Send a command to the Aider terminal
---@param aider_id number # The  id of the aider instance
---@param cmd_name string # The command name to send
---@param args? string[] # The arguments to send to the command
M.send_cmd = function(aider_id, cmd_name, args)
	args = args or {}

	local term = _G.AidergoManager.terminals[aider_id]
	if not term then
		vim.notify(string.format("aidergo: Terminal with ID %d does not exist", aider_id), vim.log.levels.ERROR)
		return
	end
	local cmd = string.format("/%s %s\n", cmd_name, table.concat(args, " "))
	local channel = get_channel(term)
	clean_terminal_input(channel)
	vim.fn.chansend(channel, cmd)
end

--- clean the inptut of the aider terminal
---@param aider_id? number # The  id of the aider instance
M.clean_aider_input = function(aider_id)
	local term = _G.AidergoManager.terminals[aider_id]
	if not term then
		vim.notify(string.format("aidergo: Terminal with ID %d does not exist", aider_id), vim.log.levels.ERROR)
		return
	end
	-- sending a Ctrl+U to clear the input
	local channel = get_channel(term)
	clean_terminal_input(channel)
end

---@param aider_id? number # The  id of the aider instance
M.add_current_file = function(aider_id)
	if not aider_id then
		aider_id = smart_get_id()
	end

	if not aider_id then
		error("No Aider instance available.")
	end

	local file_path = vim.fn.expand("%:p")
	M.send_cmd(aider_id, "add", { file_path })
end

---@param aider_id? number # The  id of the aider instance
M.remove_current_file = function(aider_id)
	if not aider_id then
		aider_id = smart_get_id()
	end

	if not aider_id then
		error("No Aider instance available.")
	end

	local file_path = vim.fn.expand("%:p")
	M.send_cmd(aider_id, "drop", { file_path })
end

---@param aider_id? number # The  id of the aider instance
---@param position? '"bottom"'|'"top"'|'"left"'|'"right"'|'"float"' # The position of the terminal, defaults to bottom
---@param size? number # The size of the terminal, defaults to 40
M.toggle = function(aider_id, position, size)
	if not aider_id then
		aider_id = smart_get_id()
	end

	position = position or config.position
	size = size or config.size

	if not aider_id then
		local id = M.create(position, size)
		if not id then
			error("Failed to create Aider terminal.")
			return
		end
		return
	end

	local term = _G.AidergoManager.terminals[aider_id]
	if not term then
		error("Aider Terminal with ID " .. aider_id .. " does not exist.")
		return
	end
	-- vim.notify(direction)
	term:show()
end

---@return number[] # A list of all available Aider terminal ids
M.get_aider_ids = function()
	local ids = {}
	for id, _ in pairs(_G.AidergoManager.terminals) do
		table.insert(ids, id)
	end
	return ids
end

--- shutdown all aider terminal
M.clean_all = function()
	for id, term in pairs(_G.AidergoManager.terminals) do
		if term then
			term:destroy()
			_G.AidergoManager.terminals[id] = nil
		end
	end
end

return M
