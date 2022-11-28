# 💡 Modicator.nvim

_Cursor line number mode indicator._

A small Neovim plugin that changes the foreground color of the `CursorLineNr` highlight based on the current Vim mode.

![modicator](https://user-images.githubusercontent.com/15816726/194103616-5fb6d1d3-5049-43cd-83da-20ed0c207d42.gif)

## Setup

```lua
require('modicator').setup()
```

Note that modicator requires you to have `termguicolors` set. In Lua this is done by adding `vim.o.termguicolors = true` somewhere in your configuration.

Modicator sets the Normal mode highlight foreground based on the default foreground color of `CursorLineNr` so if you're using a colorscheme make sure that it gets loaded before this plugin.

With [packer.nvim](https://github.com/wbthomason/packer.nvim/) this is done like this:

```lua
use { 'melkster/modicator.nvim',
  after = 'onedark.nvim', -- Add your colorscheme plugin here
  setup = function()
    -- There are required for Modicator to work
    vim.o.cursorline = true
    vim.o.number = true
    vim.o.termguicolors = true
  end,
  config = function()
    require('modicator').setup({
      -- ...
    })
  end
}
```

## Configuration

Use `highlights.modes` to set the color for each mode, and pass it to `.setup()`. The key for each color is the output `mode()` for that mode. Check out `:help mode()` for more information.

For normal mode, Modicator uses the `CursorLineNr`'s `fg` highlight. The other highligt keys of `CursorLineNr` (`bg`, `gui`, `bold`, etc.) are preserved when you switch to other modes. Modicator only modifies `CursorLineNr`'s `fg` color.

**Default configuration:**

```lua
local modicator = require('modicator')

modicator.setup({
  -- NOTE: Modicator requires line_numbers and cursorline to be enabled
  highlights = {
    modes = {
      ['i'] = modicator.get_highlight_fg('Question'),
      ['v'] = modicator.get_highlight_fg('Type'),
      ['V'] = modicator.get_highlight_fg('Type'),
      [''] = modicator.get_highlight_fg('Type'),
      ['s'] = modicator.get_highlight_fg('Keyword'),
      ['S'] = modicator.get_highlight_fg('Keyword'),
      ['R'] = modicator.get_highlight_fg('Title'),
      ['c'] = modicator.get_highlight_fg('Constant'),
    },
  },
})
```
