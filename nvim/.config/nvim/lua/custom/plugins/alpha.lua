-- Startup dashboard
-- https://github.com/goolord/alpha-nvim

local plugins = { 'https://github.com/goolord/alpha-nvim' }
if vim.g.have_nerd_font then table.insert(plugins, 'https://github.com/nvim-tree/nvim-web-devicons') end
vim.pack.add(plugins)

local alpha = require 'alpha'
local dashboard = require 'alpha.themes.startify'

dashboard.section.header.val = {
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                     ]],
  [[       ████ ██████           █████      ██                     ]],
  [[      ███████████             █████                             ]],
  [[      █████████ ███████████████████ ███   ███████████   ]],
  [[     █████████  ███    █████████████ █████ ██████████████   ]],
  [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
  [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
  [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
  [[                                                                       ]],
  [[                                                                       ]],
  [[                                                                       ]],
}

alpha.setup(dashboard.opts)
