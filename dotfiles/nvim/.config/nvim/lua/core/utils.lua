local M = {}

function M.map(mode, key_binding, action, options)
  options = options or {}
  vim.keymap.set(mode, key_binding, action, options)
end

return { M }
