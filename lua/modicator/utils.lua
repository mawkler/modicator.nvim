local M = {}

--- @param hl_group string
--- @return boolean
function M.highlight_exists(hl_group)
  local hl = vim.api.nvim_get_hl(0, { name = hl_group })
  return not vim.tbl_isempty(hl)
end

--- @return table<string>
function M.get_highlights()
  local modes = require('modicator').modes
  return vim.tbl_map(function(mode)
    return mode .. 'Mode'
  end, modes)
end

--- Gets the highlight `group`.
--- @param hl_name string
--- @return table<string, any>
function M.get_highlight(hl_name)
  return vim.api.nvim_get_hl(0, { name = hl_name, link = false })
end

return M
