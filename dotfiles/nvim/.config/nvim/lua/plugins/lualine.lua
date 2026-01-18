local M = {
  'nvim-lualine/lualine.nvim',
  config = function()
    require('lualine').setup({
      options = {
        themes = 'dracula',
        icons_enabled = true,
        component_separators = '|',
        section_separators = ''
      }
    })
  end
}

return { M }
