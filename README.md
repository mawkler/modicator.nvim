# Modicator.nvim 💡

_Cursor line number mode indicator._

A small Neovim plugin that changes the foreground color of the `CursorLineNr` highlight based on the current Vim mode.

![modicator](https://user-images.githubusercontent.com/15816726/215295831-299dc732-85ae-4668-9e7b-e88cd499f18a.gif)

## Setup

```lua
require('modicator').setup()
```

Note that modicator requires you to have `termguicolors`, `cursorline`, `number` set. In Lua this is done by adding

```lua
vim.o.termguicolors = true
vim.o.cursorline = true
vim.o.number = true
```

somewhere in your Neovim configuration.

Modicator sets the Normal mode highlight foreground based on the default foreground color of `CursorLineNr` so if you're using a colorscheme make sure that it gets loaded before this plugin.

With [lazy.nvim](https://github.com/folke/lazy.nvim/):

```lua
return {
  'mawkler/modicator.nvim',
  dependencies = 'mawkler/onedark.nvim', -- Add your colorscheme plugin here
  init = function()
    -- These are required for Modicator to work
    vim.o.cursorline = true
    vim.o.number = true
    vim.o.termguicolors = true
  end,
  config = function()
    require('modicator').setup()
  end,
}
```

Or with [packer.nvim](https://github.com/wbthomason/packer.nvim/):

```lua
use {
  'mawkler/modicator.nvim',
  after = 'onedark.nvim', -- Add your colorscheme plugin here
  setup = function()
    -- These are required for Modicator to work
    vim.o.cursorline = true
    vim.o.number = true
    vim.o.termguicolors = true
  end,
  config = function()
    require('modicator').setup()
  end
}
```

## Configuration

Modicator uses the the following highlight groups for each mode, respectively:

```txt
NormalMode
InsertMode
VisualMode
CommandMode
ReplaceMode
SelectMode
TerminalMode,
TerminalNormalMode,
```

For more information on how to create a highlight group, see `:help nvim_set_hl`.

**Default configuration:**

```lua
require('modicator').setup({
  -- Show warning if any required option is missing
  show_warnings = true,
  highlights = {
    -- Default options for bold/italic
    defaults = {
      bold = false,
      italic = false
    },
  },
})
```
