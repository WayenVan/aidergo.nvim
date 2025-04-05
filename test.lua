function wrap_path_with_quotes(path)
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

-- Example with various special characters
local paths = {
	"/home/user/my documents/file.txt",
	[[C:\Program Files\My App\config.json]],
	'/path/with/quotes"here/file',
	"/path/with\nnewline/file",
	"/path/with\ttab/file",
}

for _, path in ipairs(paths) do
	print(path .. " → " .. wrap_path_with_quotes(path))
end

-- term:destroy()
-- print(term.buf)

-- print(vim.api.nvim_get_option_value("channel", { buf = term.buf }))
