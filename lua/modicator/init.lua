local api = vim.api

local M = {}

--- Gets the foreground color value of `group`.
--- @param group string
--- @return string
M.get_highlight_fg = function(group)
  return api.nvim_get_hl_by_name(group, true).foreground
end

local options = {
  show_warnings = true, -- Show warning if any required option is missing
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
  formats = {
    modes = {
      ['n']  = { bold = false, italic = false },
      ['i']  = { bold = false, italic = false },
      ['v']  = { bold = false, italic = false },
      ['V']  = { bold = false, italic = false },
      [''] = { bold = false, italic = false },
      ['s']  = { bold = false, italic = false },
      ['S']  = { bold = false, italic = false },
      ['R']  = { bold = false, italic = false },
      ['c']  = { bold = false, italic = false },
    },
  },
}

--- Sets the foreground color value of the `CursorLineNr` highlight groups to
--- `color`.
--- @param color string
M.set_highlight_and_format = function(color, format)
  local base_highlight = api.nvim_get_hl_by_name('CursorLineNr', true)
  -- Should this be defined with these defaults?
  local base_format = { bold = false, italic = false }
  local opts = vim.tbl_extend('keep',
    { foreground = color, bold = format['bold'], italic = format['italic'] },
  base_highlight, base_format)
  api.nvim_set_hl(0, 'CursorLineNr', opts)
end

local function create_autocmd()
  api.nvim_create_augroup('Modicator', {})
  api.nvim_create_autocmd('ModeChanged', {
    callback = function()
      local mode = api.nvim_get_mode().mode
      local color = options.highlights.modes[mode] or options.highlights.modes.n
      local format = options.formats.modes[mode] or options.formats.modes.n
      M.set_highlight_and_format(color, format)
    end,
    group = 'Modicator'
  })
end

local function check_option(option)
  if not vim.o[option] then
    local message = string.format(
      'modicator.nvim requires `%s` to be set. Run `:set %s` or add `vim.o.%s '
        .. '= true` to your init.lua',
      option,
      option,
      option
    )
    vim.notify(message, vim.log.levels.WARN)
  end
end

function M.setup(opts)
  options = vim.tbl_deep_extend('force', options, opts or {})

  if options.show_warnings then
    for _, opt in pairs({ 'cursorline', 'number', 'termguicolors' }) do
      check_option(opt)
    end
  end

  create_autocmd()
end

return M
