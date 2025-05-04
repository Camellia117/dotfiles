return {
  -- 注意: 插件可以指定依赖项。
  -- 依赖项也是正确的插件规范 - 你可以在顶层对插件做的任何事情，也可以对依赖项做。
  -- 使用 `dependencies` 键指定特定插件的依赖项

  -- LSP 插件
  {
    -- `lazydev` 配置 Lua LSP，用于你的 Neovim 配置、运行时和插件
    -- 用于补全、注释和 Neovim API 的签名
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- 当找到 `vim.uv` 单词时加载 luvit 类型
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- 主 LSP 配置
    'neovim/nvim-lspconfig',
    dependencies = {
      -- 自动安装 LSP 和相关工具到 Neovim 的 stdpath
      -- Mason 必须在其依赖项之前加载，因此我们需要在这里设置它。
      -- 注意: `opts = {}` 等同于调用 `require('mason').setup({})`
      { 'williamboman/mason.nvim', opts = {} },
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- 为 LSP 提供有用的状态更新。
      { 'j-hui/fidget.nvim', opts = {} },

      -- 提供 blink.cmp 的额外功能
      'saghen/blink.cmp',
    },
    config = function()
      -- 简要说明: **什么是 LSP？**
      --
      -- LSP 是一个你可能听过但不一定理解的缩写。
      --
      -- LSP 代表语言服务器协议（Language Server Protocol）。它是一个帮助编辑器
      -- 和语言工具以标准化方式通信的协议。
      --
      -- 通常，你有一个“服务器”，它是一个工具，用于理解特定语言
      -- （例如 `gopls`、`lua_ls`、`rust_analyzer` 等）。这些语言服务器
      -- （有时称为 LSP 服务器，但这有点像 ATM 机）是独立的
      -- 进程，与某个“客户端”通信 - 在这里是 Neovim！
      --
      -- LSP 为 Neovim 提供以下功能：
      --  - 跳转到定义
      --  - 查找引用
      --  - 自动补全
      --  - 符号搜索
      --  - 以及更多！
      --
      -- 因此，语言服务器是需要单独安装的外部工具，
      -- 这就是 `mason` 和相关插件的作用。
      --
      -- 如果你想了解 lsp 和 treesitter 的区别，可以查看优雅撰写的帮助部分 `:help lsp-vs-treesitter`

      -- 此函数在 LSP 附加到特定缓冲区时运行。
      -- 也就是说，每次打开一个与 LSP 关联的新文件时
      -- （例如，打开 `main.rs` 与 `rust_analyzer` 关联）此函数将被执行以配置当前缓冲区
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          -- 注意: 记住 Lua 是一种真正的编程语言，因此可以定义小的帮助和实用函数，
          -- 这样你就不必重复自己。
          --
          -- 在这种情况下，我们创建了一个函数，让我们更容易定义特定于 LSP 的映射。
          -- 它每次为我们设置模式、缓冲区和描述。
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- 重命名光标下的变量。
          -- 大多数语言服务器支持跨文件重命名等。
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- 执行代码操作，通常需要将光标放在错误或
          -- LSP 的建议上以激活此功能。
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

          -- 查找光标下单词的引用。
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- 跳转到光标下单词的实现。
          -- 当你的语言有声明类型而没有实际实现的方法时很有用。
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- 跳转到光标下单词的定义。
          -- 这是变量首次声明的位置，或者函数定义的位置等。
          -- 要跳回，请按 <C-t>。
          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- 警告: 这不是跳转到定义，而是跳转到声明。
          -- 例如，在 C 中，这会带你到头文件。
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- 模糊查找当前文档中的所有符号。
          -- 符号是变量、函数、类型等。
          map('gO', require('telescope.builtin').lsp_document_symbols, '打开文档符号')

          -- 模糊查找当前工作区中的所有符号。
          -- 类似于文档符号，但搜索整个项目。
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, '打开工作区符号')

          -- 跳转到光标下单词的类型。
          -- 当你不确定变量的类型时很有用，你想查看
          -- 它的 *类型* 的定义，而不是它的 *定义*。
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

          -- 此函数解决了 neovim nightly（版本 0.11）和稳定版（版本 0.10）之间的差异
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer 某些 LSP 仅在特定文件中支持方法
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- 以下两个自动命令用于高亮显示光标下单词的引用，
          -- 当光标停留一段时间时。
          -- 查看 `:help CursorHold` 了解何时执行此操作
          --
          -- 当你移动光标时，高亮将被清除（第二个自动命令）。
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- 以下代码创建了一个键映射，用于在代码中切换内联提示，
          -- 如果你使用的语言服务器支持它们
          --
          -- 这可能是多余的，因为它们会占用一些代码空间
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- 诊断配置
      -- 查看 :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      -- LSP 服务器和客户端能够相互通信它们支持的功能。
      -- 默认情况下，Neovim 不支持 LSP 规范中的所有内容。
      -- 当你添加 blink.cmp、luasnip 等时，Neovim 现在有了 *更多* 的功能。
      -- 因此，我们使用 blink.cmp 创建新的功能，然后将其广播到服务器。
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      -- 启用以下语言服务器
      -- 随意在此处添加/删除任何你想要的 LSP。它们将自动安装。
      --
      -- 在以下表中添加任何额外的覆盖配置。可用的键是：
      -- - cmd (table): 覆盖用于启动服务器的默认命令
      -- - filetypes (table): 覆盖服务器的默认关联文件类型列表
      -- - capabilities (table): 覆盖功能字段。可用于禁用某些 LSP 功能。
      -- - settings (table): 覆盖初始化服务器时传递的默认设置。
      --   例如，要查看 `lua_ls` 的选项，你可以访问: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},
        -- ... 等等。查看 `:help lspconfig-all` 获取所有预配置 LSP 的列表
        --
        -- 某些语言（如 typescript）有整个语言插件可能很有用：
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- 但对于许多设置，LSP (`ts_ls`) 就可以很好地工作
        -- ts_ls = {},
        --

        lua_ls = {
          -- cmd = { ... },
          -- filetypes = { ... },
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- 你可以切换以下选项以忽略 Lua_LS 的烦人的 `missing-fields` 警告
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }
      local local_servers = {
        nixd = {
          cmd = { "nixd" }, -- nixd 的可执行文件路径
          filetypes = { "nix" }, -- 关联的文件类型
          root_dir = require('lspconfig.util').root_pattern(".git", "*.nix"), -- 项目根目录检测
          settings = {
            -- 根据需要添加 nixd 的自定义设置
          },
        },    
      }

      -- 确保安装上述服务器和工具
      --
      -- 要检查已安装工具的当前状态和/或手动安装其他工具，
      -- 你可以运行
      --    :Mason
      --
      -- 你可以在此菜单中按 `g?` 获取帮助。
      --
      -- `mason` 必须在之前设置：要配置其选项，请参阅
      -- `nvim-lspconfig` 的 `dependencies` 表。
      --
      -- 你可以在此处添加其他工具，Mason 会为你安装它们，
      -- 以便它们可以在 Neovim 中使用。
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- 用于格式化 Lua 代码
        -- 'alejandra', -- nix 格式化工具
        -- 'nixfmt', -- 请使用nixpkgs.nixfmt-rfc-style
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {}, -- 显式设置为空表（Kickstart 通过 mason-tool-installer 填充安装）
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or local_servers[server_name] or {}
            -- 这仅处理通过上述服务器配置显式传递的值覆盖。
            -- 当禁用某些 LSP 功能时很有用（例如，为 ts_ls 关闭格式化功能）
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
}
