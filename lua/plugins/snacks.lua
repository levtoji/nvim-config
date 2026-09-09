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
    -- den Explorer-Picker ein (siehe snacks/explorer/actions.lua explorer_rename).
    rename = { enabled = true },
    -- Highlightet automatisch alle Referenzen des Symbols unter dem Cursor,
    -- ]]/[[ zum Springen zwischen den Vorkommen.
    words = { enabled = true },
    gitbrowse = { enabled = true },
    -- Lazygit als schwebendes Terminal: Neogit bleibt Standard, Lazygit für
    -- Rebases/Merge-Konflikte, wo es die bessere UI hat. Ersetzt die frühere
    -- toggleterm-Eigenlösung; Bonus ggü. der: Auto-Theme passend zum
    -- Colorscheme + Edit-Integration mit der laufenden nvim-Instanz.
    lazygit = { enabled = true },
    -- Datei-Explorer als Sidebar, ersetzt neo-tree (weniger Dependencies:
    -- kein plenary/nui.nvim mehr nur dafür). replace_netrw wie bisher bei
    -- neo-tree: Öffnet sich automatisch, wenn ein Verzeichnis geöffnet wird.
    explorer = { replace_netrw = true },
    picker = {
      sources = {
        explorer = {
          follow_file = true,
          layout = { layout = { position = "left" } },
        },
      },
    },
  },
  keys = {
    { "<leader>z", function() Snacks.zen() end, desc = "Zen Mode" },
    { "<leader>H", function() Snacks.dashboard() end, desc = "Dashboard" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse (im Browser öffnen)" },
    { "<leader>gl", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>e", function() Snacks.explorer() end, desc = "Toggle File Explorer" },
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
