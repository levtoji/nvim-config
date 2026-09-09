-- Workaround fuer einen Bug in Neovims eingebauten Inlay-Hints (0.12.5).
--
-- Symptom: beim Bearbeiten (z.B. ci{) bricht der Decoration-Provider ab mit
--   Decoration provider "win" (ns=nvim.lsp.inlayhint):
--   vim/lsp/inlay_hint.lua:362: Invalid 'col': out of range
--
-- Ursache: vim.lsp.inlay_hint speichert Hints pro Client (client_hints), fuehrt
-- die Buffer-Version (bufstate.version) aber nur einmal pro Buffer. Sind
-- mehrere Server an einen Buffer attached (bei uns z.B. ts_ls + angularls),
-- passiert Folgendes:
--
--   1. Client A antwortet fuer Version V; Hints werden in Byte-Spalten des
--      damaligen Zeileninhalts umgerechnet und gespeichert.
--   2. Der Buffer schrumpft (ci{) -> Version V+1. Der Versions-Check in
--      inlay_hint.lua:323 verhindert das Rendern. Noch alles gut.
--   3. Client B antwortet fuer V+1 und setzt bufstate.version auf V+1.
--      Damit gilt der Check wieder als erfuellt - aber die Hints von Client A
--      liegen unveraendert auf ihren alten, zu grossen Spalten.
--   4. Der Decoration-Provider ruft nvim_buf_set_extmark mit einer Spalte
--      hinter dem Zeilenende auf -> "Invalid 'col': out of range".
--
-- Invariante, die hier durchgesetzt wird: ein gespeicherter Hint zeigt nie
-- hinter das Ende seiner Zeile. Der Handler laeuft synchron direkt nach der
-- Antwort und damit vor dem naechsten Redraw, schliesst das Fenster also
-- vollstaendig. Die korrekten Positionen liefert die Anfrage nach, die durch
-- dieselbe Aenderung ohnehin schon fuer jeden Client unterwegs ist.
--
-- Sobald Neovim die Version pro Client fuehrt, kann diese Datei ersatzlos
-- entfallen; tests/unit/inlay_hint_spec.lua schlaegt dann weiterhin nicht an.

local M = {}

--- Zieht alle gespeicherten Inlay-Hints eines Buffers auf gueltige Spalten.
--- @param bufnr integer
--- @return integer korrigierte Hints
function M.clamp(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_loaded(bufnr) then
    return 0
  end

  local hints = vim.lsp.inlay_hint.get({ bufnr = bufnr })
  if #hints == 0 then
    return 0
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local lengths = {} --- @type table<integer, integer>
  local fixed = 0

  for _, entry in ipairs(hints) do
    local pos = entry.inlay_hint.position
    if pos.line < line_count then
      local len = lengths[pos.line]
      if not len then
        len = #(vim.api.nvim_buf_get_lines(bufnr, pos.line, pos.line + 1, false)[1] or "")
        lengths[pos.line] = len
      end
      if pos.character > len then
        pos.character = len
        fixed = fixed + 1
      end
    end
  end

  return fixed
end

--- Haengt sich hinter den eingebauten textDocument/inlayHint-Handler.
function M.setup()
  if M._installed then
    return
  end
  M._installed = true

  local default = vim.lsp.handlers["textDocument/inlayHint"]
  vim.lsp.handlers["textDocument/inlayHint"] = function(err, result, ctx, config)
    local ret = default(err, result, ctx, config)
    M.clamp(ctx and ctx.bufnr)
    return ret
  end
end

M.setup()

return M
