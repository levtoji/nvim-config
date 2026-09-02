return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      -- delve (Go), netcoredbg (.NET-Debugger) und roslyn (C#-LSP-Server)
      -- gibt's nicht über brew core, daher lässt mason sie beim ersten Start installieren
      require("mason-tool-installer").setup({
        ensure_installed = { "delve", "netcoredbg", "roslyn-language-server" },
      })

      local dap = require("dap")
      local dapui = require("dapui")
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Go
      require("dap-go").setup({
        delve = { path = mason_bin .. "/dlv" },
      })

      -- .NET
      dap.adapters.coreclr = {
        type = "executable",
        command = mason_bin .. "/netcoredbg",
        args = { "--interpreter=vscode" },
      }
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - netcoredbg",
          request = "launch",
          program = function()
            return vim.fn.input("Pfad zur .dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
        },
      }

      -- Rider-artige Debug-Keymaps
      vim.keymap.set("n", "<F9>", dap.continue, { desc = "Debug: Continue" })
      vim.keymap.set("n", "<F8>", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F7>", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<S-F8>", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<C-F8>", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
      vim.keymap.set("n", "<leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint-Bedingung: "))
      end, { desc = "Debug: Conditional Breakpoint" })
      vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })
      vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })
      vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Debug: Terminate" })
    end,
  },
}
