-- Winziges Test-Framework ohne externe Abhaengigkeiten.
--
-- Bewusst kein plenary/busted: die Tests sollen auch dann laufen, wenn
-- lazy.nvim noch gar nichts installiert hat (frisch geklonte Config, CI).

local M = {
  passed = 0,
  failed = 0,
  failures = {},
  _suite = nil,
}

--- @param name string
--- @param fn fun()
function M.describe(name, fn)
  local prev = M._suite
  M._suite = prev and (prev .. " > " .. name) or name
  local ok, err = pcall(fn)
  if not ok then
    M.failed = M.failed + 1
    table.insert(M.failures, { name = M._suite .. " (describe)", err = err })
    io.write("  ✗ ", M._suite, " (Fehler beim Aufbau)\n")
  end
  M._suite = prev
end

--- @param name string
--- @param fn fun()
function M.it(name, fn)
  local full = (M._suite and (M._suite .. " > ") or "") .. name
  local ok, err = pcall(fn)
  if ok then
    M.passed = M.passed + 1
    io.write("  ✓ ", full, "\n")
  else
    M.failed = M.failed + 1
    table.insert(M.failures, { name = full, err = err })
    io.write("  ✗ ", full, "\n")
  end
end

local function fail(msg)
  error(msg, 3)
end

local function show(v)
  if type(v) == "string" then
    return string.format("%q", v)
  end
  return vim.inspect(v)
end

function M.eq(actual, expected, msg)
  if not vim.deep_equal(actual, expected) then
    fail(string.format(
      "%serwartet: %s\n     bekommen: %s",
      msg and (msg .. "\n     ") or "",
      show(expected),
      show(actual)
    ))
  end
end

function M.truthy(value, msg)
  if not value then
    fail(msg or ("erwartet: truthy, bekommen: " .. show(value)))
  end
end

function M.falsy(value, msg)
  if value then
    fail(msg or ("erwartet: falsy, bekommen: " .. show(value)))
  end
end

--- @param list any[]
function M.contains(list, value, msg)
  if not vim.tbl_contains(list, value) then
    fail(string.format(
      "%s%s nicht enthalten in %s",
      msg and (msg .. "\n     ") or "",
      show(value),
      show(list)
    ))
  end
end

--- @param fn fun()
function M.no_error(fn, msg)
  local ok, err = pcall(fn)
  if not ok then
    fail((msg and (msg .. "\n     ") or "") .. "unerwarteter Fehler: " .. tostring(err))
  end
end

--- Prueft, ob ein punktierter Pfad wie "vim.diagnostic.goto_prev" existiert.
--- Faengt weggefallene APIs nach einem Neovim-Upgrade.
--- @param path string
function M.api_exists(path)
  local obj = _G
  for part in path:gmatch("[^.]+") do
    if type(obj) ~= "table" then
      return false
    end
    obj = obj[part]
  end
  return obj ~= nil
end

function M.report()
  io.write("\n")
  if #M.failures > 0 then
    io.write("Fehlgeschlagen:\n")
    for _, f in ipairs(M.failures) do
      io.write("\n  ✗ ", f.name, "\n     ", tostring(f.err):gsub("\n", "\n     "), "\n")
    end
    io.write("\n")
  end
  io.write(string.format("%d bestanden, %d fehlgeschlagen\n", M.passed, M.failed))
  return M.failed == 0
end

return M
