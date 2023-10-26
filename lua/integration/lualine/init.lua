local lualine = require('lualine')

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

--- @return table?
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

local function get_highlight_bg(hl_grup)
  return vim.api.nvim_get_hl(0, { name = hl_grup, link = false }).bg
end

local function highlight_exists(hl_group)
  local hl = vim.api.nvim_get_hl(0, { name = hl_group })
  return not vim.tbl_isempty(hl)
end

local function uppercase_first_letter(str)
  return str:gsub('^%l', string.upper)
end

--- Set mode highlights based on lualine's mode highlights
M.use_lualine_mode_highlights = function()
  local mode_section = get_mode_section_name()
  -- If lualine doesn't have a `mode` section
  if mode_section == nil then return end

  for _, mode in pairs(lualine_modes) do
    local lualine_hl_group = mode_section .. '_' .. mode
    local lualine_mode_bg = get_highlight_bg(lualine_hl_group)
    local mode_hl_group = uppercase_first_letter(mode) .. 'Mode'

    if not highlight_exists(mode_hl_group) then
      vim.api.nvim_set_hl(0, mode_hl_group, { fg = lualine_mode_bg })
    end
  end
end

return M
