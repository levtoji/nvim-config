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

  it("stellt den Web-Stack auf 2 Spaces um, wenn kein .editorconfig existiert", function()
    local dir = vim.fn.tempname()
    vim.fn.mkdir(dir, "p")
    local path = dir .. "/probe.ts"
    vim.fn.writefile({ "const x = 1;" }, path)

    local buf = vim.fn.bufadd(path)
    vim.fn.bufload(buf)
    vim.api.nvim_buf_call(buf, function()
      vim.bo.shiftwidth = 8 -- absichtlich falscher Ausgangswert
      vim.bo.filetype = "typescript"
      eq(vim.bo.shiftwidth, 2, "sollte auf 2 Spaces umgestellt werden")
      eq(vim.bo.tabstop, 2)
    end)
    vim.api.nvim_buf_delete(buf, { force = true })
  end)

  it("laesst den Web-Stack unangetastet, wenn ein .editorconfig existiert", function()
    -- .editorconfig hat immer Vorrang - der eingebaute editorconfig-Support
    -- (:h editorconfig) kuemmert sich darum. Dieser Default darf ihm nicht
    -- ins Handwerk pfuschen.
    local dir = vim.fn.tempname()
    vim.fn.mkdir(dir, "p")
    vim.fn.writefile({ "root = true", "[*]", "indent_size = 4" }, dir .. "/.editorconfig")
    local path = dir .. "/probe.ts"
    vim.fn.writefile({ "const x = 1;" }, path)

    local buf = vim.fn.bufadd(path)
    vim.fn.bufload(buf)
    vim.api.nvim_buf_call(buf, function()
      vim.bo.shiftwidth = 8
      vim.bo.filetype = "typescript"
      eq(vim.bo.shiftwidth, 8, "sollte den vorhandenen Wert nicht anfassen")
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
