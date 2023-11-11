local status, error = pcall(function()
  local root = vim.fn.fnamemodify('.repro', ':p')
  for _, name in ipairs { 'config', 'data', 'state', 'cache' } do
    vim.env[('XDG_%s_HOME'):format(name:upper())] = root .. '/' .. name
  end

  local lazy_path = root .. '/plugins/lazy.nvim'
  if not vim.loop.fs_stat(lazy_path) then
    local lay_url = 'https://github.com/folke/lazy.nvim.git'
    vim.fn.system({ 'git', 'clone', '--filter=blob:none', lay_url, lazy_path })
  end
  vim.opt.runtimepath:prepend(lazy_path)

  vim.o.termguicolors = true
  vim.o.cursorline = true
  vim.o.number = true

  local plugins = {
    { 'mawkler/modicator.nvim', opts = {} },
    { 'nvim-lua/plenary.nvim' },
  }

  require('lazy').setup(plugins, { root = root .. '/plugins' })
end)
