-- Vim options / setup
require("opts_and_keymaps")
vim.g.loaded_python3_provider = 0

-- Lazyvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({

  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',
  -- Useful plugin to show you pending keybinds.
  {
    'folke/which-key.nvim',
    opts = {
      icons = {
        mappings = false
      }
    }
  },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      current_line_blame = true,
      on_attach = function(bufnr)
        vim.keymap.set("n", "<leader>gp", require("gitsigns").prev_hunk,
          { buffer = bufnr, desc = "Go to previous git Hunk" })
        vim.keymap.set("n", "<leader>gn", require("gitsigns").next_hunk, { buffer = bufnr, desc = "Go to next git Hunk" })
        vim.keymap.set("n", "<leader>gi", require("gitsigns").preview_hunk_inline,
          { buffer = bufnr, desc = "Git Preview Hunk Inline" })
        vim.keymap.set("n", "<leader>ghr", ":Gitsigns reset_hunk<CR>", { buffer = bufnr, desc = "Git Reset Hunk" })
        vim.keymap.set("n", "<leader>ghR", require("gitsigns").reset_buffer,
          { buffer = bufnr, desc = "Git Reset Buffer" })

        vim.keymap.set("n", "<leader>ghs", ":Gitsigns stage_hunk<CR>", { buffer = bufnr, desc = "Git Stage Hunk" })
        vim.keymap.set("n", "<leader>ghS", require("gitsigns").stage_buffer,
          { buffer = bufnr, desc = "Git Stage Buffer" })

        vim.keymap.set("n", "<leader>ghu", require("gitsigns").undo_stage_hunk,
          { buffer = bufnr, desc = "Git undo stage Hunk" })

        vim.keymap.set("n", "<leader>gB", "<cmd>Gitsigns toggle_current_line_blame<CR>",
          { desc = "Toggle git blame current line" })
        vim.keymap.set("n", "<leader>g|", "<cmd>Gitsigns diffthis<CR>", { desc = "Vertical Git diff" })
      end,
    },
  },
  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    main = "ibl",
    opts = {},
    version = ">=3.*"
  },
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'vrischmann/tree-sitter-templ', -- :TSInstall templ
    },
    build = function()
      if vim.fn.executable('tree-sitter') == 1 then
        vim.cmd('TSUpdate')
      end
    end,
    config = function()
      local treesitter_languages = {
        'c',
        'cpp',
        'go',
        'lua',
        'python',
        'rust',
        'tsx',
        'javascript',
        'typescript',
        'vimdoc',
        'vim',
        'html',
        'css',
      }

      local treesitter = require('nvim-treesitter')
      treesitter.setup()
      if vim.fn.executable('tree-sitter') == 1 then
        treesitter.install(treesitter_languages)
      end

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          if pcall(vim.treesitter.start, args.buf) then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      local function select_parent_node()
        if not vim.treesitter.get_parser(nil, nil, { error = false }) then
          vim.lsp.buf.selection_range(vim.v.count1)
          return
        end

        if vim.api.nvim_get_mode().mode == 'n' then
          vim.cmd.normal({ 'v', bang = true })
        end

        require('vim.treesitter._select').select_parent(vim.v.count1)
      end

      vim.keymap.set({ 'n', 'x' }, '<c-space>', select_parent_node, { desc = 'Select parent node' })
      vim.keymap.set('x', '<c-s>', select_parent_node, { desc = 'Select parent node' })
      vim.keymap.set('x', '<M-space>', function()
        if vim.treesitter.get_parser(nil, nil, { error = false }) then
          require('vim.treesitter._select').select_child(vim.v.count1)
        else
          vim.lsp.buf.selection_range(-vim.v.count1)
        end
      end, { desc = 'Select child node' })

      require('nvim-treesitter-textobjects').setup {
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      }

      local ts_select = require('nvim-treesitter-textobjects.select')
      vim.keymap.set({ 'x', 'o' }, 'aa', function()
        ts_select.select_textobject('@parameter.outer', 'textobjects')
      end, { desc = 'Select outer parameter' })
      vim.keymap.set({ 'x', 'o' }, 'ia', function()
        ts_select.select_textobject('@parameter.inner', 'textobjects')
      end, { desc = 'Select inner parameter' })
      vim.keymap.set({ 'x', 'o' }, 'af', function()
        ts_select.select_textobject('@function.outer', 'textobjects')
      end, { desc = 'Select outer function' })
      vim.keymap.set({ 'x', 'o' }, 'if', function()
        ts_select.select_textobject('@function.inner', 'textobjects')
      end, { desc = 'Select inner function' })
      vim.keymap.set({ 'x', 'o' }, 'ac', function()
        ts_select.select_textobject('@class.outer', 'textobjects')
      end, { desc = 'Select outer class' })
      vim.keymap.set({ 'x', 'o' }, 'ic', function()
        ts_select.select_textobject('@class.inner', 'textobjects')
      end, { desc = 'Select inner class' })

      local ts_move = require('nvim-treesitter-textobjects.move')
      vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
        ts_move.goto_next_start('@function.outer', 'textobjects')
      end, { desc = 'Go to next function start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
        ts_move.goto_next_start('@class.outer', 'textobjects')
      end, { desc = 'Go to next class start' })
      vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
        ts_move.goto_next_end('@function.outer', 'textobjects')
      end, { desc = 'Go to next function end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
        ts_move.goto_next_end('@class.outer', 'textobjects')
      end, { desc = 'Go to next class end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
        ts_move.goto_previous_start('@function.outer', 'textobjects')
      end, { desc = 'Go to previous function start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
        ts_move.goto_previous_start('@class.outer', 'textobjects')
      end, { desc = 'Go to previous class start' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
        ts_move.goto_previous_end('@function.outer', 'textobjects')
      end, { desc = 'Go to previous function end' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
        ts_move.goto_previous_end('@class.outer', 'textobjects')
      end, { desc = 'Go to previous class end' })

      local ts_swap = require('nvim-treesitter-textobjects.swap')
      vim.keymap.set('n', '<leader>a', function()
        ts_swap.swap_next('@parameter.inner', 'textobjects')
      end, { desc = 'Swap with next parameter' })
      vim.keymap.set('n', '<leader>A', function()
        ts_swap.swap_previous('@parameter.inner', 'textobjects')
      end, { desc = 'Swap with previous parameter' })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      mode = "cursor",
      max_lines = 3,
      trim_scope = "inner",
    },
  },
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require("bufferline").setup {}
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", function() require("trouble").toggle() end, desc = "Toggle Trouble" }
    },
  },
  {
    "nvimtools/none-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        debug = true,
        sources = {
          null_ls.builtins.formatting.black, -- Will error if black not in path, which is what I want
        },
      })
    end
  },
  { import = 'plugins' },
}, {})

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Diagnostic display configuration
vim.diagnostic.config({
  virtual_text = {
    prefix = '■',  -- Square symbol at end of line
    spacing = 4,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
  end,
})
