-- Komponente: alle lua/plugins/*.lua
--
-- Prueft jede Plugin-Datei generisch. Das faengt genau die Fehler, die sonst
-- erst Wochen spaeter auffallen: Tippfehler in Feldnamen (lazy.nvim ignoriert
-- unbekannte Felder still), doppelt deklarierte Plugins, Keymaps ohne desc.

-- Feldnamen laut lazy.nvim LazyPluginSpec
local KNOWN_FIELDS = {
  [1] = true,
  name = true, main = true, url = true, dir = true, enabled = true, cond = true,
  optional = true, lazy = true, priority = true, dev = true, rocks = true,
  virtual = true, dependencies = true, specs = true, import = true,
  event = true, cmd = true, ft = true, keys = true, module = true,
  init = true, deactivate = true, config = true, build = true, opts = true,
  branch = true, tag = true, commit = true, version = true, pin = true,
  submodules = true,
}

--- lazy.nvim-Regel: ist spec[1] ein String, ist es ein einzelnes Plugin,
--- sonst eine Liste von Specs.
local function is_plugin(spec)
  return type(spec) == "table" and (type(spec[1]) == "string" or spec.dir or spec.url)
end

--- @param deps boolean? auch Eintraege aus `dependencies` aufnehmen
--- @return table[] flache Liste aller Plugin-Specs
local function flatten(spec, deps, out)
  out = out or {}
  if type(spec) == "string" then
    table.insert(out, { spec })
  elseif is_plugin(spec) then
    table.insert(out, spec)
    if deps then
      for _, dep in ipairs(spec.dependencies or {}) do
        flatten(dep, deps, out)
      end
    end
  elseif type(spec) == "table" then
    for _, child in ipairs(spec) do
      flatten(child, deps, out)
    end
  end
  return out
end

local files = vim.fn.glob(CONFIG_ROOT .. "/lua/plugins/*.lua", false, true)
table.sort(files)

describe("lua/plugins", function()
  it("enthaelt ueberhaupt Plugin-Dateien", function()
    truthy(#files > 0, "keine Dateien in lua/plugins gefunden")
  end)
end)

-- Sammelt alle Plugins fuer die dateiuebergreifenden Checks weiter unten
local all = {}

for _, file in ipairs(files) do
  local short = vim.fn.fnamemodify(file, ":t")

  describe("plugins." .. short, function()
    local spec

    it("laedt fehlerfrei und liefert eine Tabelle", function()
      local chunk, load_err = loadfile(file)
      truthy(chunk, "Syntaxfehler: " .. tostring(load_err))
      local ok, result = pcall(chunk)
      truthy(ok, "Laufzeitfehler beim Laden: " .. tostring(result))
      eq(type(result), "table")
      spec = result
    end)

    it("deklariert mindestens ein Plugin", function()
      truthy(spec, "Datei konnte nicht geladen werden")
      local plugins = flatten(spec, false)
      truthy(#plugins > 0, "keine Plugin-Spec gefunden")
      for _, p in ipairs(plugins) do
        table.insert(all, { file = short, plugin = p })
      end
    end)

    it("nutzt nur bekannte lazy.nvim-Felder", function()
      truthy(spec, "Datei konnte nicht geladen werden")
      for _, p in ipairs(flatten(spec, true)) do
        for key in pairs(p) do
          truthy(
            KNOWN_FIELDS[key],
            ("unbekanntes Feld '%s' bei '%s' - Tippfehler? lazy.nvim ignoriert das still")
              :format(tostring(key), tostring(p[1] or p.dir))
          )
        end
      end
    end)

    it("hat plausible Plugin-Namen (owner/repo)", function()
      truthy(spec, "Datei konnte nicht geladen werden")
      for _, p in ipairs(flatten(spec, true)) do
        if type(p[1]) == "string" then
          truthy(
            p[1]:match("^[%w%-%._]+/[%w%-%._]+$"),
            ("'%s' sieht nicht wie owner/repo aus"):format(p[1])
          )
        end
      end
    end)

    it("gibt jedem Keymap eine Beschreibung", function()
      truthy(spec, "Datei konnte nicht geladen werden")
      for _, p in ipairs(flatten(spec, true)) do
        if type(p.keys) == "table" then
          for _, key in ipairs(p.keys) do
            if type(key) == "table" and key[1] then
              truthy(
                key.desc,
                ("Keymap '%s' in %s hat kein desc (taucht sonst nicht in which-key auf)")
                  :format(tostring(key[1]), tostring(p[1]))
              )
            end
          end
        end
      end
    end)
  end)
end

describe("lua/plugins (dateiuebergreifend)", function()
  it("deklariert kein Plugin doppelt", function()
    -- `all` enthaelt nur Top-Level-Specs; dependencies duerfen bewusst in
    -- mehreren Dateien auftauchen (lazy.nvim merged die).
    local seen = {}
    for _, entry in ipairs(all) do
      local name = entry.plugin[1]
      if type(name) == "string" then
        seen[name] = seen[name] or {}
        table.insert(seen[name], entry.file)
      end
    end
    local dupes = {}
    for name, filelist in pairs(seen) do
      local distinct = {}
      for _, f in ipairs(filelist) do
        distinct[f] = true
      end
      if vim.tbl_count(distinct) > 1 then
        table.insert(dupes, ("%s (%s)"):format(name, table.concat(vim.tbl_keys(distinct), ", ")))
      end
    end
    eq(dupes, {}, "Plugins in mehreren Dateien deklariert")
  end)

  it("kollidiert nicht mit den globalen Keymaps aus config/keymaps.lua", function()
    local global = {}
    local src = table.concat(vim.fn.readfile(CONFIG_ROOT .. "/lua/config/keymaps.lua"), "\n")
    for mode, lhs in src:gmatch('map%("(%a)",%s*"([^"]+)"') do
      global[mode .. " " .. lhs] = true
    end

    local clashes = {}
    for _, entry in ipairs(all) do
      local keys = entry.plugin.keys
      if type(keys) == "table" then
        for _, key in ipairs(keys) do
          local lhs = type(key) == "table" and key[1] or key
          if type(lhs) == "string" then
            local modes = type(key) == "table" and key.mode or "n"
            modes = type(modes) == "table" and modes or { modes }
            for _, m in ipairs(modes) do
              if global[m .. " " .. lhs] then
                table.insert(clashes, ("%s %s (%s)"):format(m, lhs, entry.file))
              end
            end
          end
        end
      end
    end
    eq(clashes, {}, "Plugin-Keymaps ueberschreiben globale Keymaps")
  end)
end)
