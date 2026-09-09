-- Schwebendes Terminal für nx/ng-Kommandos etc., ohne nvim zu verlassen.
-- <C-\> öffnet/schließt (toggleterm-Standard).
-- Lazygit (<leader>gl) läuft über snacks.nvim, siehe lua/plugins/snacks.lua.
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = { "ToggleTerm", "TermExec" },
  keys = { [[<c-\>]] },
  opts = {
    open_mapping = [[<c-\>]],
    direction = "float",
    float_opts = { border = "curved" },
  },
}
