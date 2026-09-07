-- OPTIONS
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.cursorline = false
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.o.wrap = false

vim.wo.relativenumber = true

vim.o.hlsearch = false

vim.o.scrolloff = 8

vim.opt.swapfile = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- KEYMAPS
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = '*',
})

-- Delete highlighted into the void and paste over
vim.keymap.set("v", "<leader>p", "\"_dP", { remap = true })

-- Delete into the void
vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")


-- Keeps cursor in middle when page jumping up and down
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- Keeps cursor in the middle when jumping to next search term
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Replace the current word I am on
vim.keymap.set("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gc<Left><Left><Left>]],
	{ desc = "Replace current word" })


-- Lazyvim Steals (https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua)

-- Move to window using the <ctrl> hjkl keys
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- buffers
vim.keymap.set("n", "<leader>j", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>k", "<cmd>bprevious<cr>", { desc = "Prev buffer" })

-- better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- new file
vim.keymap.set("n", "<leader>nf", "<cmd>enew<cr>", { desc = "New File" })

-- windows
vim.keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split window horizontally", remap = true })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split window vertically", remap = true })

-- quicklist navigation
vim.keymap.set("n", "<leader><Tab>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<leader><S-Tab>", "<cmd>cprev<CR>zz")

-- change terminal mode esc
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

-- copy relative path to clipboard
vim.keymap.set("n", "<leader>cr", function()
	local filepath = vim.api.nvim_buf_get_name(0) -- absolute path to current file
	local cwd = vim.fn.getcwd() -- cwd from where nvim was started
	local relpath = vim.fn.fnamemodify(filepath, ":." ) -- path relative to cwd
	vim.fn.setreg("+", relpath)
	print("Copied relative path: " .. relpath)
end, { desc = "[C]opy [r]elative filepath to clipboard" })

-- Close buffer
vim.keymap.set("n", "<leader>cb", ":bp | bd#<CR>", { desc = "Close buffer without closing split" })

-- Winbar breadcrumbs (shows current function/class from LSP)
_G.winbar_breadcrumbs = function()
	local ok, navic = pcall(require, "nvim-navic")
	if ok and navic.is_available() then
		return navic.get_location()
	end
	return ""
end
vim.opt.winbar = "%!v:lua.winbar_breadcrumbs()"

-- DIAGNOSTICS TOGGLES
-- State variables for toggles
local diagnostics_state = {
	inline = true,       -- current: inline virtual text enabled
	show_warnings = true, -- current: warnings shown
}

-- Apply diagnostics config based on current state
local function apply_diagnostics_config()
	local config = {
		virtual_text = diagnostics_state.inline,
		signs = true,
		underline = true,
	}

	if not diagnostics_state.show_warnings then
		local severity = { min = vim.diagnostic.severity.ERROR }
		config.virtual_text = diagnostics_state.inline and { severity = severity } or false
		config.signs = { severity = severity }
		config.underline = { severity = severity }
	end

	vim.diagnostic.config(config)
end

-- Set default diagnostics config
apply_diagnostics_config()

-- Keymap 1: Toggle inline virtual text vs sign-only
vim.keymap.set("n", "<leader>td", function()
	diagnostics_state.inline = not diagnostics_state.inline
	apply_diagnostics_config()
	local mode = diagnostics_state.inline and "inline" or "sign-only"
	print("Diagnostics display: " .. mode)
end, { desc = "[T]oggle [D]iagnostics display mode (inline/sign-only)" })

-- Keymap 2: Toggle warnings on/off
vim.keymap.set("n", "<leader>tw", function()
	diagnostics_state.show_warnings = not diagnostics_state.show_warnings
	apply_diagnostics_config()
	local mode = diagnostics_state.show_warnings and "errors + warnings" or "errors only"
	print("Diagnostics severity: " .. mode)
end, { desc = "[T]oggle [W]arnings (errors only / errors + warnings)" })

