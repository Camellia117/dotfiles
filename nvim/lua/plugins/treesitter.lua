return {
  { -- 高亮、编辑和导航代码
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- 设置用于 opts 的主模块
    -- [[ 配置 Treesitter ]] 查看 `:help nvim-treesitter`
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      -- 自动安装未安装的语言
      auto_install = true,
      highlight = {
        enable = true,
        -- 某些语言依赖于 vim 的正则表达式高亮系统（例如 Ruby）来实现缩进规则。
        -- 如果你遇到奇怪的缩进问题，请将语言添加到
        -- additional_vim_regex_highlighting 和禁用缩进的语言列表中。
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    -- 还有其他 nvim-treesitter 模块可以用来与 nvim-treesitter 交互。
    -- 你应该探索一些，看看哪些感兴趣：
    --
    --    - 增量选择：已包含，查看 `:help nvim-treesitter-incremental-selection-mod`
    --    - 显示当前上下文：https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + 文本对象：https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },

}
