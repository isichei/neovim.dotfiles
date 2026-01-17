local default = "kanagawa"

Lualine_theme = nil

return {
  {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1001,
    opts = {
      theme = "dragon", -- Load "wave" theme when 'background' option is not set
      background = {    -- map the value of 'background' option to a theme
        dark = "dragon",
      }
    },
    config = function(_, opts)
      require("kanagawa").setup(opts)
      local colors = require("kanagawa.colors").setup(opts)
      local palette = colors.palette
      local custom_kanagawa = {
        normal = {
          a = { bg = palette.dragonBlue2, fg = palette.sumiInk0, gui = "bold" },
          b = { bg = palette.dragonBlack5, fg = palette.fujiWhite },
          c = { bg = palette.dragonBlack4, fg = palette.fujiWhite },
        },
        insert = {
          a = { bg = palette.dragonGreen2, fg = palette.sumiInk0, gui = "bold" },
        },
        visual = {
          a = { bg = palette.dragonPink, fg = palette.sumiInk0, gui = "bold" },
        },
        replace = {
          a = { bg = palette.dragonRed, fg = palette.sumiInk0, gui = "bold" },
        },
        inactive = {
          c = { bg = palette.sumiInk0, fg = palette.sumiInk4 },
        }
      }
      Lualine_theme = custom_kanagawa
      if default == "kanagawa" then
        vim.cmd.colorscheme("kanagawa")
      end
    end
  },
  {
    'AlexvZyl/nordic.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      bright_border = true,
    },
    config = function(_, opts)
      require("nordic").setup(opts)
      if default == "nordic" then
        vim.cmd.colorscheme("nordic")
      end
    end,
  },
  {
    'sainnhe/everforest',
    lazy = false,
    priority = 1000,
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin declaration.
      -- vim.g.everforest_enable_italic = true
      vim.g.everforest_background = 'hard'
      vim.g.everforest_better_performance = 1

      if default == "everforest" then
        vim.cmd.colorscheme("everforest")
      end
    end
  },
  {
    'sainnhe/gruvbox-material',
    lazy = false,
    priority = 1000,
    config = function()
      -- Optionally configure and load the colorscheme
      -- directly inside the plugin decuaration.
      -- vim.g.gruvbox_material_enable_italic = true
      vim.g.gruvbox_material_background = 'hard'
      vim.g.gruvbox_material_performance = 1
      if default == "gruvbox-material" then
        vim.cmd.colorscheme("gruvbox-material")
      end
    end
  },
  { "rose-pine/neovim", name = "rose-pine", lazy = false },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
      color_overrides = {
        mocha = {
          base = "#11111b",   -- rgb(17, 17, 27)
          mantle = "#0A0A14", -- rgb(10, 10, 20)
          crust = "#05050F",  -- rgb(5, 5, 15)
        },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      if default == "catppuccin" then
        vim.cmd.colorscheme("catppuccin-mocha")
      end
    end,
  },
  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    event = "ColorScheme",
    dependencies = { "rebelot/kanagawa.nvim", "NickvanDyke/opencode.nvim"},
    opts = {
      options = {
        theme = default,
        icons_enabled = false,
        component_separators = "|",
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_c = {
          {
            'filename',
            path = 1
          }
        }
      }
    },
    config = function(_, opts)
      if default == "kanagawa" and not (Lualine_theme == nil) then opts["options"]["theme"] = Lualine_theme end
      require("lualine").setup(opts)
    end,
  }
}
