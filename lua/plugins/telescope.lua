return {
  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = 'master',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      local telescope = require("telescope")
      local telescopeConfig = require("telescope.config")

      -- Clone the default Telescope configuration
      local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

      -- I want to search in hidden/dot files.
      table.insert(vimgrep_arguments, "--hidden")
      -- I don't want to search in the `.git` directory.
      table.insert(vimgrep_arguments, "--glob")
      table.insert(vimgrep_arguments, "!**/.git/*")
      table.insert(vimgrep_arguments, "--glob")
      table.insert(vimgrep_arguments, "!**/.venv/*")
      table.insert(vimgrep_arguments, "--glob")
      table.insert(vimgrep_arguments, "!**/__pycache__/*")

      -- Couldn't find a way to set a default theme for the builtins
      local default_telescope_theme = "ivy"
      local used_builtins = { "find_files", "git_files", "oldfiles", "colorscheme", "buffers", "help_tags", "diagnostics",
        "live_grep" }

      -- set my default settings for pickers
      local telescope_pickers = {
        find_files = {
          hidden = true, -- will still show the inside of `.git/` as it's not `.gitignore`d.
          find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*", "--glob", "!**/.venv/*", "--glob", "!**/__pycache__/*" },
        },
        colorscheme = {
          enable_preview = true
        }
      }

      -- add the default theme
      for _, v in ipairs(used_builtins) do
        if not telescope_pickers[v] then
          telescope_pickers[v] = {}
        end
        if not telescope_pickers[v]["theme"] then
          telescope_pickers[v]["theme"] = default_telescope_theme
        end
      end

      telescope.setup({
        defaults = {
          -- `hidden = true` is not supported in text grep commands.
          -- mappings = {
          --   i = {
          --     ['<C-u>'] = false,
          --     ['<C-d>'] = false,
          --   },
          -- },
          vimgrep_arguments = vimgrep_arguments,
        },
        pickers = telescope_pickers,
      })

      -- Enable telescope fzf native, if installed
      pcall(require('telescope').load_extension, 'fzf')


      -- Add some keymaps (see `:help telescope.builtin`)
      vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
      vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
      vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sc', require('telescope.builtin').colorscheme, { desc = '[S]earch [C]olourschemes' })
      vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sw', function()
        local word = vim.fn.expand("<cword>")
        require('telescope.builtin').grep_string({ search = word })
      end, { desc = '[S]earch current [w]ord under cursor' })
      vim.keymap.set('n', '<leader>sW', function()
        local word = vim.fn.expand("<cWORD>")
        require('telescope.builtin').grep_string({ search = word })
      end, { desc = '[S]earch current [W]ord under cursor' })
      vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>s/', function()
        require('telescope.builtin').live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch Open Files' })
      vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
    end
  },
}
