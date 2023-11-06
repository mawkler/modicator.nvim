local modicator = require('modicator')

local M = {}

--- @param message string
M.warn = function(message)
  if modicator.get_options().show_warnings then
    local warning = string.format('modicator.nvim: %s', message)
    vim.notify(warning, vim.log.levels.WARN)
  end
end

return M
