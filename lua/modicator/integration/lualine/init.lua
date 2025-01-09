local lualine = require('lualine')
local modicator = require('modicator')

local M = {}

--- @alias LualineSectionLetter 'a' | 'b' | 'c' | 'x' | 'y' | 'z'

--- @return table<string>
local function get_mode_names()
  return vim.tbl_map(function(mode)
    return vim.fn.tolower(mode)
  end, modicator.modes)
end

--- @param section table
--- @return table?
local function get_mode_table(section)
  local mode_sections = vim.tbl_filter(function(component)
    return type(component) ~= 'function' and component[1] == 'mode'
  end, section)
  -- If there are multiple 'mode' sections, use the first one
  return mode_sections[1]
end

--- @return string?
local function get_mode_section_name()
  local sections = lualine.get_config().sections
  for section, components in pairs(sections) do
    -- Look for 'mode' component as a string
    if vim.tbl_contains(components, 'mode') then
      return section
    end

    -- Look for 'mode' component as a table
    if get_mode_table(components) ~= nil then
      return section
    end
  end
end

--- @param mode_section string?
--- @return LualineSectionLetter?
local function letter_from_mode_section(mode_section)
  if not mode_section then return end

  local section_name_length = #'lualine_' + 1
  return string.sub(mode_section, section_name_length, section_name_length)
end

--- @return LualineSectionLetter?
local function get_mode_section_letter()
  local mode_section_name = get_mode_section_name()
  return letter_from_mode_section(mode_section_name)
end

local function uppercase_first_letter(str)
  return str:gsub('^%l', string.upper)
end

--- @return table?
local function get_lualine_theme()
  local loader = require('lualine.utils.loader')
  local lualine_theme = require('lualine').get_config().options.theme
  if (type(lualine_theme) == 'table') then
    return lualine_theme
  else
    local ok, theme = pcall(loader.load_theme, lualine_theme)
    if ok and theme then
      return theme
    end
  end
end

--- @param mode string
--- @param mode_section LualineSectionLetter
--- @return table?
local function get_lualine_mode_hl(mode, mode_section)
  local theme = get_lualine_theme()
  return theme and theme[mode] and theme[mode][mode_section]
end

--- @param mode string
--- @param mode_section_letter LualineSectionLetter
local function set_highlight_from_lualine(mode, mode_section_letter)
  local mode_hl_group = uppercase_first_letter(mode) .. 'Mode'
  local hl = get_lualine_mode_hl(mode, mode_section_letter)

  if not hl then
    -- Fallback if lualine highlight for `mode` doesn't exist
    hl = get_lualine_mode_hl('normal', mode_section_letter)
  end

  local highlight_exists = require('modicator.utils').highlight_exists
  if hl and not highlight_exists(mode_hl_group) then
    local options = modicator.get_options()
    local highlight_level = options.integration.lualine.highlight
    vim.api.nvim_set_hl(0, mode_hl_group, { fg = hl[highlight_level] })
  end
end

--- Set mode highlights based on lualine's mode highlights
--- @param mode_section LualineSectionLetter?
function M.use_lualine_mode_highlights(mode_section)
  mode_section = mode_section or get_mode_section_letter()
  -- If lualine doesn't have a `mode` section and none was passed in
  if mode_section == nil then
    local message = "'integration.lualine.enabled' is true, but no lualine "
        .. "mode section was found. Please set it manually in "
        .. "'integration.lualine.mode_section'"
    require('modicator.notifications').warn(message)
    return
  end

  for _, mode in pairs(get_mode_names()) do
    set_highlight_from_lualine(mode, mode_section)
  end
end

return M
