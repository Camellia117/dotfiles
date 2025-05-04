-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ 配置和安装插件 ]]
--
--  要检查当前插件状态，请运行
--    :Lazy
--
--  在此菜单中按 `?` 获取帮助。使用 `:q` 关闭窗口
--
--  要更新插件，可以运行
--    :Lazy update
--
-- 注意: 在这里安装你的插件。
require('lazy').setup({

  { -- 各种小型独立插件/模块的集合
    'echasnovski/mini.nvim',
    config = function()
      -- 更好的 Around/Inside 文本对象
      --
      -- 示例：
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- 添加/删除/替换包围（括号、引号等）。
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- ...还有更多！
      -- 查看：https://github.com/echasnovski/mini.nvim
    end,
  },

  -- 取消注释以下行并将你的插件添加到 `lua/custom/plugins/*.lua` 以开始使用。
  { import = 'plugins' },
  { import = 'plugins.lsp' },
  --
  -- 有关加载、来源和示例的更多信息，请参见 `:help lazy.nvim-🔌-plugin-spec`
  -- 或使用 telescope！
  -- 在普通模式下输入 `<space>sh` 然后输入 `lazy.nvim-plugin`
  -- 你可以在同一窗口中继续，使用 `<space>sr` 恢复上一次的 telescope 搜索
}, {
  ui = {
    -- 如果你使用 Nerd Font：将图标设置为空表，这将使用
    -- 默认的 lazy.nvim 定义的 Nerd Font 图标，否则定义一个 Unicode 图标表
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
