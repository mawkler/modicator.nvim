local modicator = require('modicator')
local utils = require('modicator.utils')

local highlight_exists = utils.highlight_exists
local get_highlights = utils.get_highlights

local function setup_modicator()
  vim.o.termguicolors = true
  vim.o.cursorline = true
  vim.o.number = true
  require('modicator').setup()
end

--- @param keys string
--- @param mode string?
local function feedkeys(keys, mode)
  if mode == nil then mode = 'n' end

  return vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(keys, true, true, true),
    mode,
    true
  )
end

--- @param ms number? Milliseconds
local function sleep(ms)
  local co = coroutine.running()
  vim.defer_fn(function() coroutine.resume(co) end, ms or 10)

  coroutine.yield()
end

describe('creates highlights', function()
  it('has no modicator highlights before setup', function()
    for _, highlight in pairs(get_highlights()) do
      assert.is_not_true(highlight_exists(highlight))
    end
  end)

  it('creates highlights on setup', function()
    setup_modicator()

    for _, highlight in pairs(get_highlights()) do
      assert.is_true(highlight_exists(highlight))
    end
  end)

  it('sets mode highlights for default colorscheme', function()
    local mode_hl_fgs = {}
    for _, hl_name in pairs(utils.get_highlights()) do
      mode_hl_fgs[hl_name] = modicator.get_highlight(hl_name).fg
    end

    local expected_fg_hls = {
      CommandMode        = 16752800,
      InsertMode         = 32768,
      NormalMode         = 16776960,
      ReplaceMode        = 16711935,
      SelectMode         = 16777056,
      TerminalMode       = 32768,
      TerminalNormalMode = 16776960,
      VisualMode         = 6356832,
    }

    assert.are.same(expected_fg_hls, mode_hl_fgs)
  end)
end)
