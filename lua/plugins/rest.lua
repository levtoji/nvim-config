-- HTTP-Client wie Rider's HTTP-Client-Tool: .http-Dateien (inkl. http-client.env.json) direkt in
-- nvim gegen die vielen *-bff-Services abfeuern, ohne Postman/Insomnia. Reines Lua, ausgeführt
-- wird per httpyac-CLI (`npm install -g httpyac`).
return {
  "abidibo/nvim-httpyac",
  ft = "http",
  config = function()
    require("nvim-httpyac").setup()
  end,
  keys = {
    { "<leader>Rs", "<cmd>NvimHttpYac<CR>", ft = "http", desc = "Send request" },
    { "<leader>Ra", "<cmd>NvimHttpYacAll<CR>", ft = "http", desc = "Send all requests" },
    { "<leader>Rp", "<cmd>NvimHttpYacPicker<CR>", ft = "http", desc = "Pick named request" },
    { "<leader>Re", "<cmd>NvimHttpYacEnv<CR>", ft = "http", desc = "Select environment" },
    { "<leader>Rc", "<cmd>NvimHttpYacEnvClear<CR>", ft = "http", desc = "Clear environment" },
    { "<leader>Ry", "<cmd>NvimHttpYacCopyCmd<CR>", ft = "http", desc = "Copy httpyac command" },
  },
}
