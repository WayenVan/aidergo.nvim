---@class AiderGoOpt
---@field mas_id? number
---@field position? '"bottom"'|'"top"'|'"left"'|'"right"'|'"float"' # The position of the terminal, defaults to bottom
---@field args? string[] # The arguments to pass to the AiderGo command

---@type AiderGoOpt
local M = {
	max_id = 999,
	position = "right",
	size = 40,
	args = {
		"--pretty",
		"--stream",
		"--no-auto-commits",
	},
}

return M
