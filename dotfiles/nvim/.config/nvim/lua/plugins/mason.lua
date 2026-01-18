local M = {
  'williamboman/mason.nvim',
  dependencies = {
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
  },
  config = function()
    require('mason').setup()
    require('mason-lspconfig').setup({
      automatic_installation = true,
      ensure_installed = {
        'clangd', 'rust_analyzer', 'pyright', 'ts_ls', 'lua_ls', 'jsonls', 'zls'
      }
    })
  end
}

return { M }
