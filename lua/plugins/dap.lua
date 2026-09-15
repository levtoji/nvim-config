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

      -- Node/TypeScript (agent-portal & Co.) ueber vscode-js-debug. "pwa-node"
      -- ist der type, den VS Code's launch.json fuer Node-Launches verwendet -
      -- gleicher Adapter-Name macht bestehende launch.json-Dateien direkt kompatibel.
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = mason_bin .. "/js-debug-adapter",
          args = { "${port}" },
        },
      }
      dap.configurations.typescript = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach to process",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
        {
          -- Fallback fuer Projekte ohne launch.json: statt jedes Mal Terminal
          -- + "npm run ..." zu tippen, hier den Skriptnamen einmal abfragen.
          type = "pwa-node",
          request = "launch",
          name = "npm run <script>",
          runtimeExecutable = "npm",
          runtimeArgs = function()
            return { "run", vim.fn.input("npm-Script (package.json): ") }
          end,
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
        },
      }
      dap.configurations.javascript = vim.deepcopy(dap.configurations.typescript)

      -- Projekt-eigene Run/Debug-Configs (Rider-Paritaet): der eingebaute
      -- "dap.launch.json"-Provider liest .vscode/launch.json aus dem cwd bei
      -- JEDEM F9 automatisch frisch (kein manuelles Neuladen noetig) und
      -- zeigt die Eintraege zusammen mit den obigen Fallbacks zur Auswahl an.
    end,
  },
}
