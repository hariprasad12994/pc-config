local function sync_explorer_with_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(buf)

  if vim.fn.isdirectory(bufname) or vim.fn.isfile(bufname) then
    if not require('nvim-tree.view').is_visible() then
      vim.api.nvim_input('<C-e>')
    end

    require('nvim-tree.api').tree.find_file(vim.fn.expand('%:p'))
    vim.api.nvim_input('<C-h>')
  end
end


local M = {
  'nvim-tree/nvim-tree.lua',
  -- keys = {
  --   { vim.keymap.set({'n', 'v', 's', 'x'}, '<C-e>', "<cmd>NvimTreeToggle<cr>") },
  --   { vim.keymap.set('n', '<leader>se', sync_explorer_with_buffer, { desc = '[S]ync [E]xplorer' }) }
  -- },
  config = function() 
    require('nvim-tree').setup()
    vim.keymap.set({'n', 'v', 's', 'x'}, '<C-e>', "<cmd>NvimTreeToggle<cr>")
    vim.keymap.set('n', '<leader>se', sync_explorer_with_buffer, { desc = '[S]ync [E]xplorer' })
  end
}

return { M }
