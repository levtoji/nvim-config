-- Komponente: lua/config/autocmds.lua

local function autocmds(event)
  return vim.api.nvim_get_autocmds({ group = "UserConfig", event = event })
end

describe("config.autocmds", function()
  it("laedt fehlerfrei", function()
    no_error(function()
      require("config.autocmds")
    end)
  end)

  it("legt die Gruppe UserConfig an", function()
    truthy(#vim.api.nvim_get_autocmds({ group = "UserConfig" }) > 0)
  end)

  it("hebt gejankten Text hervor", function()
    local found = autocmds("TextYankPost")
    eq(#found, 1)
    eq(found[1].desc, "Highlight yanked text")
  end)

  it("stellt Go auf Tabs um", function()
    local found = vim.tbl_filter(function(a)
      return a.pattern == "go"
    end, autocmds("FileType"))
    eq(#found, 1)

    -- Effekt statt nur Existenz pruefen
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_call(buf, function()
      vim.bo.filetype = "go"
      eq(vim.bo.expandtab, false, "Go darf keine Spaces expandieren")
      eq(vim.bo.shiftwidth, 4)
      eq(vim.bo.tabstop, 4)
    end)
    vim.api.nvim_buf_delete(buf, { force = true })
  end)

  it("formatiert Go-Dateien beim Speichern", function()
    local found = vim.tbl_filter(function(a)
      return a.pattern == "*.go"
    end, autocmds("BufWritePre"))
    eq(#found, 1)
    eq(found[1].desc, "Go-Dateien beim Speichern formatieren (gopls/gofumpt)")
  end)

  it("nutzt nur Neovim-APIs, die es in dieser Version noch gibt", function()
    for _, path in ipairs({ "vim.highlight.on_yank", "vim.lsp.buf.format" }) do
      truthy(T.api_exists(path), path .. " existiert nicht mehr")
    end
  end)
end)
