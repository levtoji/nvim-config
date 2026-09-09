-- Komponente: lua/plugins/lsp.lua (Struktur; das Laufzeitverhalten deckt
-- tests/e2e/lsp_runtime_spec.lua ab, weil config() blink.cmp braucht)

local spec = dofile(CONFIG_ROOT .. "/lua/plugins/lsp.lua")
local src = table.concat(vim.fn.readfile(CONFIG_ROOT .. "/lua/plugins/lsp.lua"), "\n")

local function find(name)
  for _, p in ipairs(spec) do
    if p[1] == name then
      return p
    end
  end
end

describe("plugins.lsp", function()
  it("deklariert mason, lspconfig und roslyn", function()
    truthy(find("williamboman/mason.nvim"), "mason.nvim fehlt")
    truthy(find("neovim/nvim-lspconfig"), "nvim-lspconfig fehlt")
    truthy(find("seblyng/roslyn.nvim"), "roslyn.nvim fehlt")
  end)

  it("laedt lspconfig erst beim Oeffnen einer Datei", function()
    eq(find("neovim/nvim-lspconfig").event, { "BufReadPre", "BufNewFile" })
  end)

  it("zieht mason und blink.cmp als Dependencies mit", function()
    local deps = find("neovim/nvim-lspconfig").dependencies
    contains(deps, "williamboman/mason.nvim")
    contains(deps, "saghen/blink.cmp")
  end)

  it("laedt roslyn nur fuer C#", function()
    eq(find("seblyng/roslyn.nvim").ft, "cs")
  end)

  it("installiert die noetigen Server und Debug-Adapter ueber mason", function()
    for _, tool in ipairs({
      "delve",
      "netcoredbg",
      "roslyn-language-server",
      "typescript-language-server",
      "angular-language-server",
      "eslint-lsp",
    }) do
      truthy(src:find(tool, 1, true), ("mason-tool-installer kennt '%s' nicht"):format(tool))
    end
  end)

  it("aktiviert die konfigurierten Sprachserver", function()
    for _, server in ipairs({ "gopls", "ts_ls", "angularls", "eslint" }) do
      truthy(
        src:find('vim.lsp.enable("' .. server .. '")', 1, true)
          or src:find('"' .. server .. '"', 1, true),
        ("Server '%s' wird nicht aktiviert"):format(server)
      )
    end
  end)

  it("schaltet Inlay Hints nur fuer Server ein, die sie koennen", function()
    truthy(src:find('supports_method("textDocument/inlayHint")', 1, true))
    truthy(src:find("vim.lsp.inlay_hint.enable(true", 1, true))
  end)

  it("hat einen Toggle fuer Inlay Hints", function()
    truthy(src:find("<leader>th", 1, true))
    truthy(src:find("vim.lsp.inlay_hint.is_enabled", 1, true))
  end)

  it("nutzt nur Neovim-APIs, die es in dieser Version noch gibt", function()
    for _, path in ipairs({
      "vim.lsp.config",
      "vim.lsp.enable",
      "vim.lsp.buf.definition",
      "vim.lsp.buf.references",
      "vim.lsp.buf.implementation",
      "vim.lsp.buf.type_definition",
      "vim.lsp.buf.hover",
      "vim.lsp.buf.code_action",
      "vim.lsp.buf.format",
      "vim.lsp.get_client_by_id",
    }) do
      truthy(T.api_exists(path), path .. " existiert nicht mehr")
    end
  end)
end)
