return {
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
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
