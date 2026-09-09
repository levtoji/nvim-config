-- E2E: echtes Editieren in einem echten Buffer mit angehaengten LSP-Clients.
--
-- Der Absturz "Invalid 'col': out of range" trat beim Bearbeiten auf (ci{).
-- Hier wird genau das gefahren - inklusive der LspAttach-Kette aus
-- lua/plugins/lsp.lua, die Inlay Hints ueberhaupt erst einschaltet.

local stub = dofile(CONFIG_ROOT .. "/tests/helpers/lsp_stub.lua")

local tmpdir = vim.fn.tempname()
vim.fn.mkdir(tmpdir, "p")

--- Oeffnet eine echte Datei. Dateityp txt, damit ausser den Stubs kein
--- echter Sprachserver anspringt.
local function open_file(lines)
  local path = tmpdir .. "/probe_" .. tostring(vim.uv.hrtime()) .. ".txt"
  vim.fn.writefile(lines, path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  return vim.api.nvim_get_current_buf()
end

local function feed(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "x", false)
end

local function violations(buf)
  local bad = {}
  local line_count = vim.api.nvim_buf_line_count(buf)
  for _, entry in ipairs(vim.lsp.inlay_hint.get({ bufnr = buf })) do
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

describe("Editieren mit aktiven Inlay Hints", function()
  it("laedt nvim-lspconfig beim Oeffnen einer Datei", function()
    open_file({ "hallo" })
    local lazy = require("lazy.core.config")
    local plugin = lazy.plugins["nvim-lspconfig"]
    truthy(plugin, "nvim-lspconfig ist lazy unbekannt")
    truthy(plugin._.loaded, "nvim-lspconfig wurde beim Oeffnen einer Datei nicht geladen")
  end)

  it("schaltet Inlay Hints ein, sobald ein faehiger Server attached", function()
    local buf = open_file({ "irrelevant" })
    local srv = stub.new("e2e_single")
    srv.attach(buf)
    vim.wait(1000, function()
      return #vim.lsp.get_clients({ bufnr = buf }) >= 1
    end)
    stub.settle()

    eq(
      vim.lsp.inlay_hint.is_enabled({ bufnr = buf }),
      true,
      "der LspAttach-Autocmd aus lua/plugins/lsp.lua hat Inlay Hints nicht aktiviert"
    )

    stub.stop_all(buf)
    vim.api.nvim_buf_delete(buf, { force = true })
  end)

  it("uebersteht ci{ mit zwei versetzt antwortenden Servern", function()
    local buf = open_file({
      "public void Foo() {",
      "    var averyveryverylongvariablename = new Dictionary<string, int>();",
      "}",
    })

    local a = stub.new("e2e_a")
    local b = stub.new("e2e_b")
    a.attach(buf)
    b.attach(buf)
    vim.wait(2000, function()
      return #vim.lsp.get_clients({ bufnr = buf }) == 2
    end)
    eq(#vim.lsp.get_clients({ bufnr = buf }), 2, "Stub-Server sind nicht attached")
    stub.settle()
    a.drop()
    b.drop()

    -- Aenderung -> beide Server bekommen einen inlayHint-Request
    vim.api.nvim_win_set_cursor(0, { 2, 4 })
    feed("A // touch<Esc>")
    stub.settle()

    -- Server A antwortet fuer den aktuellen Stand mit einem Hint weit hinten
    local long = vim.api.nvim_buf_get_lines(buf, 1, 2, false)[1]
    a.reply({ { position = { line = 1, character = #long - 2 }, label = ": var" } })
    b.drop()

    -- Jetzt der eigentliche Ausloeser: ci{ loescht den kompletten Block
    vim.api.nvim_win_set_cursor(0, { 1, 18 })
    feed("ci{<Esc>")
    stub.settle()

    -- Nur Server B antwortet fuer den neuen Stand
    a.drop()
    b.reply({ { position = { line = 0, character = 0 }, label = "B" } })

    eq(violations(buf), {}, "veraltete Hints zeigen hinter das Zeilenende")

    -- Ein echter Redraw darf keinen Fehler produzieren
    vim.v.errmsg = ""
    vim.cmd("redraw!")
    eq(vim.v.errmsg, "")

    local messages = vim.api.nvim_exec2("messages", { output = true }).output or ""
    falsy(
      messages:find("Invalid 'col'", 1, true),
      "Decoration-Provider hat 'Invalid col' gemeldet"
    )
    falsy(
      messages:find("Decoration provider", 1, true),
      "Decoration-Provider wurde mit Fehler deaktiviert"
    )

    stub.stop_all(buf)
    vim.api.nvim_buf_delete(buf, { force = true })
  end)

  it("haelt <leader>th als Toggle bereit", function()
    local buf = open_file({ "irrelevant" })
    local found = false
    for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
      if m.desc == "Toggle Inlay Hints" then
        found = true
      end
    end
    truthy(found, "Keymap 'Toggle Inlay Hints' fehlt")
    vim.api.nvim_buf_delete(buf, { force = true })
  end)
end)
