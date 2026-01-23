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
		quickfile = { enabled = true },
		indent = { enabled = true, animate = { enabled = false } },
		-- dim = { enabled = false },
		input = { enabled = true },
		-- image = {enabled = false},
		notifier = {
			enabled = true,
			timeout = 3000,
		},
		picker = {
			enabled = true,
			sources = {
				files = {
					hidden = true,
					ignored = false,
					exclude = { ".git", ".venv", "__pycache__" },
				},
				grep = {
					hidden = true,
					ignored = false,
					exclude = { ".git", ".venv", "__pycache__" },
				},
			},
		},
		styles = {
			notification = {
				wo = { wrap = true },
			},
		},
	},
	keys = {
		{ "<leader>?", function() Snacks.picker.recent() end, desc = "Find recently opened files" },
		{ "<leader><space>", function() Snacks.picker.buffers() end, desc = "Find existing buffers" },
		{ "<leader>sf", function() Snacks.picker.files() end, desc = "Search Files" },
		{ "<leader>sc", function() Snacks.picker.colorschemes() end, desc = "Search Colourschemes" },
		{ "<leader>sh", function() Snacks.picker.help() end, desc = "Search Help" },
		{ "<leader>sw", function() Snacks.picker.grep({ search = vim.fn.expand("<cword>") }) end, desc = "Search current word under cursor" },
		{ "<leader>sW", function() Snacks.picker.grep({ search = vim.fn.expand("<cWORD>") }) end, desc = "Search current WORD under cursor" },
		{ "<leader>sg", function() Snacks.picker.grep() end, desc = "Search by Grep" },
		{ "<leader>s/", function() Snacks.picker.grep_buffers() end, desc = "Search Open Files" },
		{ "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Search Diagnostics" },
		{ "<leader>sl", function() Snacks.picker.lines() end, desc = "Search Buffer Lines" },
		-- Git
		{ "<leader>gf", function() Snacks.picker.git_files() end, desc = "Git Files" },
		{ "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
		{ "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
		{ "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
		{ "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
		{ "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
		{ "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
		{ "<leader>gF", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
		-- GitHub
		{ "<leader>ghi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (open)" },
		{ "<leader>ghI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
		{ "<leader>ghp", function() Snacks.picker.gh_pull_request() end, desc = "GitHub Pull Requests (open)" },
		{ "<leader>ghP", function() Snacks.picker.gh_pull_request({ state = "all" }) end, desc = "GitHub Pull Requests (all)" },
	},
}
