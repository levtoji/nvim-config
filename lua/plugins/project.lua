-- Projekt-Switcher (Cmd+O-Äquivalent): entdeckt Repos per Glob-Pattern, wechselt
-- cwd beim Auswählen dorthin und stellt die letzte Session (offene Buffer/Tabs)
-- automatisch wieder her. Ersetzt eine vorherige custom fd/fzf-lua-Lösung.
return {
  "coffebar/neovim-project",
  opts = {
    projects = {
      "~/RiderProjects/*",
      "~/WebstormProjects/*",
      "~/.config/*",
    },
    picker = {
      type = "fzf-lua",
    },
    -- Verhindert, dass Session-Autoload beim leeren "nvim"-Aufruf mit dem
    -- snacks-Dashboard um den Startbildschirm konkurriert.
    dashboard_mode = true,
  },
  init = function()
    vim.opt.sessionoptions:append("globals")
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ibhagwan/fzf-lua",
    "Shatur/neovim-session-manager",
  },
  lazy = false,
  priority = 100,
  keys = {
    { "<leader>fp", "<cmd>NeovimProjectDiscover<cr>", desc = "Find Project" },
    { "<leader>fP", "<cmd>NeovimProjectHistory<cr>", desc = "Recent Projects" },
  },
}
