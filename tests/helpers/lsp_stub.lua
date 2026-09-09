-- In-Process-LSP-Server-Stub.
--
-- Neovim erlaubt als `cmd` eine Lua-Funktion statt eines Prozesses. Damit
-- laufen LSP-Tests ohne echten Sprachserver und - wichtiger - mit voller
-- Kontrolle darueber, WANN eine Antwort eintrifft. Genau diese Kontrolle
-- braucht man, um Race Conditions zwischen mehreren Clients zu reproduzieren.

local M = {}

--- @class TestLspServer
--- @field pending fun(err: any, result: any)[] noch nicht beantwortete Requests
--- @field name string
--- @field client_id integer?

--- @param name string
--- @param capabilities table? zusaetzliche Server-Capabilities
--- @return TestLspServer
function M.new(name, capabilities)
  local srv = { name = name, pending = {} }

  srv.cmd = function(_)
    local closing = false
    return {
      request = function(method, _, callback)
        if method == "initialize" then
          callback(nil, {
            capabilities = vim.tbl_extend("force", {
              textDocumentSync = 1,
              inlayHintProvider = true,
            }, capabilities or {}),
          })
        elseif method == "shutdown" then
          callback(nil, nil)
        else
          -- Alles andere wird geparkt, bis der Test es explizit beantwortet.
          table.insert(srv.pending, callback)
        end
        return true, 1
      end,
      notify = function()
        return true
      end,
      is_closing = function()
        return closing
      end,
      terminate = function()
        closing = true
      end,
    }
  end

  --- Beantwortet alle offenen Requests mit `result`.
  --- @param result any
  function srv.reply(result)
    local callbacks = srv.pending
    srv.pending = {}
    for _, cb in ipairs(callbacks) do
      cb(nil, result)
    end
    M.settle()
  end

  --- Verwirft alle offenen Requests, ohne zu antworten (langsamer Server).
  function srv.drop()
    srv.pending = {}
  end

  --- @param bufnr integer
  function srv.attach(bufnr)
    srv.client_id = vim.lsp.start({ name = srv.name, cmd = srv.cmd }, { bufnr = bufnr })
    return srv.client_id
  end

  return srv
end

--- Laesst die Event-Loop laufen, damit geplante Callbacks/Autocmds durchlaufen.
--- @param ms integer?
function M.settle(ms)
  vim.wait(ms or 300, function()
    return false
  end)
end

--- @param bufnr integer
function M.stop_all(bufnr)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    client:stop(true)
  end
  M.settle(50)
end

return M
