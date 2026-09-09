-- Regressionstest fuer den "Invalid 'col': out of range"-Absturz beim Editieren.
--
-- Siehe lua/config/lsp_inlay_hint_fix.lua fuer die Ursache. Der Test faehrt die
-- Race Condition deterministisch nach: zwei LSP-Clients an einem Buffer, der
-- eine antwortet fuer die alte, der andere fuer die neue Buffer-Version.

local stub = dofile(CONFIG_ROOT .. "/tests/helpers/lsp_stub.lua")

require("config.lsp_inlay_hint_fix")

local LONG = "local averyveryverylongvariablename = { a = 1, b = 2 }"
local SHORT = "local x"

--- @return integer bufnr, table srv_a, table srv_b
local function setup_buffer(line)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { line })
  vim.api.nvim_set_current_buf(buf)

  local a = stub.new("srv_a")
  local b = stub.new("srv_b")
  a.attach(buf)
  b.attach(buf)
  vim.wait(1000, function()
    return #vim.lsp.get_clients({ bufnr = buf }) == 2
  end)

  vim.lsp.inlay_hint.enable(true, { bufnr = buf })
  stub.settle()
  -- Requests aus dem Enable verwerfen, damit jeder Test bei null anfaengt
  a.drop()
  b.drop()
  return buf, a, b
end

local function teardown(buf)
  stub.stop_all(buf)
  if vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end

--- Fuehrt `fn` aus und raeumt danach auf - auch wenn eine Assertion wirft.
--- Ohne das wuerden Zombie-Clients aus einem fehlgeschlagenen Test die
--- folgenden Tests verfaelschen.
local function with_buffer(line, fn)
  local buf, a, b = setup_buffer(line)
  local ok, err = pcall(fn, buf, a, b)
  teardown(buf)
  if not ok then
    error(err, 0)
  end
end

--- Aendert den Buffer und wartet, bis didChange raus und die neuen
--- inlayHint-Requests bei den Stubs angekommen sind.
local function edit(buf, line)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { line })
  stub.settle()
end

local function hints(buf)
  return vim.lsp.inlay_hint.get({ bufnr = buf })
end

--- Kein gespeicherter Hint darf hinter das Ende seiner Zeile zeigen - genau
--- diese Bedingung prueft nvim_buf_set_extmark beim Rendern.
--- @return string[] Verletzungen
local function violations(buf)
  local bad = {}
  local line_count = vim.api.nvim_buf_line_count(buf)
  for _, entry in ipairs(hints(buf)) do
    local pos = entry.inlay_hint.position
    if pos.line < line_count then
      local line = vim.api.nvim_buf_get_lines(buf, pos.line, pos.line + 1, false)[1] or ""
      if pos.character > #line then
        table.insert(bad, ("Client %d: Zeile %d hat %d Bytes, Hint auf Spalte %d")
          :format(entry.client_id, pos.line, #line, pos.character))
      end
    end
  end
  return bad
end

describe("Inlay Hints", function()
  it("stellt die noetigen APIs bereit", function()
    for _, path in ipairs({
      "vim.lsp.inlay_hint.enable",
      "vim.lsp.inlay_hint.is_enabled",
      "vim.lsp.inlay_hint.get",
      "vim.lsp.handlers",
    }) do
      truthy(T.api_exists(path), path .. " existiert nicht mehr")
    end
    truthy(
      vim.lsp.handlers["textDocument/inlayHint"],
      "kein Handler fuer textDocument/inlayHint - der Fix haengt daran"
    )
  end)

  it("speichert Hints eines einzelnen Clients", function()
    with_buffer(LONG, function(buf, a)
      edit(buf, LONG)
      a.reply({ { position = { line = 0, character = 36 }, label = "A" } })

      eq(#hints(buf), 1, "Hint wurde nicht uebernommen - Testaufbau kaputt")
      eq(violations(buf), {})
    end)
  end)

  it("haelt Hints innerhalb der Zeile, wenn derselbe Client nachliefert", function()
    with_buffer(LONG, function(buf, a)
      edit(buf, LONG)
      a.reply({ { position = { line = 0, character = 36 }, label = "A" } })

      edit(buf, SHORT)
      a.reply({ { position = { line = 0, character = 6 }, label = "A" } })

      eq(#hints(buf), 1)
      eq(violations(buf), {})
    end)
  end)

  it("haelt Hints innerhalb der Zeile, wenn zwei Clients versetzt antworten", function()
    -- Genau die Konstellation, die den Absturz ausgeloest hat: zwei Server am
    -- selben Buffer (ts_ls + angularls), einer antwortet fuer die alte Version.
    with_buffer(LONG, function(buf, a, b)
      edit(buf, LONG)
      -- Client A antwortet fuer die aktuelle Version, Hint weit hinten in der Zeile
      a.reply({ { position = { line = 0, character = 36 }, label = "A" } })
      b.drop()

      -- Zeile schrumpft drastisch - das macht ci{
      edit(buf, SHORT)

      -- Nur Client B antwortet fuer die neue Version und zieht bufstate.version hoch
      a.drop()
      b.reply({ { position = { line = 0, character = 0 }, label = "B" } })

      eq(#hints(buf), 2, "beide Clients sollten Hints gespeichert haben")
      eq(violations(buf), {}, "veraltete Hints wuerden nvim_buf_set_extmark sprengen")
    end)
  end)

  it("laesst gueltige Hints unangetastet", function()
    with_buffer("local value = compute(1, 2)", function(buf, a, b)
      edit(buf, "local value = compute(1, 2)")
      a.reply({ { position = { line = 0, character = 11 }, label = ": number" } })
      b.reply({ { position = { line = 0, character = 22 }, label = "x: " } })

      local cols = {}
      for _, entry in ipairs(hints(buf)) do
        table.insert(cols, entry.inlay_hint.position.character)
      end
      table.sort(cols)
      eq(cols, { 11, 22 })
      eq(violations(buf), {})
    end)
  end)

  it("kann alle gespeicherten Hints als Extmark setzen", function()
    -- Fuehrt aus, was der Decoration-Provider tut. Hier per pcall abgesichert,
    -- damit der Fehler im Test landet statt im Redraw.
    with_buffer(LONG, function(buf, a, b)
      edit(buf, LONG)
      a.reply({ { position = { line = 0, character = 36 }, label = "A" } })
      b.drop()
      edit(buf, SHORT)
      a.drop()
      b.reply({ { position = { line = 0, character = 0 }, label = "B" } })

      local ns = vim.api.nvim_create_namespace("inlay_hint_spec")
      local set = 0
      for _, entry in ipairs(hints(buf)) do
        local pos = entry.inlay_hint.position
        local ok, err = pcall(vim.api.nvim_buf_set_extmark, buf, ns, pos.line, pos.character, {
          virt_text_pos = "inline",
          virt_text = { { "hint", "LspInlayHint" } },
        })
        truthy(ok, ("Extmark auf %d:%d abgelehnt: %s"):format(pos.line, pos.character, tostring(err)))
        set = set + 1
      end
      eq(set, 2, "Testaufbau kaputt - es lagen keine zwei Hints vor")
    end)
  end)
end)
