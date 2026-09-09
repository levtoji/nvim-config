-- Komponente: lua/config/keymaps.lua

-- nvim_get_keymap liefert lhs in eigener Notation zurueck (<C-h> -> <C-H>,
-- < -> <lt>). Beide Seiten auf Rohbytes normalisieren statt Strings vergleichen.
local function normalize(lhs)
  return vim.api.nvim_replace_termcodes(lhs, true, true, true)
end

local function mapping(mode, lhs)
  local target = normalize(lhs)
  for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
    if normalize(m.lhs) == target then
      return m
    end
  end
  return nil
end

describe("config.keymaps", function()
  it("laedt fehlerfrei", function()
    no_error(function()
      require("config.options") -- setzt mapleader, muss vorher passieren
      require("config.keymaps")
    end)
  end)

  local expected = {
    { "n", "<Esc>", "Clear search highlight" },
    { "n", "<C-h>", "Focus window left" },
    { "n", "<C-l>", "Focus window right" },
    { "n", "<C-j>", "Focus window down" },
    { "n", "<C-k>", "Focus window up" },
    { "n", "<leader>w", "Save file" },
    { "n", "<leader>q", "Quit" },
    { "v", "<", "Indent left, keep selection" },
    { "v", ">", "Indent right, keep selection" },
    { "n", "[d", "Previous diagnostic" },
    { "n", "]d", "Next diagnostic" },
    { "n", "<leader>xl", "Diagnostics to loclist" },
    { "n", "<A-j>", "Move line down" },
    { "n", "<A-k>", "Move line up" },
    { "v", "<A-j>", "Move selection down" },
    { "v", "<A-k>", "Move selection up" },
  }

  for _, spec in ipairs(expected) do
    local mode, lhs, desc = spec[1], spec[2], spec[3]
    it(("mappt %s %s"):format(mode, lhs), function()
      local m = mapping(mode, lhs)
      truthy(m, ("Mapping %s %s fehlt"):format(mode, lhs))
      eq(m.desc, desc, ("Beschreibung von %s %s"):format(mode, lhs))
    end)
  end

  it("nutzt nur Neovim-APIs, die es in dieser Version noch gibt", function()
    -- Faengt Deprecations, die nach einem nvim-Upgrade zu Laufzeitfehlern werden.
    for _, path in ipairs({
      "vim.diagnostic.goto_prev",
      "vim.diagnostic.goto_next",
      "vim.diagnostic.setloclist",
    }) do
      truthy(T.api_exists(path), path .. " existiert nicht mehr")
    end
  end)
end)
