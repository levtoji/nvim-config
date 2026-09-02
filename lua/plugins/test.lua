return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "fredrikaverpil/neotest-golang",
    "Issafalcon/neotest-dotnet",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-golang"),
        require("neotest-dotnet"),
      },
    })

    local neotest = require("neotest")
    vim.keymap.set("n", "<leader>tt", function()
      neotest.run.run()
    end, { desc = "Test: Run Nearest" })
    vim.keymap.set("n", "<leader>tf", function()
      neotest.run.run(vim.fn.expand("%"))
    end, { desc = "Test: Run File" })
    vim.keymap.set("n", "<leader>td", function()
      neotest.run.run({ strategy = "dap" })
    end, { desc = "Test: Debug Nearest" })
    vim.keymap.set("n", "<leader>ts", function()
      neotest.summary.toggle()
    end, { desc = "Test: Toggle Summary" })
    vim.keymap.set("n", "<leader>to", function()
      neotest.output.open({ enter = true })
    end, { desc = "Test: Show Output" })
    vim.keymap.set("n", "<leader>tO", function()
      neotest.output_panel.toggle()
    end, { desc = "Test: Toggle Output Panel" })
  end,
}
