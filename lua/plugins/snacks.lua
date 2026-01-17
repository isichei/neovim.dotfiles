return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true },
		dashboard = {
			sections = {
				{
					section = "terminal",
					cmd = "chafa ~/.config/boats.png --format symbols --symbols vhalf --size 60x17 --stretch; sleep .1",
					height = 17,
					padding = 1,
				},
				{ section = "startup" },
				{
					pane = 2,
					{ section = "keys", gap = 1, padding = 1 },
				},
			},
		},
		quickfile = {enabled = true},
		indent = { enabled = true, animate = {enabled = false}},
		-- dim = { enabled = false },
		input = { enabled = true },
		-- image = {enabled = false},
		notifier = {
			enabled = true,
			timeout = 3000,
		},
		styles = {
			notification = {
				wo = { wrap = true }, -- Wrap notifications
			},
		},
	},
}
