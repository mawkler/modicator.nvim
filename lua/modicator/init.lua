local api = vim.api

local M = {}

local options = {
  show_warnings = true, -- Show warning if any required option is missing
  highlights = {
    defaults = {
      bold = false,
      italic = false,
    },
  },
}

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

--- Gets the background color value of `group`.
--- @param group string
--- @return table<string, any>
M.get_highlight = function(group)
  return api.nvim_get_hl(0, { name = group })
end

local function fallback_hl_from_mode(mode)
  local hls = {
    ['Normal']  = 'CursorLineNr',
    ['Insert']  = 'Question',
    ['Visual']  = 'Type',
    ['Select']  = 'Keyword',
    ['Replace'] = 'Title',
    ['Command'] = 'Constant',
  }
  return hls[mode] or hls.normal
end

-- Link any missing mode highlight to its fallback highlight
local function set_fallback_highlight_groups()
  local modes = { 'Normal', 'Insert', 'Visual', 'Command', 'Replace', 'Select' }

  for _, mode in pairs(modes) do
    local hl_name = mode .. 'Mode'
    if vim.tbl_isempty(M.get_highlight(hl_name)) then
      local fallback_hl = fallback_hl_from_mode(mode)
      api.nvim_set_hl(0, hl_name, { link = fallback_hl })
    end
  end
end

local function mode_name_from_mode(mode)
  local mode_names = {
    ['n']  = 'Normal',
    ['i']  = 'Insert',
    ['v']  = 'Visual',
    ['V']  = 'Visual',
    [''] = 'Visual',
    ['s']  = 'Select',
    ['S']  = 'Select',
    ['R']  = 'Replace',
    ['c']  = 'Command',
  }
  return mode_names[mode] or 'normal'
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
      local mode_name = mode_name_from_mode(mode)

      M.set_cursor_line_highlight(mode_name .. 'Mode')
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
  if opts.highlights and opts.highlights.modes then
    local message = 'modicator.nvim: configuration of highlights has changed '
      .. 'to highlight groups rather than using `highlights.modes`. Check '
      .. '`:help modicator-configuration` to see the new configuration API.'
    vim.notify(message, vim.log.levels.WARN)
  end
end

function M.setup(opts)
  options = vim.tbl_deep_extend('force', options, opts or {})

  if options.show_warnings then
    for _, opt in pairs({ 'cursorline', 'number', 'termguicolors' }) do
      check_option(opt)
    end
    check_deprecated_config(options)
  end

  set_fallback_highlight_groups()

  create_autocmd()
end

return M
