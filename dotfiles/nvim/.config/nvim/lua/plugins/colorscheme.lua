local M = {
  {
    'ellisonleao/gruvbox.nvim',
  },
  {
    'folke/tokyonight.nvim',
    opts = {
      style = 'moon'
    },
    config = function()
      vim.cmd([[colorscheme tokyonight]])
    end
  }
}

return { M }
