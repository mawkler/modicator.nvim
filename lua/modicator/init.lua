local api = vim.api

local M = {}

--- Gets the foreground color value of `group`.
--- @param group string
--- @return string
M.get_highlight_fg = function(group)
  return api.nvim_get_hl_by_name(group, true).foreground
end

local options = {
  highlights = {
    modes = {
      ['n']  = M.get_highlight_fg('CursorLineNr'),
      ['i']  = M.get_highlight_fg('Question'),
      ['v']  = M.get_highlight_fg('Type'),
      ['V']  = M.get_highlight_fg('Type'),
      [''] = M.get_highlight_fg('Type'),
      ['s']  = M.get_highlight_fg('Keyword'),
      ['S']  = M.get_highlight_fg('Keyword'),
      ['R']  = M.get_highlight_fg('Title'),
      ['c']  = M.get_highlight_fg('Constant'),
    },
  },
}

--- Sets the foreground color value of the `CursorLineNr` highlight groups to
--- `color`.
--- @param color string
M.set_highlight = function(color)
  local base_highlight = api.nvim_get_hl_by_name('CursorLineNr', true)
  local opts = vim.tbl_extend('keep', { foreground = color }, base_highlight)
  api.nvim_set_hl(0, 'CursorLineNr', opts)
end

local function create_autocmd()
  vim.api.nvim_create_augroup('Modicator', {})
  vim.api.nvim_create_autocmd('ModeChanged', {
    callback = function()
      local mode = api.nvim_get_mode().mode
      local color = options.highlights.modes[mode] or options.highlights.modes.n
      M.set_highlight(color)
    end,
    group = 'Modicator'
  })
end

local function check_termguicolors()
  if not vim.o.termguicolors then
    vim.notify(
      'modicator.nvim requires termguicolors to be set. To solve this, run ' ..
      '`:set termguicolors` or add `vim.o.termguicolors = true` to your ' ..
      'init.lua',
      vim.log.levels.WARN
    )
  end
end

function M.setup(opts)
  check_termguicolors()

  options = vim.tbl_deep_extend('force', options, opts or {})

  create_autocmd()
end

return M
