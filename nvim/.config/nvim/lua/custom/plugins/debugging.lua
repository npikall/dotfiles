return {
    {
        "nvim-neotest/nvim-nio",
    },
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "mfussenegger/nvim-dap-python",
        },
        config = function()
            local dap, dapui = require("dap"), require("dapui")

            require("dap-python").setup("python3")
            require("dapui").setup()

            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated.dapui_config = function()
                dapui.close()
            end
            dap.listeners.before.event_exited.dapui_config = function()
                dapui.close()
            end
            vim.keymap.set("n", "<Leader>dt", dap.toggle_breakpoint, {})
            vim.keymap.set("n", "<Leader>dc", dap.continue, {})
            vim.keymap.set("n", "<Leader>dq", dap.terminate, {})
            vim.keymap.set("n", "<Leader>di", dap.step_into, {})
            vim.keymap.set("n", "<Leader>do", dap.step_over, {})
            vim.keymap.set("n", "<Leader>dO", dap.step_out, {})

            vim.keymap.set("n", "<Leader>du", dapui.toggle, {})
        end,
    },
}
