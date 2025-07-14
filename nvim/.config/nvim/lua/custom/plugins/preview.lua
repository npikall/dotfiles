return {
  {
    'chomosuke/typst-preview.nvim',
    lazy = false, -- or
    ft = 'typst',
    version = '1.*',
    opts = {}, -- lazy.nvim will implicitly calls `setup {}`
    config = function()
      require('typst-preview').setup {
        port = 5000,
      }
      vim.keymap.set('n', '<leader>p', ':TypstPreviewToggle<CR>')
    end,
  },
  -- {
  --   "iamcco/markdown-preview.nvim",
  --   cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  --   build = "cd app && npm install",
  --   init = function()
  --     vim.g.mkdp_filetypes = { "markdown" }
  --     vim.keymap.set("n","<leader>mp", ":MarkdownPreviewToggle<CR>")
  --   end,
  --   ft = { "markdown" },
  -- },
}
