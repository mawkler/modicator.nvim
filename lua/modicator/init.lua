local api = vim.api

local M = {}

M.get_fg_highlight = function(group)
  return api.nvim_get_hl_by_name(group, true).foreground
end

local options = {
  highlight = {
    modes = {
      ['n']  = M.get_fg_highlight('CursorLineNr'),
      ['i']  = M.get_fg_highlight('Question'),
      ['v']  = M.get_fg_highlight('Statement'),
      ['V']  = M.get_fg_highlight('Statement'),
      [''] = M.get_fg_highlight('Statement'),
      ['s']  = M.get_fg_highlight('Keyword'),
      ['S']  = M.get_fg_highlight('Keyword'),
      ['R']  = M.get_fg_highlight('Title'),
      ['c']  = M.get_fg_highlight('Special'),
    },
    base = {
      bold = true,
    }
  }
}

local function set_highlight(color)
  local base_highlight = api.nvim_get_hl_by_name('CursorLineNr', true)
  local opts = vim.tbl_extend('keep', { foreground = color }, base_highlight)
  api.nvim_set_hl(0, 'CursorLineNr', opts)
end

local function set_cursorline_nur_hl()
  local mode = api.nvim_get_mode().mode
  local color = options.highlight.modes[mode] or options.highlight.modes.n
  set_highlight(color)
end

vim.api.nvim_create_augroup('Modicator', {})
vim.api.nvim_create_autocmd('ModeChanged', {
  callback = set_cursorline_nur_hl,
  group = 'Modicator'
})

function M.setup(opts)
  options = vim.tbl_deep_extend('force', options, opts or {})
end

return M
