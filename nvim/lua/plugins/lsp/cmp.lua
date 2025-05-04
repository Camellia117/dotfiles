return {
  { -- 自动补全
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- 代码片段引擎
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          -- 构建步骤需要支持代码片段中的正则表达式。
          -- 此步骤在许多 Windows 环境中不受支持。
          -- 删除以下条件以在 Windows 上重新启用。
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` 包含各种预制代码片段。
          --    查看 README 了解单个语言/框架/插件的代码片段：
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        -- 'default'（推荐）提供类似内置补全的映射
        --   <c-y> 接受补全（[y]es）。
        --    如果你的 LSP 支持，它将自动导入。
        --    如果 LSP 发送了代码片段，它将展开代码片段。
        -- 'super-tab' 使用 Tab 接受补全
        -- 'enter' 使用 Enter 接受补全
        -- 'none' 不设置映射
        --
        -- 要了解为什么推荐 'default' 预设，
        -- 你需要阅读 `:help ins-completion`
        --
        -- 不过，认真地说，请阅读 `:help ins-completion`，它真的很棒！
        --
        -- 所有预设都包含以下映射：
        -- <tab>/<s-tab>: 在代码片段展开中向右/向左移动
        -- <c-space>: 打开菜单或在菜单已打开时显示文档
        -- <c-n>/<c-p> 或 <up>/<down>: 选择下一个/上一个项目
        -- <c-e>: 隐藏菜单
        -- <c-k>: 切换签名帮助
        --['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide' },
        ['<CR>'] = { 'select_and_accept', 'fallback' },

        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
        ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },

        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

        ['<Tab>'] = { 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

        ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
        --
        -- 查看 :h blink-cmp-config-keymap 了解如何定义自己的键映射
        preset = 'default',

        -- 对于更高级的 LuaSnip 键映射（例如选择选项节点、展开），请参阅：
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },

      appearance = {
        -- 'mono'（默认）适用于 'Nerd Font Mono' 或 'normal' 适用于 'Nerd Font'
        -- 调整间距以确保图标对齐
        nerd_font_variant = 'mono',
      },

      completion = {
        -- 默认情况下，你可以按 `<c-space>` 显示文档。
        -- 可选地，设置 `auto_show = true` 以在延迟后显示文档。
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },

      snippets = { preset = 'luasnip' },

      -- Blink.cmp 包括一个可选的、推荐的 Rust 模糊匹配器，
      -- 启用时会自动下载预构建的二进制文件。
      --
      -- 默认情况下，我们使用 Lua 实现，但你可以通过 `'prefer_rust_with_warning'` 启用
      -- Rust 实现。
      --
      -- 查看 :h blink-cmp-config-fuzzy 了解更多信息
      fuzzy = { implementation = 'lua' },

      -- 在你为函数输入参数时显示签名帮助窗口
      signature = { enabled = true },
    },
  },
}
