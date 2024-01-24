local utils = require('modicator.utils')

vim.cmd.colorscheme('catppuccin')

describe('creates highlights with colorscheme', function()
  it('creates highlights on setup', function()
    require('modicator').setup()

    for _, highlight in pairs(utils.get_highlights()) do
      assert.is_true(utils.highlight_exists(highlight))
    end
  end)

  it('sets mode highlights for colorscheme', function()
    local catppuccin_mode_fg_hls = {
      CommandMode = 15912397,
      InsertMode = 9024762,
      NormalMode = 11845374,
      ReplaceMode = 16376495,
      SelectMode = 15961000,
      TerminalMode = 9034987,
      TerminalNormalMode = 11845374,
      VisualMode = 10937249,
    }

    local mode_hl_fgs = {}
    for _, hl_name in pairs(utils.get_highlights()) do
      mode_hl_fgs[hl_name] = utils.get_highlight(hl_name).fg
    end

    assert.are.same(catppuccin_mode_fg_hls, mode_hl_fgs)
  end)
end)
