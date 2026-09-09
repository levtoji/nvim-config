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
          "eslint-lsp",
          "lua-language-server",
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
          -- inc-rename.nvim statt vim.lsp.buf.rename: zeigt live alle betroffenen
          -- Stellen, während der neue Name getippt wird (wie Riders Rename-Dialog).
          vim.keymap.set("n", "<leader>rn", function()
            return ":IncRename " .. vim.fn.expand("<cword>")
          end, { buffer = event.buf, expr = true, desc = "LSP: Rename" })
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, "Format Buffer")

          -- Inlay Hints (Parameter-/Typ-Hinweise) anzeigen, falls der Server sie unterstützt -
          -- die Server-Settings dafür (gopls.hints, csharp_enable_inlay_hints_*, ts_ls.inlayHints
          -- unten) reichen allein nicht, das Rendering muss client-seitig aktiviert werden.
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
          end
        end,
      })

      -- Inlay Hints buffer-lokal an/aus schalten
      vim.keymap.set("n", "<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
      end, { desc = "Toggle Inlay Hints" })

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
      local ts_inlay_hints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      }
      vim.lsp.config("ts_ls", {
        settings = {
          typescript = { inlayHints = ts_inlay_hints },
          javascript = { inlayHints = ts_inlay_hints },
        },
      })
      vim.lsp.enable({ "ts_ls", "angularls" })

      -- ESLint-Diagnostics inline (erkennt Monorepo-Configs & .eslintrc/eslint.config.* automatisch)
      vim.lsp.enable("eslint")

      -- Lua (fuer diese Config selbst): "vim" und "Snacks" als bekannte
      -- Globals eintragen, sonst meldet lua_ls jedes vim.*/Snacks.* als
      -- "undefined global" ("Snacks" wird von snacks.nvim zur Laufzeit
      -- global gesetzt, siehe lua/plugins/*.lua-Verwendung).
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim", "Snacks" } },
            hint = { enable = true },
          },
        },
      })
      vim.lsp.enable("lua_ls")
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
