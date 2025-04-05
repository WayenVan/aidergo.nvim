local M = {}

M.deepMerge = function(target, source)
	-- Handle nil cases
	if target == nil then
		return source
	end
	if source == nil then
		return target
	end

	-- Iterate through all keys in source
	for k, v in pairs(source) do
		-- If both values are tables, merge them recursively
		if type(target[k]) == "table" and type(v) == "table" then
			M.deepMerge(target[k], v)
		else
			-- Otherwise, simply assign the value
			target[k] = v
		end
	end

	return target -- Return the modified target table (same instance)
end

M.find_min_key = function(t)
	local min_key = nil
	for k, _ in pairs(t) do
		if type(k) == "number" then -- Ensure key is a number
			if min_key == nil or k < min_key then
				min_key = k
			end
		end
	end
	return min_key
end

M.wrap_path_with_quotes = function(path)
	-- First, remove any existing quotes
	path = path:gsub('^"(.*)"$', "%1")

	-- Escape backslashes (important for Windows paths)
	path = path:gsub("\\", "\\\\")

	-- Escape double quotes
	path = path:gsub('"', '\\"')

	-- Handle other special characters that could cause issues
	-- Escape newlines, carriage returns, and tabs
	path = path:gsub("\n", "\\n")
	path = path:gsub("\r", "\\r")
	path = path:gsub("\t", "\\t")

	-- Wrap the path in double quotes
	return '"' .. path .. '"'
end

return M
