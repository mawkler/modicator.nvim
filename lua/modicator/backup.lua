local M = {}

--- @type table
local cursor_line_nr_hl_backup = nil

function M.backup_default_cursorline_hl()
  local hl = require('modicator.utils').get_highlight('CursorLineNr')
  cursor_line_nr_hl_backup = hl
end

function M.restore_default_cursorline_hl()
  if cursor_line_nr_hl_backup then
    vim.api.nvim_set_hl(0, 'CursorLineNr', cursor_line_nr_hl_backup)
  end
end

return M
