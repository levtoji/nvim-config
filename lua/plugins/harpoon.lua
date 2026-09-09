-- Harpoon: bis zu 4 Dateien fest anpinnen, mit einem Tastendruck dorthin
-- springen - schneller als der Picker für Dateien, die du gerade ständig
-- wechselst.
return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("harpoon"):setup()
  end,
  keys = {
    {
      "<leader>ma",
      function()
        require("harpoon"):list():add()
      end,
      desc = "Harpoon: Add File",
    },
    {
      "<leader>mm",
      function()
        require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
      end,
      desc = "Harpoon: Menu",
    },
    {
      "<leader>1",
      function()
        require("harpoon"):list():select(1)
      end,
      desc = "Harpoon: File 1",
    },
    {
      "<leader>2",
      function()
        require("harpoon"):list():select(2)
      end,
      desc = "Harpoon: File 2",
    },
    {
      "<leader>3",
      function()
        require("harpoon"):list():select(3)
      end,
      desc = "Harpoon: File 3",
    },
    {
      "<leader>4",
      function()
        require("harpoon"):list():select(4)
      end,
      desc = "Harpoon: File 4",
    },
  },
}
