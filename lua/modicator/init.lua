local api = vim.api

local M = {}

--- Gets the foreground color value of `group`.
--- @param group string
--- @return string
M.get_highlight_fg = function(group)
  return api.nvim_get_hl(0, { name = group }).fg
end

--- Gets the background color value of `group`.
--- @param group string
--- @return string
M.get_highlight_bg = function(group)
  return api.nvim_get_hl(0, { name = group }).bg
end

local default_options = {
  show_warnings = true, -- Show warning if any required option is missing
  highlights = {
    defaults = {
      foreground = M.get_highlight_fg('CursorLineNr'),
      background = M.get_highlight_bg('CursorLineNr'),
      bold = false,
      italic = false
    },
    modes = {
      ['n']  = 'CursorLineNr',
      ['i']  = 'Question',
      ['v']  = 'Type',
      ['V']  = 'Type',
      [''] = 'Type',
      ['s']  = 'Keyword',
      ['S']  = 'Keyword',
      ['R']  = 'Title',
      ['c']  = 'Constant',
    },
  },
}

-- Gets populated by `M.setup()`
local options = {}

local function mode_name_from_mode(mode)
  local mode_names = {
    ['n']  = 'normal',
    ['i']  = 'insert',
    ['v']  = 'visual',
    ['V']  = 'visual',
    [''] = 'visual',
    ['s']  = 'select',
    ['S']  = 'select',
    ['R']  = 'replace',
    ['c']  = 'command',
  }
  local mode_name = mode_names[mode]

  return mode_name or 'normal'
end

--- @param mode string
local function hl_name_from_mode(mode)
  local mode_name = mode_name_from_mode(mode)
  local hl_name = mode_name .. 'mode'
  local hl = api.nvim_get_hl(0, { name = hl_name})
  local hl_exists = not vim.tbl_isempty(hl)

  if not hl_exists and options.show_warnings then
    local message = string.format(
      [[
        modicator.nvim: highlight group '%s' missing. Using fallback highlight
        group.\n\nTo disable this, set show_warnings = true in
        modicator.nvim's setup
      ]],
      hl_name
    )
    vim.notify_once(message, vim.log.levels.INFO)

    return default_options.highlights.modes[mode]
  end

  return hl_name
end

--- Set the foreground and background color of 'CursorLineNr'. Accepts any
--- highlight definition map that `vim.api.nvim_set_hl()` does.
--- @param hl_group_name string
M.set_cursor_line_highlight = function(hl_group_name)
  local hl_group = api.nvim_get_hl(0, { name = hl_group_name })
  local hl = vim.tbl_extend('force', options.highlights.defaults, hl_group)
  api.nvim_set_hl(0, 'CursorLineNr', hl)
end


local function create_autocmd()
  api.nvim_create_augroup('Modicator', {})
  api.nvim_create_autocmd('ModeChanged', {
    callback = function()
      local mode = api.nvim_get_mode().mode
      local hl_group = hl_name_from_mode(mode)

      M.set_cursor_line_highlight(hl_group)
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

local function check_deprecated_config(opts)
  local modes = { 'i', 'v', 'V', '', 's', 'S', 'R', 'c' }

  local deprecated_opts = vim.tbl_filter(function(mode)
    return type(opts.highlights.modes[mode]) ~= 'table'
  end, modes)

  if #deprecated_opts > 0 then
    local message = 'modicator.nvim: configuration API of `highlights.modes` '
      .. 'has changed. Check `:help modicator-configuration` to see the new '
      .. 'configuration API.'
    vim.notify(message, vim.log.levels.WARN)
  end
end

function M.setup(opts)
  options = vim.deepcopy(vim.tbl_deep_extend('force', default_options, opts or {}))

  if options.show_warnings then
    for _, opt in pairs({ 'cursorline', 'number', 'termguicolors' }) do
      check_option(opt)
    end
    check_deprecated_config(options)
  end

  create_autocmd()
end

return M
