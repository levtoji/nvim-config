-- Komponente: lua/config/lazy.lua und lazy-lock.json

describe("config.lazy", function()
  it("bootstrappt lazy.nvim an den Standardpfad", function()
    local src = table.concat(vim.fn.readfile(CONFIG_ROOT .. "/lua/config/lazy.lua"), "\n")
    truthy(src:find('stdpath("data")', 1, true), "lazy.nvim gehoert nach stdpath('data')")
    truthy(src:find("folke/lazy.nvim", 1, true))
    truthy(src:find("--branch=stable", 1, true), "sollte den stable-Branch pinnen")
  end)

  it("laedt Plugins aus lua/plugins", function()
    local src = table.concat(vim.fn.readfile(CONFIG_ROOT .. "/lua/config/lazy.lua"), "\n")
    truthy(src:find('require("lazy").setup("plugins"', 1, true))
  end)

  it("hat eine gueltige lazy-lock.json", function()
    local path = CONFIG_ROOT .. "/lazy-lock.json"
    truthy(vim.uv.fs_stat(path), "lazy-lock.json fehlt")
    local lock = vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
    eq(type(lock), "table")
    truthy(vim.tbl_count(lock) > 0, "Lockfile ist leer")
    for name, entry in pairs(lock) do
      eq(type(entry.commit), "string", ("Eintrag %s hat keinen commit"):format(name))
      truthy(#entry.commit >= 7, ("Eintrag %s hat keinen sinnvollen commit"):format(name))
    end
  end)
end)
