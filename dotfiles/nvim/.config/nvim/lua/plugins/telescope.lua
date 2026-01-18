-- { '<leader>n', function() require 'telescope.builtin'.find_files() end, mode = 'n' },


local M = {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    { 'nvim-telescope/telescope-live-grep-args.nvim' }
  },
  -- keys = {
  --   vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files)
  --   vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [w]ord' })
  --   vim.keymap.set('n', '<leader>mlg', require('telescope.builtin').live_grep, { desc = '[M]nimal [L]ive [G]rep' })
  --   vim.keymap.set('n', '<leader>fg', require('telescope.builtin').current_buffer_fuzzy_find, { desc = '[B]uffer [L]ive [G]rep' })
  --   vim.keymap.set('n', '<leader>ls', require('telescope.builtin').treesitter, { desc = '[L]ist [S]symbol' })
  --   vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
  --   vim.keymap.set("n", "<leader>lg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", { desc = '[L]ive [G]rep' })
  --   vim.keymap.set('n', '<leader>bl', require('telescope.builtin').buffers, { desc = '[B]uffer [L]ist' })
  --   vim.keymap.set('n', '<leader>ml', require('telescope.builtin').marks, { desc = '[M]ark [L]ist' })
  --   vim.keymap.set('n', '<leader>gc', require('telescope.builtin').git_commits, { desc = '[G]it [C]ommit' })
  -- },
  config = function()
    vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files)
    vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [w]ord' })
    vim.keymap.set('n', '<leader>mlg', require('telescope.builtin').live_grep, { desc = '[M]nimal [L]ive [G]rep' })
    vim.keymap.set('n', '<leader>fg', require('telescope.builtin').current_buffer_fuzzy_find, { desc = '[B]uffer [L]ive [G]rep' })
    vim.keymap.set('n', '<leader>ls', require('telescope.builtin').treesitter, { desc = '[L]ist [S]symbol' })
    vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set("n", "<leader>lg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", { desc = '[L]ive [G]rep' })
    vim.keymap.set('n', '<leader>bl', require('telescope.builtin').buffers, { desc = '[B]uffer [L]ist' })
    vim.keymap.set('n', '<leader>ml', require('telescope.builtin').marks, { desc = '[M]ark [L]ist' })
    vim.keymap.set('n', '<leader>gc', require('telescope.builtin').git_commits, { desc = '[G]it [C]ommit' })
 
  end
}

return { M }
