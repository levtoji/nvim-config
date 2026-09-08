return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "leoluz/nvim-dap-go",
    },
    -- keys statt vim.keymap.set im config(): so laden dap/dapui/mason erst
    -- beim ersten Debug-Keypress statt bei jedem nvim-Start.
    keys = {
      {
        "<F9>",
        function()
          require("dap").continue()
        end,
        desc = "Debug: Continue",
      },
      {
        "<F8>",
        function()
          require("dap").step_over()
        end,
        desc = "Debug: Step Over",
      },
      {
        "<F7>",
        function()
          require("dap").step_into()
        end,
        desc = "Debug: Step Into",
      },
      {
        "<S-F8>",
        function()
          require("dap").step_out()
        end,
        desc = "Debug: Step Out",
      },
      {
        "<C-F8>",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug: Toggle Breakpoint",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug: Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint-Bedingung: "))
        end,
        desc = "Debug: Conditional Breakpoint",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.open()
        end,
        desc = "Debug: Open REPL",
      },
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Debug: Toggle UI",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "Debug: Terminate",
      },
    },
    config = function()
      -- delve/netcoredbg werden zentral von mason-tool-installer installiert,
      -- siehe lsp.lua (mason.nvim config) - dort landen alle Mason-Tools gesammelt.
      local dap = require("dap")
      local dapui = require("dapui")
      local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

      -- Ohne das hier schickt nvim-dap beim Sessionstart kein
      -- setExceptionBreakpoints an den Adapter, d.h. geworfene Exceptions
      -- werden erst beim Programmende/Crash bemerkt statt sofort am Wurfpunkt.
      -- "all" = netcoredbg bricht bei JEDER Exception ab, nicht erst bei unhandled.
      dap.defaults.fallback.exception_breakpoints = "default"
      dap.defaults.coreclr.exception_breakpoints = { "all" }

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
    end,
  },
}
