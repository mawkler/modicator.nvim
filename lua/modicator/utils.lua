local modicator = require('modicator')

local M = {}

--- @param message string
M.warn = function(message)
  if modicator.get_options().show_warnings then
    local warning = string.format('modicator.nvim: %s', message)
    vim.notify(warning, vim.log.levels.WARN)
  end
end

--- @param hl_group string
--- @return boolean
M.highlight_exists = function(hl_group)
  local hl = vim.api.nvim_get_hl(0, { name = hl_group })
  return not vim.tbl_isempty(hl)
end

--- @return table<string>
M.get_highlights = function()
  local modes = require('modicator').modes
  return vim.tbl_map(function(mode)
    return mode .. 'Mode'
  end, modes)
end

--- Gets the highlight `group`.
--- @param hl_name string
--- @return table<string, any>
M.get_highlight = function(hl_name)
  return vim.api.nvim_get_hl(0, { name = hl_name, link = false })
end

return M
