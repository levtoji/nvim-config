return {
  "saghen/blink.cmp",
  version = "1.*",
  -- Lädt die Rust-Fuzzy-Matcher-Engine erst beim ersten Insert statt beim Start.
  event = "InsertEnter",
  -- Rider's Live Templates (foreach, psvm etc.): friendly-snippets liegt nur auf
  -- dem Runtimepath, blink.cmp lädt es automatisch (sources.providers.snippets
  -- unten macht das nur explizit, da friendly_snippets sonst per Default an ist).
  dependencies = { "rafamadriz/friendly-snippets", "milanglacier/minuet-ai.nvim" },
  opts = {
    -- "default"-Preset mappt weder <Tab> noch <CR> auf Accept, nur <Up>/<Down>
    -- navigieren. super-tab: <Tab> wählt das markierte Item aus/bestätigt es.
    keymap = { preset = "super-tab" },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      documentation = { auto_show = true },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "minuet" },
      providers = {
        snippets = { opts = { friendly_snippets = true } },
        -- Lokale FIM-Vervollständigung über Ollama, siehe plugins/ai-completion.lua
        minuet = {
          name = "minuet",
          module = "minuet.blink",
          async = true,
          timeout_ms = 3000,
          score_offset = 50,
        },
      },
    },
    signature = { enabled = true },
  },
}
