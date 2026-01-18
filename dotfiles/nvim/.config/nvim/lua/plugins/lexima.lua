local M = {
  'cohama/lexima.vim',
  config = function()
    vim.fn['lexima#add_rule']({char='<', at="template\\s*\\%#", input_after='>', filetype='cpp'})
    vim.fn['lexima#add_rule']({char='>', at="\\%#>", leave=1, filetype='cpp'})
  end
}

return { M }
