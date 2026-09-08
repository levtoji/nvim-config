-- snacks.nvim war bisher nur ein stiller Dependency von claudecode.nvim - hier
-- wird es tatsächlich konfiguriert. indent ist bewusst NICHT aktiviert, das
-- übernimmt schon indent-blankline.nvim (sonst zwei konkurrierende Guides).
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    zen = { enabled = true },
    notifier = { enabled = true },
    -- aus: kollidiert mit neovim-project's Session-Autoload, das hat Vorrang.
    dashboard = { enabled = false },
    -- LSP-Rename für Dateien inkl. Import-Update; hookt sich automatisch in
    -- neo-tree's rename-Aktion ein (siehe snacks/rename.lua meta.desc).
    rename = { enabled = true },
    -- Highlightet automatisch alle Referenzen des Symbols unter dem Cursor,
    -- ]]/[[ zum Springen zwischen den Vorkommen.
    words = { enabled = true },
    gitbrowse = { enabled = true },
  },
  keys = {
    { "<leader>z", function() Snacks.zen() end, desc = "Zen Mode" },
    { "<leader>H", function() Snacks.dashboard() end, desc = "Dashboard" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse (im Browser öffnen)" },
    { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File (mit Import-Update)" },
    {
      "]]",
      function() Snacks.words.jump(vim.v.count1, true) end,
      desc = "Next Reference",
    },
    {
      "[[",
      function() Snacks.words.jump(-vim.v.count1, true) end,
      desc = "Previous Reference",
    },
  },
}
