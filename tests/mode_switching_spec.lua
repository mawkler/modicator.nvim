local modicator = require('modicator')
local utils = require('modicator.utils')

local highlight_exists = utils.highlight_exists
local get_highlights = utils.get_highlights
local hl_name_from_mode = modicator.hl_name_from_mode

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

--- @return table
local function get_current_hl()
  return modicator.get_highlight('CursorLineNr')
end

local default_mode_fg_hls = {
  CommandMode        = 16752800,
  InsertMode         = 32768,
  NormalMode         = 16776960,
  ReplaceMode        = 16711935,
  SelectMode         = 16777056,
  TerminalMode       = 32768,
  TerminalNormalMode = 16776960,
  VisualMode         = 6356832,
}

--- @param expected_mode string
--- @param key_press string
local function test_mode_switching(expected_mode, key_press)
  local from_mode = 'n'

  feedkeys('<Esc>')
  sleep()

  assert.are.equal(from_mode, vim.fn.mode())

  local current_normal_hl_fg = get_current_hl().fg
  local expected_normal_hl_fg = default_mode_fg_hls[hl_name_from_mode(from_mode)]
  assert.are.equal(current_normal_hl_fg, expected_normal_hl_fg)

  feedkeys(key_press)
  sleep()

  local current_visual_hl_fg = get_current_hl().fg
  local expected_visual_hl_fg = default_mode_fg_hls[hl_name_from_mode(expected_mode)]
  assert.are.equal(current_visual_hl_fg, expected_visual_hl_fg)
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

    assert.are.same(default_mode_fg_hls, mode_hl_fgs)
  end)
end)

describe('mode switching', function()
  it('switches to insert mode', function()
    test_mode_switching('i', 'i')
  end)

  it('switches to visual mode', function()
    test_mode_switching('v', 'v')
  end)

  it('switches to command-line mode', function()
    test_mode_switching('c', ':')
  end)

  it('switches to select mode', function()
    test_mode_switching('s', 'gh')
  end)

  it('switches to replace mode', function()
    test_mode_switching('R', 'R')
  end)

  it('switches to terminal mode', function()
    test_mode_switching('tn', ':terminal<CR>')
  end)

  it('switches to terminal mode', function()
    test_mode_switching('t', ':terminal<CR>i')
  end)
end)
