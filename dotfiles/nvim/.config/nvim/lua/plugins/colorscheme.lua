local themes = { 'gruvbox', 'tokyonight' }
local default_theme = 'gruvbox'

-- Active theme lives in nvim's own state dir, not this tracked file, so
-- switching (:ThemeToggle) doesn't dirty the repo - mirrors the tmux theme
-- state file under ~/.local/state/tmux/theme.
local state_file = vim.fn.stdpath('state') .. '/theme'

local function read_theme()
  local f = io.open(state_file, 'r')
  if not f then return default_theme end
  local name = f:read('*l')
  f:close()
  return vim.tbl_contains(themes, name) and name or default_theme
end

local function write_theme(name)
  vim.fn.mkdir(vim.fn.stdpath('state'), 'p')
  local f = io.open(state_file, 'w')
  if f then
    f:write(name)
    f:close()
  end
end

local THEME = read_theme()

local function activate(name)
  return function(_, opts)
    require(name).setup(opts)
    if THEME == name then
      vim.cmd.colorscheme(name)
    end
  end
end

vim.api.nvim_create_user_command('ThemeToggle', function()
  THEME = THEME == 'gruvbox' and 'tokyonight' or 'gruvbox'
  write_theme(THEME)
  vim.cmd.colorscheme(THEME)
end, {})

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
