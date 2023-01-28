local api = vim.api

local M = {}

--- Gets the foreground color value of `group`.
--- @param group string
--- @return string
M.get_highlight_fg = function(group)
  return api.nvim_get_hl_by_name(group, true).foreground
end

--- Gets the background color value of `group`.
--- @param group string
--- @return string
M.get_highlight_bg = function(group)
  return api.nvim_get_hl_by_name(group, true).background
end

local options = {
  show_warnings = true, -- Show warning if any required option is missing
  highlights = {
    defaults = {
      foreground = M.get_highlight_fg('CursorLineNr'),
      background = M.get_highlight_bg('CursorLineNr'),
      bold = false,
      italic = false
    },
    modes = {
      ['n'] = {
        foreground = M.get_highlight_fg('CursorLineNr'),
      },
      ['i']  = {
        foreground = M.get_highlight_fg('Question'),
      },
      ['v']  = {
        foreground = M.get_highlight_fg('Type'),
      },
      ['V']  = {
        foreground = M.get_highlight_fg('Type'),
      },
      [''] = {
        foreground = M.get_highlight_fg('Type'),
      },
      ['s']  = {
        foreground = M.get_highlight_fg('Keyword'),
      },
      ['S']  = {
        foreground = M.get_highlight_fg('Keyword'),
      },
      ['R']  = {
        foreground = M.get_highlight_fg('Title'),
      },
      ['c']  = {
        foreground = M.get_highlight_fg('Constant'),
      },
    },
  },
}

--- Set the foreground and background color of 'CursorLineNr'. Accepts any
--- highlight definition map that `:help nvim_set_hl()` does.
--- @param highlight table
M.set_highlight = function(highlight)
  local hl = vim.tbl_extend('force', options.highlights.defaults, highlight)
  api.nvim_set_hl(0, 'CursorLineNr', hl)
end

local function create_autocmd()
  api.nvim_create_augroup('Modicator', {})
  api.nvim_create_autocmd('ModeChanged', {
    callback = function()
      local mode = api.nvim_get_mode().mode
      local format = options.highlights.modes[mode] or options.highlights.modes.n
      M.set_highlight(format)
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

local function check_depricated_config(opts)
  local modes = { 'i', 'v', 'V', '', 's', 'S', 'R', 'c' }

  local depricated_opts = vim.tbl_filter(function(mode)
    return type(opts.highlights.modes[mode]) ~= 'table'
  end, modes)

  if #depricated_opts > 0 then
    local message = 'modicator.nvim: configuration API of `highlights.modes` '
      .. 'has changed. Check `:help modicator-configuration` to see the new '
      .. 'configuraition API.'
    vim.notify(message, vim.log.levels.WARN)
  end
end

function M.setup(opts)
  options = vim.tbl_deep_extend('force', options, opts or {})

  if options.show_warnings then
    for _, opt in pairs({ 'cursorline', 'number', 'termguicolors' }) do
      check_option(opt)
    end
    check_depricated_config(options)
  end

  create_autocmd()
end

return M
