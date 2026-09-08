-- "Smart Selection" wie in Rider (Strg+W "Extend Selection"): af/if/ac/ic
-- Textobjekte für Funktionen/Klassen + ]m/[m Navigation, plus echtes
-- inkrementelles Erweitern der Selektion (<C-Space> wiederholt drücken).
-- Ersetzt das alte incremental_selection-Modul, das im "main"-Branch von
-- nvim-treesitter entfernt wurde.
return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.g.no_plugin_maps = true
    end,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.outer"] = "V",
            ["@class.outer"] = "V",
          },
        },
        move = {
          set_jumps = true,
        },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local map = vim.keymap.set

      map({ "x", "o" }, "af", function()
        select.select_textobject("@function.outer")
      end, { desc = "Select around function" })
      map({ "x", "o" }, "if", function()
        select.select_textobject("@function.inner")
      end, { desc = "Select inside function" })
      map({ "x", "o" }, "ac", function()
        select.select_textobject("@class.outer")
      end, { desc = "Select around class" })
      map({ "x", "o" }, "ic", function()
        select.select_textobject("@class.inner")
      end, { desc = "Select inside class" })
      map({ "x", "o" }, "ap", function()
        select.select_textobject("@parameter.outer")
      end, { desc = "Select around parameter" })
      map({ "x", "o" }, "ip", function()
        select.select_textobject("@parameter.inner")
      end, { desc = "Select inside parameter" })

      map({ "n", "x", "o" }, "]m", function()
        move.goto_next_start("@function.outer")
      end, { desc = "Next function start" })
      map({ "n", "x", "o" }, "[m", function()
        move.goto_previous_start("@function.outer")
      end, { desc = "Previous function start" })
    end,
  },
  {
    -- <C-Space> in normal mode startet die Selektion, danach wiederholt <C-Space>
    -- zum Erweitern auf den nächsten umschließenden Knoten, <M-Space> zum Verkleinern.
    "maxischmaxi/inc-select.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
}
