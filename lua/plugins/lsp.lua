-- Stolen from Kickstart
return {
	{ -- LSP Configuration & Plugins
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Automatically install LSPs and related tools to stdpath for neovim
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			-- Useful status updates for LSP.
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ "j-hui/fidget.nvim", opts = {} },

			-- Additional lua configuration, makes nvim stuff amazing!
			{
				"folke/neodev.nvim",
				config = function()
					require("neodev").setup()
				end,
			},
			{
				"SmiteshP/nvim-navic",
				opts = {
					highlight = true,
					depth_limit = 5,
				},
			},
		},
		config = function()
			--  This function gets run when an LSP attaches to a particular buffer.
			--    That is to say, every time a new file is opened that is associated with
			--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			--    function will be executed to configure the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- NOTE: Remember that lua is a real programming language, and as such it is possible
					-- to define small helper and utility functions so you don't have to repeat yourself
					-- many times.
					--
					-- In this case, we create a function that lets us more easily define mappings specific
					-- for LSP related items. It sets the mode, buffer and description for us each time.
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Jump to the definition of the word under your cursor.
					--  This is where a variable was first declared, or where a function is defined, etc.
					--  To jump back, press <C-t>.
					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

					-- Find references for the word under your cursor.
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

					-- Jump to the implementation of the word under your cursor.
					--  Useful when your language has ways of declaring types without an actual implementation.
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

					-- Jump to the type of the word under your cursor.
					--  Useful when you're not sure what type a variable is and you want to see
					--  the definition of its *type*, not where it was *defined*.
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")

					-- Fuzzy find all the symbols in your current document.
					--  Symbols are things like variables, functions, types, etc.
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")

					-- Fuzzy find all the symbols in your current workspace
					--  Similar to document symbols, except searches over your whole project.
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)

					-- Rename the variable under your cursor
					--  Most Language Servers support renaming across files, etc.
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

					-- Opens a popup that displays documentation about the word under your cursor
					--  See `:help K` for why this keymap
					map("K", vim.lsp.buf.hover, "Hover Documentation")

					-- Add border to hover documentation
					vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
						border = "rounded",
						max_width = 120,
						max_height = 40,
					})

					-- Open a floating window showing the definition of the symbol under the cursor.
					-- Shift + ? types a `?`, so we map on "?".
					map("?", function()
						if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then
							vim.notify("No LSP client attached", vim.log.levels.WARN)
							return
						end
						vim.lsp.buf_request(0, "textDocument/definition", vim.lsp.util.make_position_params(), function(err, result)
							if err then
								vim.notify("Definition request failed: " .. vim.inspect(err), vim.log.levels.ERROR)
								return
							end
							-- Some servers return a single Location instead of a list
							result = vim.islist(result) and result or { result }
							if #result == 0 then
								vim.notify("No definition found", vim.log.levels.WARN)
								return
							end

							local loc = result[1]
							local uri = loc.uri or loc.targetUri
							local range = loc.range or loc.targetSelectionRange
							local def_buf = vim.uri_to_bufnr(uri)
							vim.fn.bufload(def_buf)
							local def_lines = vim.api.nvim_buf_get_lines(def_buf, 0, -1, false)

							-- Grab a chunk of lines around the definition
							local first = math.max(1, range.start.line - 4)
							local last = math.min(#def_lines, first + 39)
							local content = {}
							for i = first, last do
								content[#content + 1] = def_lines[i]
							end

							-- Show it in a disposable scratch float with syntax highlighting
							local buf = vim.api.nvim_create_buf(false, true)
							vim.bo[buf].buftype = "nofile"
							vim.bo[buf].bufhidden = "wipe"
							vim.bo[buf].filetype = vim.bo[def_buf].filetype
							vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
							vim.api.nvim_buf_set_name(buf, vim.fn.fnamemodify(vim.api.nvim_buf_get_name(def_buf), ":t"))

							local width = math.min(100, math.floor(vim.o.columns * 0.8))
							local height = math.min(#content, math.floor(vim.o.lines * 0.6))
							local win = vim.api.nvim_open_win(buf, true, {
								relative = "editor",
								width = width,
								height = height,
								col = math.floor((vim.o.columns - width) / 2),
								row = math.floor((vim.o.lines - height) / 2),
								border = "rounded",
								style = "minimal",
							})
							vim.wo[win].number = true
							vim.api.nvim_win_set_cursor(win, { range.start.line + 1 - (first - 1), range.start.character })
							vim.api.nvim_win_call(win, function()
								vim.cmd("normal! zz")
							end)

							-- Close with q / <Esc>, jump into the file with <CR>
							local function close()
								pcall(vim.api.nvim_win_close, win, true)
							end
							vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })
							vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true })
							vim.keymap.set("n", "<CR>", function()
								close()
								vim.api.nvim_win_set_buf(0, def_buf)
								vim.api.nvim_win_set_cursor(0, { range.start.line + 1, range.start.character })
							end, { buffer = buf, nowait = true })
						end)
					end, "Peek Definition")

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					map("<leader>fm", function()
						vim.lsp.buf.format()
					end, "Format current buffer with LSP")
					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.server_capabilities.documentSymbolProvider then
						require("nvim-navic").attach(client, event.buf)
					end
					if client and client:supports_method("textDocument/inlayHint") then
						vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
					end
					if client and client.server_capabilities.documentHighlightProvider then
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							callback = vim.lsp.buf.clear_references,
						})
					end
				end,
			})

			-- LSP servers and clients are able to communicate to each other what features they support.
			--  By default, Neovim doesn't support everything that is in the LSP Specification.
			--  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
			--  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			-- Enable the following language servers
			--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
			--
			--  Add any additional override configuration in the following tables. Available keys are:
			--  - cmd (table): Override the default command used to start the server
			--  - filetypes (table): Override the default list of associated filetypes for the server
			--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
			--  - settings (table): Override the default settings passed when initializing the server.
			--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
			local servers = {
				gopls = {},
			basedpyright = {
				settings = {
					basedpyright = {
						analysis = {
							diagnosticMode = "openFilesOnly",
							typeCheckingMode = "basic",
							inlayHints = {
								callArgumentNames = true,
								variableTypes = true,
								functionReturnTypes = true,
								genericTypes = true,
							},
						},
					},
				},
			},
				html = { filetypes = { "html", "htmldjango", "twig", "hbs" } },
				templ = {},
				lua_ls = {
					-- cmd = {...},
					-- filetypes { ...},
					-- capabilities = {},
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							workspace = {
								checkThirdParty = false,
								-- Tells lua_ls where to find all the Lua files that you have loaded
								-- for your neovim configuration.
								library = {
									"${3rd}/luv/library",
									unpack(vim.api.nvim_get_runtime_file("", true)),
								},
								-- If lua_ls is really slow on your computer, you can try this instead:
								-- library = { vim.env.VIMRUNTIME },
							},
							completion = {
								callSnippet = "Replace",
							},
							-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
							-- diagnostics = { disable = { 'missing-fields' } },
						},
					},
				},
			}

			-- Ensure the servers and tools above are installed
			--  To check the current status of installed tools and/or manually install
			--  other tools, you can run
			--    :Mason
			--
			--  You can press `g?` for help in this menu
			require("mason").setup()

			-- You can add other tools here that you want Mason to install
			-- for you, so that they are available from within Neovim.
			local ensure_installed = vim.tbl_keys(servers or {})
			-- Remove pyright since it's installed globally, not by Mason
			ensure_installed = vim.tbl_filter(function(s)
				return s ~= "pyright"
			end, ensure_installed)
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format lua code
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for tsserver)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						vim.lsp.config(server_name, server)
						vim.lsp.enable(server_name)
					end,
				},
			})

			-- DISABLE PYRIGHT
			-- Manually set up pyright because it is installed globally, not via Mason
			-- local pyright_config = servers.pyright or {}
			-- pyright_config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, pyright_config.capabilities or {})
			-- vim.lsp.config('pyright', pyright_config)
			-- vim.lsp.enable('pyright')
		end,
	},
	{ -- autocomplete
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			-- Adding lspkind for some icons
			"onsails/lspkind.nvim",
		},
		config = function()
			-- See `:help cmp`

			local cmp = require("cmp")
			local lspkind = require("lspkind")

			cmp.setup({
				preselect = cmp.PreselectMode.None,
				completeopt = "menu,menuone,noinsert",
				mapping = {
					["<CR>"] = function(fallback)
						if cmp.visible() and cmp.get_active_entry() then
							cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
						else
							fallback()
						end
					end,
					["<S-CR>"] = function(fallback)
						if cmp.visible() and cmp.get_active_entry() then
							cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
						else
							fallback()
						end
					end,
					["<Tab>"] = function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						else
							fallback()
						end
					end,
					["<S-Tab>"] = function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end,
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "buffer" },
					{ name = "path" },
				},
				formatting = {
					format = lspkind.cmp_format({
						menu = {
							nvim_lsp = "[LSP]",
							buffer = "[buf]",
							path = "[path]",
						},
					}),
				},
				experimental = {
					ghost_text = true,
				},
				window = {
					documentation = {
						border = "rounded",
						winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
						max_width = 50,
						min_width = 50,
						max_height = math.floor(vim.o.lines * 0.4),
						min_height = 3,
					},
				},
			})
		end,
	},
}
