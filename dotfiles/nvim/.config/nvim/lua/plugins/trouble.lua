local M = {
  'folke/trouble.nvim',
  -- keys = {  
  --   { vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { silent = true, noremap = true }) },
  --   { vim.keymap.set('n', '<leader>xw', '<cmd>TroubleToggle diagnostics toggle focus=false filter.buf=0<cr>', { silent = true, noremap = true }) }
  -- },
  config = function()
    require('trouble').setup({
      -- icons = false,
      fold_open = 'v', -- icon used for open folds
      fold_closed = '>', -- icon used for closed folds,
      indent_lines = false, -- add an indent guide below the fold icons
      signs = {
        -- icons / text used for a diagnostics
        error = 'X',
        warning = 'W',
        hint = 'H',
        information = 'i'
      }
    })

    vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { silent = true, noremap = true })
    vim.keymap.set('n', '<leader>xw', '<cmd>TroubleToggle diagnostics toggle focus=false filter.buf=0<cr>', { silent = true, noremap = true })
  end
}


return { M }
