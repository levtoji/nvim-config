-- Komponente: lua/config/options.lua

describe("config.options", function()
  it("laedt fehlerfrei", function()
    no_error(function()
      require("config.options")
    end)
  end)

  it("setzt Leader auf <Space>", function()
    eq(vim.g.mapleader, " ")
    eq(vim.g.maplocalleader, " ")
  end)

  it("setzt die Editor-Grundoptionen", function()
    local expected = {
      number = true,
      relativenumber = true,
      mouse = "a",
      clipboard = "unnamedplus",
      breakindent = true,
      undofile = true,
      ignorecase = true,
      smartcase = true,
      signcolumn = "yes",
      updatetime = 250,
      timeoutlen = 300,
      splitright = true,
      splitbelow = true,
      list = true,
      inccommand = "split",
      cursorline = true,
      scrolloff = 8,
      termguicolors = true,
    }
    for name, want in pairs(expected) do
      eq(vim.o[name], want, "Option '" .. name .. "'")
    end
  end)

  it("nutzt 4 Spaces als Indent-Default (C#-Konvention)", function()
    eq(vim.o.expandtab, true)
    eq(vim.o.shiftwidth, 4)
    eq(vim.o.tabstop, 4)
    eq(vim.o.smartindent, true)
  end)

  it("zeigt Tabs, Trailing Whitespace und NBSP an", function()
    eq(vim.opt.listchars:get(), { tab = "» ", trail = "·", nbsp = "␣" })
  end)
end)
