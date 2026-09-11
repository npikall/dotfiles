-- Quarto support (code cells, LSP in embedded languages)
-- https://github.com/quarto-dev/quarto-nvim

vim.pack.add {
  'https://github.com/jmbuhr/otter.nvim',
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  'https://github.com/quarto-dev/quarto-nvim',
}

require('quarto').setup {}
