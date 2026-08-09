local THEME = 'tokyonight' -- 'gruvbox' | 'tokyonight'

local function activate(name)
  return function(_, opts)
    require(name).setup(opts)
    if THEME == name then
      vim.cmd.colorscheme(name)
    end
  end
end

local M = {
  {
    'ellisonleao/gruvbox.nvim',
    config = activate('gruvbox'),
  },
  {
    'folke/tokyonight.nvim',
    opts = {
      style = 'moon'
    },
    config = activate('tokyonight'),
  }
}

return { M }
