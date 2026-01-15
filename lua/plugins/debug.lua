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
			local dap = require("dap")
			local ui = require("dapui")

			require("dapui").setup()
			require("nvim-dap-virtual-text").setup({})

			pcall(function()
				require("dap-python").setup("python")
			end)

			dap.configurations.python = {
				{
					name = "Python: Run file with args",
					type = "python",
					request = "launch",
					program = "${file}",
					cwd = "${workspaceFolder}",
					console = "integratedTerminal",
					stopOnEntry = false,
					justMyCode = false,
					args = function()
						local args_string = vim.fn.input("Arguments: ")
						return vim.split(args_string, " +")
					end,
				},
				{
					name = "Python: Run Pytest",
					type = "python",
					request = "launch",
					module = "pytest",
					cwd = "${workspaceFolder}",
					console = "integratedTerminal",
					stopOnEntry = false,
					justMyCode = false,
					connect = function()
						local test_path = vim.fn.input("test path [.]: ") or "."
						return { args = { "--pdb", test_path, "-v" } }
					end,
				},
				{
					name = "Python: Attach to process",
					type = "python",
					request = "attach",
					connect = function()
						local port = tonumber(vim.fn.input("Port [5678]: "))
						return {
							host = "127.0.0.1",
							port = port or 5678,
						}
					end,
					justMyCode = false,
				},
			}

			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debugger: Toggle breakpoint" })
			vim.keymap.set("n", "<leader>dr", dap.run_to_cursor, { desc = "Debugger: Run to cursor" })

			-- Eval var under cursor
			vim.keymap.set("n", "<leader>?", function()
				require("dapui").eval(nil, { enter = true })
			end, { desc = "Debugger: Eval var under cursor" })

			vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Debugger: [c]ontinue" })
			vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Debugger: step [i]nto" })
			vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Debugger: step [o]ver" })
			vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Debugger: step [O]ut" })
			vim.keymap.set("n", "<F5>", dap.step_back, { desc = "Debugger: Step back" })
			vim.keymap.set("n", "<F6>", dap.restart, { desc = "Debugger: Restart" })
			vim.keymap.set("n", "<F12>", function()
				dap.terminate()
				ui.close()
			end, { desc = "Debugger: Close debugging session" })

			-- Setup for nvim-dap to use a red circle for breakpoints
			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
			vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#FF0000" })

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
