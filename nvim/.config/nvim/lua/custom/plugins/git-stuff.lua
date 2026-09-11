-- Git porcelain for Neovim
-- https://github.com/tpope/vim-fugitive
--
-- NOTE: gitsigns itself is set up in `init.lua`, and its recommended keymaps
-- come from `kickstart.plugins.gitsigns`, so only the shorthands live here.

vim.pack.add { 'https://github.com/tpope/vim-fugitive' }

vim.keymap.set('n', '<leader>gp', function() require('gitsigns').preview_hunk() end, { desc = 'Git [p]review hunk' })
vim.keymap.set('n', '<leader>gt', function() require('gitsigns').toggle_current_line_blame() end, { desc = 'Git [t]oggle line blame' })
