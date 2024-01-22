local api = vim.api

local M = {}

--- @class ModicatorLualineIntegration
--- @field enabled? boolean
--- @field mode_section? LualineSectionLetter If `nil`, gets detected automatically. See `:help lualine-usage-and-customization`
--- @field highlight? 'bg' | 'fg' Whether to use the highlight's foreground or background

--- @class ModicatorOptions
--- @field show_warnings? boolean Show warning on VimEnter if any required option is missing
--- @field highlights? { defaults?: { bold?: boolean, italic?: boolean } }
--- @field integration? { lualine?: ModicatorLualineIntegration }
local options = {
  --- @type boolean
  show_warnings = true,
  highlights = {
    defaults = {
      bold = false,
      italic = false,
    },
  },
  integration = {
    lualine = {
      enabled = true,
      mode_section = nil,
      highlight = 'bg',
    },
  },
}

--- @return ModicatorOptions
M.get_options = function()
  return options
end

local function check_option(option)
  if not vim.o[option] then
    local message = string.format(
      'modicator requires `%s` to be set. Run `:set %s` or add `vim.o.%s '
      .. '= true` to your init.lua',
      option,
      option,
      option
    )
    require('modicator.utils').warn(message)
  end
end

local function check_deprecated_config(opts)
  if opts.highlights and opts.highlights.modes then
    local message = 'configuration of highlights has changed to highlight '
        .. 'groups rather than using `highlights.modes`. Check `:help '
        .. 'modicator-configuration` to see the new configuration API.'
    require('modicator.utils').warn(message)
  end
end

local function show_warnings()
  if options.show_warnings then
    for _, opt in pairs({ 'cursorline', 'number', 'termguicolors' }) do
      check_option(opt)
    end
    check_deprecated_config(options)
  end
end

local function lualine_is_loaded()
  local ok, _ = pcall(require, 'lualine')
  return ok
end

local function mode_name_from_mode(mode)
  local mode_names = {
    ['n']  = 'Normal',
    ['i']  = 'Insert',
    ['v']  = 'Visual',
    ['V']  = 'Visual',
    ['']  = 'Visual',
    ['s']  = 'Select',
    ['S']  = 'Select',
    ['R']  = 'Replace',
    ['c']  = 'Command',
    ['t']  = 'Terminal',
    ['nt'] = 'TerminalNormal',
  }
  return mode_names[mode] or 'Normal'
end

--- @param mode string
M.hl_name_from_mode = function(mode)
  local mode_name = mode_name_from_mode(mode)
  return mode_name .. 'Mode'
end

local function update_mode()
  local mode = api.nvim_get_mode().mode
  local hl_name = M.hl_name_from_mode(mode)
  M.set_cursor_line_highlight(hl_name)
end

local function fallback_hl_from_mode(mode)
  local hls = {
    Normal = 'CursorLineNr',
    Insert = 'Question',
    Visual = 'String',
    Select = 'ErrorMsg',
    Replace = 'WarningMsg',
    Command = 'Identifier',
    Terminal = 'Operator',
    TerminalNormal = 'CursorLineNr',
  }
  return hls[mode] or hls.normal
end

M.modes = {
  'Normal',
  'Insert',
  'Visual',
  'Command',
  'Replace',
  'Select',
  'Terminal',
  'TerminalNormal',
}

-- Link any missing mode highlight to its fallback highlight
local function set_fallback_highlight_groups()
  for _, mode in pairs(M.modes) do
    local utils = require('modicator.utils')
    local hl_name = mode .. 'Mode'

    if vim.tbl_isempty(utils.get_highlight(hl_name)) then
      local fallback_hl = fallback_hl_from_mode(mode)

      if mode == 'Normal' or mode == 'TerminalNormal' then
        -- We can't directly link the `(Terminal)NormalMode` highlight to
        -- `CursorLineNr` since it will mutate, so we copy it instead
        local cursor_line_nr = utils.get_highlight('CursorLineNr')
        api.nvim_set_hl(0, hl_name, cursor_line_nr)
      else
        api.nvim_set_hl(0, hl_name, { link = fallback_hl })
      end
    end
  end
end

local function set_highlight_groups()
  if lualine_is_loaded() and options.integration.lualine.enabled then
    local mode_section = options.integration.lualine.mode_section
    require('modicator.integration.lualine').use_lualine_mode_highlights(mode_section)
  else
    set_fallback_highlight_groups()
  end

  update_mode()
end

--- Set the foreground and background color of 'CursorLineNr'. Accepts any
--- highlight definition map that `vim.api.nvim_set_hl()` does.
--- @param hl_name string
M.set_cursor_line_highlight = function(hl_name)
  local hl_group = require('modicator.utils').get_highlight(hl_name)
  local hl = vim.tbl_extend('force', options.highlights.defaults, hl_group)
  api.nvim_set_hl(0, 'CursorLineNr', hl)

  local is_register_executing = vim.fn.reg_executing() ~= ""

  -- Workaround for https://github.com/neovim/neovim/issues/25851
  if not vim.o.lazyredraw and not is_register_executing then
    vim.cmd.redraw()
  end
end

local function create_autocmds()
  local augroup = api.nvim_create_augroup('Modicator', {})
  -- NOTE: VimEnter loads after user's configuration is loaded
  api.nvim_create_autocmd('VimEnter', {
    callback = function()
      show_warnings()
      update_mode()
    end,
    group = augroup,
  })
  api.nvim_create_autocmd('ModeChanged', {
    callback = update_mode,
    group = augroup,
  })
  api.nvim_create_autocmd('Colorscheme', {
    callback = set_highlight_groups,
    group = augroup,
  })
end

--- @param opts ModicatorOptions?
function M.setup(opts)
  options = vim.tbl_deep_extend('force', options, opts or {})

  set_highlight_groups()

  vim.api.nvim_set_hl(0, 'CursorLineNr', { link = 'NormalMode' })

  create_autocmds()
end

return M
