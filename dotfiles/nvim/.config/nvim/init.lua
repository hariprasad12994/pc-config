vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.mouse = 'a'
vim.opt.number = true
vim.opt.hlsearch = false
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldenable = false

vim.g.mapleader = ','

-- Keybinding to source the vimrc file
vim.keymap.set('n', '<leader>s', ':source $MYVIMRC<cr>', {})
-- Keybinding to select all the text in the buffer
vim.keymap.set('n', '<leader>a', ':keepjumps normal! ggVG<cr>', {})
-- Keybinding to swap j and k, personal preference for navigating the buffer verticaly
vim.keymap.set({'n', 'v', 's', 'x'}, 'j', 'k', { noremap = true })
vim.keymap.set({'n', 'v', 's', 'x'}, 'k', 'j', { noremap = true })
-- Basic clipboard interaction
-- prerequisite - install xclip, tmux
vim.keymap.set({'n', 'x', 'v'}, '<leader>y', '"+y', {})
vim.keymap.set({'n', 'x', 'v'}, '<leader>p', '"+p', {})
-- Keybinding for toggling relative numbering
vim.keymap.set({'n', 'x', 'v', 's'}, '<leader>l', ":set invrelativenumber<cr>", { noremap = true})
-- Keybinding for switching tabs
vim.keymap.set('n', '<Tab>', ':bnext<cr>', {})
vim.keymap.set('n', '<S-Tab>', ':bprevious<cr>', {})
vim.keymap.set('n', '<C-k>', ':wincmd j<cr>', {})
vim.keymap.set('n', '<C-j>', ':wincmd k<cr>', {})
vim.keymap.set('n', '<C-h>', ':wincmd h<cr>', {})
vim.keymap.set('n', '<C-l>', ':wincmd l<cr>', {})

local plugin_install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local is_bootstrapping = false
if vim.fn.empty(vim.fn.glob(plugin_install_path)) > 0 then
  print("Installing Packer...")
  local packer_url = 'https://github.com/wbthomason/packer.nvim'
  vim.fn.system({'git', 'clone', '--depth', '1', packer_url, plugin_install_path})
  -- https://github.com/wbthomason/packer.nvim/issues/710
  vim.o.runtimepath = vim.fn.stdpath('data') .. '/site/pack/*/start/*,' .. vim.o.runtimepath
  vim.cmd('packadd packer.nvim')
  print('Done')
  is_bootstrapping = true
end

require('packer').startup(function(use)
  use { 'wbthomason/packer.nvim' }
  use {
    'neovim/nvim-lspconfig',
    requires = {
      -- For automatic LSP installation to stdpath
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'j-hui/fidget.nvim'
    },
  }
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/vim-vsnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path'
    }
  }
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.2',
    branch = '0.1.x',
    requires = {
      'nvim-lua/plenary.nvim',
      'BurntSushi/ripgrep'
    }
  }
  use {
    'nvim-telescope/telescope-fzf-native.nvim',
    run = 'make',
    cond = vim.fn.executable 'make' == 1
  }
  use { 'numToStr/Comment.nvim' }
  use { 'nvim-tree/nvim-tree.lua' }
  use { 'nvim-treesitter/nvim-treesitter' }
  use { 
    'nvim-treesitter/nvim-treesitter-textobjects',
    after = 'nvim-treesitter'
  }
  use { 'kylechui/nvim-surround' }
  use { 'folke/trouble.nvim' }
  use { 'akinsho/bufferline.nvim' }
  use { 'nvim-lualine/lualine.nvim' }
  use { 'joshdick/onedark.vim' }
  use { 'folke/tokyonight.nvim' }
  use { 'ellisonleao/gruvbox.nvim' }

  if is_bootstrapping then
    require('packer').sync()
  end
end)

if is_bootstrapping then
  print('Plugins are being installed, wait until Packer completes and restart over')
  return
end

-- Automatically source and recompile packer whenever init.lua is saved
local packer_group = vim.api.nvim_create_augroup( 'Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source<afile> | PackerSync',
  group = packer_group,
  pattern = vim.fn.expand '$MYVIMRC'
})

vim.opt.termguicolors = true
vim.opt.background = dark
vim.cmd('colorscheme tokyonight-moon')

vim.opt.showmode = false
require('lualine').setup({
  options = {
    theme = 'onedark',
    icons_enabled = true,
    component_separators = '|',
    section_seperators = ''
  }
})

require('Comment').setup()

require('nvim-tree').setup()
vim.keymap.set({'n', 'v', 's', 'x'}, '<C-e>', "<cmd>NvimTreeToggle<cr>")

require('nvim-treesitter.configs').setup({
  ensure_installed = { 'c', 'cpp', 'python', 'json', 'lua', 'rust', 'vim' },
  highlight = { enable = true },
  indent = { enable = true, disable = { 'python' } },
})

-- Diagnostics keymaps
vim.keymap.set('n', 'd[', vim.diagnostic.goto_prev)
vim.keymap.set('n', 'd]', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

local normal_mode_map = function(keys, func)
  vim.keymap.set('n', keys, func, { silent = true })
end

normal_mode_map('<leader>ff', ":Telescope find_files<cr>")
pcall(require('telescope').load_extension, 'fzf')
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [w]ord' })
vim.keymap.set('n', '<leader>lg', require('telescope.builtin').live_grep, { desc = '[L]ive [G]rep' })
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').current_buffer_fuzzy_find, { desc = '[B]uffer [L]ive [G]rep' })
vim.keymap.set('n', '<leader>ls', require('telescope.builtin').treesitter, { desc = '[L]ist [S]symbol' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })

-- For debugging purposes, turn trace level LSP logging by uncommenting the following line
-- vim.lsp.set_log_level('trace')

local on_attach = function(_, bufnr)
  local normal_mode_map = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end
  
  normal_mode_map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  normal_mode_map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  normal_mode_map('<leader>gd', vim.lsp.buf.definition, '[G]oto [D]efintion')
  normal_mode_map('<leader>gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  normal_mode_map('<leader>gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  normal_mode_map('<leader>td', vim.lsp.buf.type_definition, '[T]ype [D]efintion')
  normal_mode_map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  normal_mode_map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orskpace [S]ymbols')
  normal_mode_map('<leader>d', vim.lsp.buf.hover, 'Hover [D]ocumentation')
  normal_mode_map('<leader>gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  normal_mode_map('<leader>D', vim.lsp.buf.signature_help, 'Signature Documentation')
  normal_mode_map('<leader>ic', vim.lsp.buf.incoming_calls, '[I]ncoming [C]alls')
  normal_mode_map('<leader>oc', vim.lsp.buf.outgoing_calls, '[O]utgoing [C]alls')

  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

local language_servers = {
  clangd = {
    -- https://www.reddit/com/r/neovim/comments/wzzqmw/using_nvimcmp_and_lsp_signatures_how_can_i_move/
    cmd = { "clangd", "--function-arg-placeholders=0", "--completion-style=detailed", "--query-driver=/usr/bin/gcc,/usr/bin/g++" },
    settings = {}
  },
  pyright = { cmd = {}, settings = {} },
  rust_analyzer = { cmd = {}, settings = {} },
  jsonls = { cmd = {}, settings = {} }
}

-- nvim_cmp supports additional completion capabilities, so broadcast to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Setup mason for external tooling
require('mason').setup()

local mason_lsp_config = require 'mason-lspconfig'
mason_lsp_config.setup {
  ensure_installed = vim.tbl_keys(language_servers)
}
mason_lsp_config.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = language_servers[server_name]['settings']
    }
  end,
  ['clangd'] = function()
    require('lspconfig')['clangd'].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      cmd = language_servers['clangd']['cmd'],
      settings = language_servers['clangd']['settings']
    }
  end
}

-- Turn on LSP status information
require('fidget').setup()

-- Setup nvim_cmp
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
local cmp = require 'cmp'
cmp.setup ({
  -- Empty snippet configuration
  -- https://github.com/hrsh7th/nvim-cmp/issues/373
  snippet = {
    expand = function(args)
      vim.fn['vsnip#anonymous'](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-h>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-e>'] = cmp.mapping.close(),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true
    }),
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'buffer' },
    { name = 'path' }
  }),
  completion = { completeopt = 'menu,menuone,noselect' }
})


require('trouble').setup {
  icons = false,
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
}

vim.keymap.set('n', '<leader>xx', '<cmd>TroubleToggle<cr>', { silent = true, noremap = true })
vim.keymap.set('n', '<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<cr>', { silent = true, noremap = true })
vim.keymap.set('n', '<leader>xd', '<cmd>TroubleToggle document_diagnostics<cr>', { silent = true, noremap = true })
vim.keymap.set('n', '<leader>xl', '<cmd>TroubleToggle loclist<cr>', { silent = true, noremap = true })
vim.keymap.set('n', '<leader>xq', '<cmd>TroubleToggle quickfix<cr>', { silent = true, noremap = true })
vim.keymap.set('n', 'gR', '<cmd>TroubleToggle lsp_references<cr>', { silent = true, noremap = true })

require('bufferline').setup()

require('nvim-surround').setup()

local function auto_update_path()
  local buf = vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(buf)
  if vim.fn.isdirectory(bufname) or vim.fn.isfile(bufname) then
    if not require("nvim-tree.view").is_visible() then
      vim.api.nvim_input('<C-e>')
    end
    require("nvim-tree.api").tree.find_file(vim.fn.expand("%:p"))
    vim.api.nvim_input('<C-h>')
  end
end

vim.keymap.set('n', '<leader>se', auto_update_path, { desc = '[S]ync [E]xplorer' })
