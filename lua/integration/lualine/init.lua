local lualine = require('lualine')
local modicator = require('modicator')

local M = {}

local lualine_modes = {
  'normal',
  'visual',
  'replace',
  'insert',
  'command',
  'terminal',
}

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

--- Set mode highlights based on lualine's mode highlights
--- @param mode_section string?
M.use_lualine_mode_highlights = function(mode_section)
  mode_section = mode_section or get_mode_section_name()
  -- If lualine doesn't have a `mode` section and none was passed in
  if mode_section == nil then return end

  for _, mode in pairs(lualine_modes) do
    local mode_hl_group = uppercase_first_letter(mode) .. 'Mode'

    local lualine_hl_group = mode_section .. '_' .. mode
    local lualine_mode_hl = modicator.get_highlight(lualine_hl_group)

    local hl_level = modicator.get_options().integration.lualine.highlight
    local hl = lualine_mode_hl[hl_level]

    if not highlight_exists(mode_hl_group) then
      vim.api.nvim_set_hl(0, mode_hl_group, { fg = hl })
    end
  end
end

return M
