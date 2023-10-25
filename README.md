# Modicator.nvim 💡

_Cursor line number **mod**e ind**icator**._

A small Neovim plugin that changes the color of your cursor's line number based on the current Vim mode.

Modicator has [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) support [out of the box](#lualine-integration).

![Modicator in use](https://user-images.githubusercontent.com/15816726/215295831-299dc732-85ae-4668-9e7b-e88cd499f18a.gif)

## Setup

```lua
require('modicator').setup()
```

Note that modicator requires you to have `termguicolors`, `cursorline`, `number` set. In Lua this is done by adding the following somewhere in your Neovim configuration:

```lua
vim.o.termguicolors = true
vim.o.cursorline = true
vim.o.number = true
```

Modicator sets the Normal mode highlight foreground based on the default foreground color of `CursorLineNr` so if you're using a colorscheme make sure that it gets loaded before this plugin.

With [lazy.nvim](https://github.com/folke/lazy.nvim/):

```lua
{
  'mawkler/modicator.nvim',
  dependencies = 'mawkler/onedark.nvim', -- Add your colorscheme plugin here
  init = function()
    -- These are required for Modicator to work
    vim.o.cursorline = true
    vim.o.number = true
    vim.o.termguicolors = true
  end,
  opts = {}
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

Modicator uses the following highlight groups for each mode, respectively:

```txt
NormalMode
InsertMode
VisualMode
CommandMode
ReplaceMode
SelectMode
TerminalMode
TerminalNormalMode
```

For more information on how to create a highlight group, see `:help nvim_set_hl`.

### Default configuration:

```lua
require('modicator').setup({
  -- Show warning if any required option is missing
  show_warnings = true,
  highlights = {
    -- Default options for bold/italic
    defaults = {
      bold = false,
      italic = false,
    },
  },
  integration = {
    lualine = {
      enabled = true,
    },
  },
})
```

## Lualine integration

Modicator has built-in support [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim), meaning that if it detects lualine.nvim in your setup it will use the same colors for each mode as lualine.nvim uses. To disable this feature, you can set `integration.lualine.enabled = false` in your [modicator configuration](#default-configuration).

Note that Modicator will only create a highlight group from a lualine.nvim mode highlight if that highlight group doesn't already exist.

## Issues with other plugins

### marks.nvim

By default, [marks.nvim](https://github.com/chentoast/marks.nvim) highlights number lines with marks using `CursorLineNr`, which makes all line numbers recolored by Modicator every time mode is changed.

To fix this issue, either set `MarkSignNumHL` to something else, or remove the highlight group completely by putting the following snippet anywhere in your configuration:

```lua
local marks_fix_group = vim.api.nvim_create_augroup("marks-fix-hl", {})
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  group = marks_fix_group,
  callback = function()
    vim.api.nvim_set_hl(0, "MarkSignNumHL", {})
  end,
})
```
