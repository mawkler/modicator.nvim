local lualine = require('lualine')
local modicator = require('modicator')

local M = {}

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

local function highlight_exists(hl_group)
  local hl = vim.api.nvim_get_hl(0, { name = hl_group })
  return not vim.tbl_isempty(hl)
end

local function uppercase_first_letter(str)
  return str:gsub('^%l', string.upper)
end

local function letter_from_mode_section(mode_section)
  local section_name_length = #"lualine_" + 1
  return string.sub(mode_section, section_name_length, section_name_length)
end

--- @return table?
local function get_lualine_theme()
  local loader = require('lualine.utils.loader')
  local ok, theme = pcall(loader.load_theme, vim.g.colors_name)
  if ok and theme then
    return theme
  end
end

--- @param mode string
--- @param mode_section 'a' | 'b' | 'c' | 'x' | 'y' | 'z'
--- @return table?
local function get_lualine_mode_hl(mode, mode_section)
  local theme = get_lualine_theme()
  return theme and theme[mode] and theme[mode][mode_section]
end

--- Set mode highlights based on lualine's mode highlights
--- @param mode_section string?
M.use_lualine_mode_highlights = function(mode_section)
  mode_section = mode_section or get_mode_section_name()
  -- If lualine doesn't have a `mode` section and none was passed in
  if mode_section == nil then
    local message = "'integration.lualine.enabled' is true, but no lualine "
        .. "mode section was found. Please set it manually in "
        .. "'integration.lualine.mode_section'"
    require('modicator.utils').warn(message)
    return
  end

  local mode_section_letter = letter_from_mode_section(mode_section)

  for _, mode in pairs(get_mode_names()) do
    local mode_hl_group = uppercase_first_letter(mode) .. 'Mode'
    local hl = get_lualine_mode_hl(mode, mode_section_letter)

    if not hl then
      -- Fallback if lualine highlight for `mode` doesn't exist
      hl = get_lualine_mode_hl('normal', mode_section_letter)
    end

    if hl and not highlight_exists(mode_hl_group) then
      vim.api.nvim_set_hl(0, mode_hl_group, { fg = hl.fg })
    end
  end
end

return M
