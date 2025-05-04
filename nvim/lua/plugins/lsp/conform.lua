return {
  { -- 自动格式化
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>t',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer（格式化缓冲区）',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- 禁用 "format_on_save lsp_fallback" 功能，适用于没有
        -- 标准化代码风格的语言。你可以在这里添加其他语言
        -- 或重新启用被禁用的语言。
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        -- nix = { 'alejandra' },
        nix = { 'nixfmt' },
        -- Conform 也可以顺序运行多个格式化工具
        -- python = { "isort", "black" },
        --
        -- 你可以使用 'stop_after_first' 来运行列表中的第一个可用格式化工具
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },
}
