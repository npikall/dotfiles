-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- Load every other Lua file in this directory, in alphabetical order.
--
-- NOTE: The entries are stat'd rather than matched on the type reported by
-- `vim.fs.dir`: when this config is deployed with a symlink farm (GNU stow),
-- every entry is reported as a `link`, and a link left dangling by a deleted
-- file must be skipped instead of `require`d.
local plugins_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'plugins')

local modules = {}
for file_name in vim.fs.dir(plugins_dir) do
  local module = file_name:match '^(.+)%.lua$'
  if module and module ~= 'init' then
    local stat = vim.uv.fs_stat(vim.fs.joinpath(plugins_dir, file_name))
    if stat and stat.type == 'file' then table.insert(modules, module) end
  end
end
table.sort(modules)

for _, module in ipairs(modules) do
  require('custom.plugins.' .. module)
end
