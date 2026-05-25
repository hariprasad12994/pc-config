local M = {
  'nvim-treesitter/nvim-treesitter',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-context',
  },
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local treesitter = require('nvim-treesitter')
    treesitter.install({
      'c',
      'cpp',
      'lua',
      'python',
      'cmake',
      'vim',
      'json',
      'rust',
      'zig',
      'haskell',
      'csv'
    })
  end,
}

return { M }
