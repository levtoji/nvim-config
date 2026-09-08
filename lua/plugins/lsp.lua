return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    dependencies = { "WhoIsSethDaniel/mason-tool-installer.nvim" },
    opts = {},
    -- Zentrale Stelle für alle Tools, die es nicht über brew/npm core gibt -
    -- Debug-Adapter (dap.lua) und Sprachserver landen hier gemeinsam, damit
    -- nicht zwei Plugins gegeneinander mason-tool-installer.setup() aufrufen.
    config = function(_, opts)
      require("mason").setup(opts)
      require("mason-tool-installer").setup({
        ensure_installed = {
          "delve",
          "netcoredbg",
          "roslyn-language-server",
          "typescript-language-server",
          "angular-language-server",
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    -- Lädt LSP-Setup erst beim Öffnen einer echten Datei statt bei jedem
    -- nvim-Start (zieht mason + blink.cmp als Dependencies mit).
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- Einheitliche Keymaps für jeden LSP-Server, der an einen Buffer attached
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end
          map("gd", vim.lsp.buf.definition, "Goto Definition")
          map("gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("gr", vim.lsp.buf.references, "Goto References")
          map("gI", vim.lsp.buf.implementation, "Goto Implementation")
          map("<leader>D", vim.lsp.buf.type_definition, "Type Definition")
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, "Format Buffer")
        end,
      })

      -- Completion-Fähigkeiten von blink.cmp an alle Server weiterreichen
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            gofumpt = true,
            staticcheck = true,
            analyses = { unusedparams = true },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              constantValues = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
          },
        },
      })
      vim.lsp.enable("gopls")

      -- TypeScript/Angular (agent-portal & Co, Nx-Monorepo): ts_ls für die
      -- Sprache, angularls zusätzlich für Angular-Templates/Komponenten.
      -- Root-Erkennung (u.a. über nx.json) übernimmt nvim-lspconfig selbst.
      vim.lsp.enable({ "ts_ls", "angularls" })
    end,
  },
  {
    -- Microsofts offizieller Roslyn-LSP statt OmniSharp: schneller, aktiv gepflegt,
    -- bessere Code-Fixes/Refactorings. Lädt den Roslyn-Server beim ersten Start selbst.
    "seblyng/roslyn.nvim",
    ft = "cs",
    opts = {
      config = {
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
          },
        },
      },
    },
  },
}
