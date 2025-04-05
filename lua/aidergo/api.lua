local M = {}
local t = require("toggleterm.terminal")
local config = require("aidergo.config")
local utils = require("aidergo.utils")
--- Create  new aider terminal

local function clean_terminal_input(term)
	vim.fn.chansend(term.job_id, "\x15")
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
---@param direction? '"float"'|'"vertical"'|'"horizontal"' # Optional terminal direction, defaults to float
---@return number # The created terminal id
M.create = function(direction)
	direction = direction or config.default_direction

	local mode_arg = vim.opt.background:get() == "dark" and "--dark-mode" or "--light-mode"
	local aider_cmd = "aider --no-auto-commits --pretty --stream " .. mode_arg

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
		error("No available terminal ID")
	end

	-- Create the terminal and assign it to the manager
	local aider_term = t.Terminal:new({
		cmd = aider_cmd,
		dir = vim.fn.getcwd(),
		direction = direction,
		on_create = function(_)
			_G.AidergoManager.last_opened_id = assigned_id
		end,
		on_open = function(_)
			_G.AidergoManager.last_opened_id = assigned_id
		end,
		on_exit = function(_)
			-- Remove the terminal from the manager when it exits
			_G.AidergoManager.terminals[assigned_id] = nil
			if _G.AidergoManager.last_opened_id == assigned_id then
				_G.AidergoManager.last_opened_id = nil
			end
		end,
		close_on_exit = true,
		hidden = true,
		display_name = "Aider: " .. assigned_id,
	})
	_G.AidergoManager.terminals[assigned_id] = aider_term.id
	aider_term:toggle()

	return assigned_id
end

--- Send a command to the Aider terminal
---@param aider_id number # The  id of the aider instance
---@param cmd_name string # The command name to send
---@param args? string[] # The arguments to send to the command
M.send_cmd = function(aider_id, cmd_name, args)
	args = args or {}
	local term_id = _G.AidergoManager.terminals[aider_id]
	if not term_id then
		error("Aider instance with ID " .. aider_id .. " does not exist.")
	end

	local term = t.get(term_id, true)
	if not term then
		error("Terminal with ID " .. term_id .. " does not exist.")
	end

	local cmd = string.format("/%s %s", cmd_name, table.concat(args, " "))
	clean_terminal_input(term)
	term:send(cmd)
end

--- clean the inptut of the aider terminal
---@param aider_id? number # The  id of the aider instance
M.clean_aider_input = function(aider_id)
	local term_id = _G.AidergoManager.terminals[aider_id]
	if not term_id then
		error("Aider instance with ID " .. aider_id .. " does not exist.")
	end

	local term = t.get(term_id, true)
	if not term then
		error("Terminal with ID " .. term_id .. " does not exist.")
	end
	-- sending a Ctrl+U to clear the input
	clean_terminal_input(term)
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
---@param direction? '"float"'|'"vertical"'|'"horizontal"' # Optional terminal direction, defaults to float
M.toggle = function(aider_id, direction)
	direction = direction or config.default_direction
	if not aider_id then
		aider_id = smart_get_id()
	end

	if not aider_id then
		local id = M.create(direction)
		local term = t.get(id, true)
		if term and ~term:is_open() then
			term:open()
			return
		end
		error("Failed to create Aider terminal.")
	end

	local term_id = _G.AidergoManager.terminals[aider_id]
	if not term_id then
		error("Aider instance with ID " .. aider_id .. " does not exist.")
	end

	local term = t.get(term_id, true)
	if not term then
		error("Terminal with ID " .. term_id .. " does not exist.")
	end
	term:toggle(nil, direction)
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
	for id, term_id in pairs(_G.AidergoManager.terminals) do
		local term = t.get(term_id, true)
		if term then
			term:shutdown()
			_G.AidergoManager.terminals[id] = nil
		end
	end
end

return M
