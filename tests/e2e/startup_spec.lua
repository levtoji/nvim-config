-- E2E: die echte Config wurde geladen (nvim -u init.lua), inklusive lazy.nvim.

describe("Start mit der echten Config", function()
  it("hat alle config-Module geladen", function()
    for _, mod in ipairs({
      "config.options",
      "config.keymaps",
      "config.autocmds",
      "config.lsp_inlay_hint_fix",
      "config.lazy",
    }) do
      truthy(package.loaded[mod], ("Modul '%s' wurde nicht geladen"):format(mod))
    end
  end)

  it("hat lazy.nvim aufgesetzt", function()
    local ok, lazy = pcall(require, "lazy")
    truthy(ok, "lazy.nvim ist nicht ladbar")
    truthy(#lazy.plugins() > 0, "lazy kennt keine Plugins")
  end)

  it("hat alle deklarierten Plugins installiert", function()
    local missing = {}
    for _, plugin in ipairs(require("lazy").plugins()) do
      if not plugin._.installed and not plugin.virtual then
        table.insert(missing, plugin.name)
      end
    end
    eq(missing, {}, "nicht installierte Plugins - ':Lazy sync' ausfuehren")
  end)

  it("hat kein Plugin mit Ladefehler", function()
    local broken = {}
    for _, plugin in ipairs(require("lazy").plugins()) do
      if plugin._.has_errors then
        table.insert(broken, plugin.name)
      end
    end
    eq(broken, {})
  end)

  it("hat die Optionen aus config.options aktiv", function()
    eq(vim.g.mapleader, " ")
    eq(vim.o.number, true)
    eq(vim.o.relativenumber, true)
    eq(vim.o.expandtab, true)
    eq(vim.o.shiftwidth, 4)
    eq(vim.o.undofile, true)
  end)

  it("hat das Colorscheme gesetzt", function()
    truthy(vim.g.colors_name, "kein Colorscheme aktiv")
    truthy(
      tostring(vim.g.colors_name):find("tokyonight", 1, true),
      ("erwartet tokyonight, aktiv ist '%s'"):format(tostring(vim.g.colors_name))
    )
  end)

  it("hat den Inlay-Hint-Fix installiert", function()
    eq(require("config.lsp_inlay_hint_fix")._installed, true)
  end)

  it("hat beim Start keinen Fehler gemeldet", function()
    eq(vim.v.errmsg, "", "vim.v.errmsg ist gesetzt")
    local messages = vim.api.nvim_exec2("messages", { output = true }).output or ""
    local bad = {}
    for line in messages:gmatch("[^\n]+") do
      if line:match("^E%d+:") or line:find("stack traceback", 1, true) then
        table.insert(bad, line)
      end
    end
    eq(bad, {}, "Fehler in :messages")
  end)
end)
