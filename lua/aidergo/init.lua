---@class AidergoManager
---@field terminals? table<number, snacks.terminal | snacks.win | unknown>  # maintan a terminal, buffer ids
---@field last_opened_id? number  # The last opened aidergo ID

local M = {}

function M.setup(opts)
	local config = require("aidergo.config")
	local utils = require("aidergo.utils")
	config = utils.deepMerge(config, opts or {})

	---@type AidergoManager
	_G.AidergoManager = {
		terminals = {}, -- Store terminal instances
		last_opened_id = nil,
	}
end

return M
