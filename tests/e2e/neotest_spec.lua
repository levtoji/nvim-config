-- E2E: neotest-Adapter muessen mit Optionen initialisiert werden.
--
-- Regression: require("neotest-golang") und require("neotest-dotnet")
-- liefern ein Modul, das per setmetatable(__call) aufgerufen werden muss,
-- damit Adapter.options gefuellt wird. War frueher in test.lua vergessen -
-- filter_dir() ist dann mit "attempt to index field 'options' (a nil value)"
-- abgestuerzt, sobald Neotest ausserhalb eines Go-Projekts nach Tests sucht
-- (z.B. mit cwd = diesem Config-Repo). Siehe ~/.local/state/nvim/neotest.log.

describe("plugins.test (neotest)", function()
  it("laedt neotest inkl. Adaptern und initialisiert deren Optionen", function()
    require("lazy").load({ plugins = { "neotest" } })

    local ok_golang, golang = pcall(require, "neotest-golang")
    truthy(ok_golang, "neotest-golang ist nicht ladbar")
    truthy(golang.options, "neotest-golang wurde nicht als Funktion aufgerufen - Adapter.options ist nil")

    -- neotest-dotnet exponiert keine .options wie neotest-golang, sondern
    -- haelt seine Config in modul-lokalen Variablen (dap, custom_attribute_args,
    -- ...). Hier laesst sich also nur pruefen, dass es ueberhaupt ladbar bleibt.
    local ok_dotnet = pcall(require, "neotest-dotnet")
    truthy(ok_dotnet, "neotest-dotnet ist nicht ladbar")
  end)

  it("filter_dir() ueberlebt einen Discovery-Scan ausserhalb eines Go-Projekts", function()
    require("lazy").load({ plugins = { "neotest" } })
    local golang = require("neotest-golang")

    no_error(function()
      golang.filter_dir("lua", "lua", CONFIG_ROOT)
    end, "filter_dir() ist mit uninitialisierten Adapter.options abgestuerzt")
  end)
end)
