-- snacks.nvim war bisher nur ein stiller Dependency von claudecode.nvim - hier
-- wird es tatsächlich konfiguriert.
return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    zen = { enabled = true },
    notifier = { enabled = true },
    -- Ersetzt indent-blankline.nvim: gleiche Guides, zusätzlich Scope-
    -- Highlighting + dezente Animation, eine Dependency weniger.
    indent = { enabled = true },
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
    -- Schwebendes Terminal für nx/ng-Kommandos etc., ersetzt toggleterm.nvim
    -- (eine Dependency weniger, gleiche Optik wie Lazygit/Explorer-Floats).
    terminal = {
      win = { style = "float", border = "rounded" },
    },
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
        -- Requirements für gh_issue/gh_pr: `gh` CLI installiert + eingeloggt.
        gh_issue = {},
        gh_pr = {},
      },
    },
    -- Schützt vor Freezes bei riesigen/minifizierten Dateien: deaktiviert
    -- LSP/Treesitter automatisch, sobald eine Datei zu groß ist.
    bigfile = { enabled = true },
    -- Kombinierte Gutter-Spalte (Marks/Signs/Folds/Git), ersetzt nichts,
    -- nutzt aber automatisch gitsigns' Signs (Pattern "GitSign").
    statuscolumn = { enabled = true },
    -- Smooth Scrolling.
    scroll = { enabled = true },
    -- Fokus-Dimming: dimmt alles außer dem aktuellen Scope, <leader>uD zum
    -- Toggle. Ergänzt das Scope-Highlighting von snacks.indent.
    dim = {},
    -- GitHub Issues/PRs direkt in nvim browsen, kommentieren, mergen etc.
    -- Setzt die `gh`-CLI voraus (installiert + `gh auth login`).
    gh = { enabled = true },
    -- Schöneres vim.ui.input (u.a. für Snacks.rename's Dateiname-Prompt).
    input = { enabled = true },
    -- Scratch-Buffer für schnelle Notizen/Code-Experimente, <leader>. Toggle,
    -- <leader>S wählt einen bestehenden Scratch-Buffer aus.
    scratch = {},
  },
  keys = {
    { "<leader>z", function() Snacks.zen() end, desc = "Zen Mode" },
    { "<leader>H", function() Snacks.dashboard() end, desc = "Dashboard" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse (im Browser öffnen)" },
    { "<leader>gl", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (offen)" },
    { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (alle)" },
    { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (offen)" },
    { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (alle)" },
    { "<leader>e", function() Snacks.explorer() end, desc = "Toggle File Explorer" },
    { [[<c-\>]], function() Snacks.terminal.toggle() end, mode = { "n", "t" }, desc = "Toggle Terminal" },
    { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File (mit Import-Update)" },
    { "<leader>uD", function() Snacks.dim() end, desc = "Toggle Dim (Fokus auf Scope)" },
    { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
    { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
    -- Finder (ersetzt fzf-lua, weniger Dependencies):
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Live Grep" },
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Find Buffers" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
    { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "Document Symbols" },
    { "<leader>fw", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace Symbols" },
    { "<leader>fd", function() Snacks.picker.diagnostics_buffer() end, desc = "Diagnostics" },
    { "<leader>fc", function() Snacks.picker.commands() end, desc = "Command Palette" },
    { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Search Keymaps" },
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
