-- Schwebendes Terminal für nx/ng-Kommandos etc., ohne nvim zu verlassen.
-- <C-\> öffnet/schließt (toggleterm-Standard).
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  cmd = { "ToggleTerm", "TermExec" },
  keys = { [[<c-\>]], "<leader>gl" },
  opts = {
    open_mapping = [[<c-\>]],
    direction = "float",
    float_opts = { border = "curved" },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)

    -- Lazygit als schwebendes Terminal daneben: Neogit bleibt Standard,
    -- Lazygit für Rebases/Merge-Konflikte, wo es die bessere UI hat.
    local Terminal = require("toggleterm.terminal").Terminal
    local lazygit = Terminal:new({
      cmd = "lazygit",
      dir = "git_dir",
      direction = "float",
      hidden = true,
      float_opts = { border = "curved" },
    })

    vim.keymap.set("n", "<leader>gl", function()
      lazygit:toggle()
    end, { desc = "Lazygit" })
  end,
}
