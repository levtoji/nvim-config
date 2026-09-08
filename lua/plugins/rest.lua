-- Rider's HTTP-Client-Tool: .http-Dateien direkt in nvim gegen die vielen
-- *-bff-Services abfeuern, ohne Postman/Insomnia. Braucht curl, git und
-- tree-sitter-cli (letzteres ist laut README schon Voraussetzung dieser Config).
return {
  "mistweaverco/kulala.nvim",
  ft = { "http", "rest" },
  keys = {
    { "<leader>Rs", desc = "Send request" },
    { "<leader>Ra", desc = "Send all requests" },
    { "<leader>Rb", desc = "Open scratchpad" },
  },
  opts = {
    global_keymaps = true,
  },
}
