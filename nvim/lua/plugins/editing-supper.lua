-- 编辑操作增强插件 
-- 提供:
-- vim 原生 Operators, Motions, Text Objects 操作增强插件
-- 
return {
  {-- vv 快速选择文本块
    'terryma/vim-expand-region', 
    config = function()
      -- 你可以在这里放置默认的映射/更新/等
      -- 你正在寻找的所有信息都在 `:help vim-expand-region` 中
      vim.api.nvim_set_keymap('v', 'v', '<Plug>(expand_region_expand)', { silent = true })
      vim.api.nvim_set_keymap('v', 'V', '<Plug>(expand_region_shrink)', { silent = true })    
    end, 
  },

  { -- 多光标编辑
    'mg979/vim-visual-multi',
    event = 'CursorHold',
    config = function()
      vim.g.VM_theme = 'ocean'
      vim.g.VM_highlight_matches = 'underline'
      vim.g.VM_maps = {
        ['Find Under'] = '<C-n>',
        ['Find Subword Under'] = '<C-n>',
        ['Select All'] = '<C-d>',
        ['Select h'] = '<C-Left>',
        ['Select l'] = '<C-Right>',
        ['Add Cursor Up'] = '<C-Up>',
        ['Add Cursor Down'] = '<C-Down>',
        ['Add Cursor At Pos'] = '<C-x>',
        ['Add Cursor At Word'] = '<C-w>',
        ['Move Left'] = '<C-S-Left>',
        ['Move Right'] = '<C-S-Right>',
        ['Remove Region'] = 'q',
        ['Increase'] = '+',
        ['Decrease'] = '_',
        ['Undo'] = 'u',
        ['Redo'] = '<C-r>',
      }
    end,
  },

  -- 在退出插入模式时自动切换输入法为英文模式
  -- 提供 Linux, Windows/WSL, Mac 全平台支持
  { 'keaising/im-select.nvim', opts = {} },

  'famiu/bufdelete.nvim',


}
