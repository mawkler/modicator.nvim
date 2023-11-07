local modicator = require('modicator')
local utils = require('modicator.utils')

local highlight_exists = utils.highlight_exists
local get_highlights = utils.get_highlights

--- @param keys string
--- @param mode string
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
  it("has no modicator highlights before setup", function()
    for _, highlight in pairs(get_highlights()) do
      assert.is_not_true(highlight_exists(highlight))
    end
  end)

  it('creates highlights on setup', function()
    require('modicator').setup()

    for _, highlight in pairs(get_highlights()) do
      assert.is_true(highlight_exists(highlight))
    end
  end)
end)
