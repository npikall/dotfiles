-- Debug Adapter Protocol, focused on Python
-- https://github.com/mfussenegger/nvim-dap

vim.pack.add {
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/mfussenegger/nvim-dap-python',
}

local dap, dapui = require 'dap', require 'dapui'

require('dap-python').setup 'python3'
---@diagnostic disable-next-line: missing-fields
dapui.setup()

dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

vim.keymap.set('n', '<leader>dt', dap.toggle_breakpoint, { desc = 'Debug: [T]oggle breakpoint' })
vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'Debug: [C]ontinue' })
vim.keymap.set('n', '<leader>dq', dap.terminate, { desc = 'Debug: [Q]uit / terminate' })
vim.keymap.set('n', '<leader>di', dap.step_into, { desc = 'Debug: Step [I]nto' })
vim.keymap.set('n', '<leader>do', dap.step_over, { desc = 'Debug: Step [O]ver' })
vim.keymap.set('n', '<leader>dO', dap.step_out, { desc = 'Debug: Step [O]ut' })
vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Debug: Toggle [U]I' })
