require("snacks")

_G._term = Snacks.terminal.open("aider", {
	win = {
		position = "right",
		size = 40,
		on_buf = function(self)
			print("Buffer ID: " .. self.buf)
		end,
		on_win = function(self)
			print("Window ID: " .. self.win)
		end,
		on_close = function(self)
			print("Window closed: " .. self.win)
		end,
	},
	auto_insert = true,
	start_insert = true,
	auto_close = false,
})

-- term:destroy()
-- print(term.buf)

-- print(vim.api.nvim_get_option_value("channel", { buf = term.buf }))
