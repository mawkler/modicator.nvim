# 💡 Modicator.nvim

_Cursor line number mode indicator._

A small Neovim plugin that changes the foreground color of the `CursorLineNr` highlight based on the current Vim mode.

## Setup

```lua
require('modicator').setup()
```

Modicator sets the Normal mode highlight foreground based on the default foreground color of `CursorLineNr`, so if you're using a colorscheme make sure that it gets loaded before this plugin.

With [packer.nvim](https://github.com/wbthomason/packer.nvim/) this is done like this:

```lua
use { 'melkster/modicator.nvim',
  after = 'onedark.nvim', -- Add your colorscheme plugin here
  config = function()
    require('modicator').setup({
      -- ...
    })
  end
}
```

## Configuration

Use `highlights.modes` to set the color for each mode, and pass it to `.setup()`. The key for each color is the output `mode()` for that mode. Check out `:help mode()` for more information.

**Default configuration:**

```lua
local modicator = require('modicator')

modicator.setup({
  highlights = {
    modes = {
      ['n'] = modicator.get_highlight_fg('CursorLineNr'),
      ['i'] = modicator.get_highlight_fg('Question'),
      ['v'] = modicator.get_highlight_fg('Statement'),
      ['V'] = modicator.get_highlight_fg('Statement'),
      [''] = modicator.get_highlight_fg('Statement'),
      ['s'] = modicator.get_highlight_fg('Keyword'),
      ['S'] = modicator.get_highlight_fg('Keyword'),
      ['R'] = modicator.get_highlight_fg('Title'),
      ['c'] = modicator.get_highlight_fg('Special'),
    },
  },
})
```
