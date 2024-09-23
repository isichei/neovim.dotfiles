return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
      "nvim-neotest/neotest",
      "nvim-neotest/neotest-python",
    },
    config = function()
      local dap = require "dap"
      local ui = require "dapui"

      require("dapui").setup()
      require("nvim-dap-virtual-text").setup({})

      pcall(function()
        require("dap-python").setup("python")
      end)

      dap.configurations.python = {
        {
          name = 'Python: Run file with args',
          type = "python",
          request = "launch",
          program = "${file}",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
          stopOnEntry = false,
          justMyCode = false,
          args = function()
            local args_string = vim.fn.input('Arguments: ')
            return vim.split(args_string, " +")
          end,
        },
        {
          name = 'Python: Run Pytest',
          type = "python",
          request = "launch",
          module = "pytest",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
          stopOnEntry = false,
          justMyCode = false,
          connect = function()
            local test_path = vim.fn.input('test path [.]: ') or '.'
            return { args = { '--pdb', test_path, "-v" } }
          end,
        }
      };

      vim.keymap.set("n", "<space>db", dap.toggle_breakpoint)
      vim.keymap.set("n", "<space>dc", dap.run_to_cursor)

      -- Eval var under cursor
      vim.keymap.set("n", "<space>?", function()
        require("dapui").eval(nil, { enter = true })
      end)

      vim.keymap.set("n", "<F1>", dap.continue)
      vim.keymap.set("n", "<F2>", dap.step_into)
      vim.keymap.set("n", "<F3>", dap.step_over)
      vim.keymap.set("n", "<F4>", dap.step_out)
      vim.keymap.set("n", "<F5>", dap.step_back)
      vim.keymap.set("n", "<F6>", dap.restart)
      vim.keymap.set("n", "<F12>", function()
        dap.terminate()
        ui.close()
      end
      )
      -- Setup for nvim-dap to use a red circle for breakpoints
      vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
      vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#FF0000' })

      dap.listeners.before.attach.dapui_config = function()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        ui.open()
      end
      -- dap.listeners.before.event_terminated.dapui_config = function()
      --   ui.close()
      -- end
      -- dap.listeners.before.event_exited.dapui_config = function()
      --   ui.close()
      -- end
    end,
  },
}
