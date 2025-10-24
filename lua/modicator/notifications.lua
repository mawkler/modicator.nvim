local M = {}

--- @return table
local function get_missing_options(opts)
  return vim.iter(opts):filter(function(opt) return not vim.o[opt] end)
end

local function warn_missing_options(opts)
  for _, opt in pairs(opts) do
    if not vim.o[opt] then
      local message = string.format(
        'Modicator requires `%s` to be set. Run `:set %s` or add `vim.o.%s '
        .. '= true` to your init.lua',
        opt,
        opt,
        opt
      )
      require('modicator.notifications').warn(message)
    end
  end
end

--- @param opts table
local function check_deprecated_config(opts)
  if opts.highlights and opts.highlights.modes then
    local message = 'configuration of highlights has changed to highlight '
        .. 'groups rather than using `highlights.modes`. Check `:help '
        .. 'modicator-configuration` to see the new configuration API.'
    require('modicator.notifications').warn(message)
  end
end

function M.show_warnings()
  local options = require('modicator').get_options()

  if options.show_warnings then
    local missing_options = get_missing_options({
      'cursorline',
      'number',
      'termguicolors',
    }):totable()

    if #missing_options > 0 then
      warn_missing_options(missing_options)

      local message = 'If you\'ve you have already set '
          .. 'those options in your config, this warning is likely '
          .. 'caused by another plugin temporarily modifying those '
          .. 'options for this buffer. If Modicator works as expected in '
          .. 'other buffers you can remove the `show_warnings` option '
          .. 'from your Modicator configuration.'
      require('modicator.notifications').inform(message)
    end

    check_deprecated_config(options)
  end
end

--- @param message string
function M.warn(message)
  if require('modicator').get_options().show_warnings then
    local warning = string.format('modicator.nvim: %s', message)
    vim.notify(warning, vim.log.levels.WARN)
  end
end

--- @param message string
function M.inform(message)
  if require('modicator').get_options().show_warnings then
    local warning = string.format('modicator.nvim: %s', message)
    vim.notify(warning, vim.log.levels.INFO)
  end
end

return M
