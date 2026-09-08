return {
  "saghen/blink.cmp",
  version = "1.*",
  -- Lädt die Rust-Fuzzy-Matcher-Engine erst beim ersten Insert statt beim Start.
  event = "InsertEnter",
  opts = {
    -- "default"-Preset mappt weder <Tab> noch <CR> auf Accept, nur <Up>/<Down>
    -- navigieren. super-tab: <Tab> wählt das markierte Item aus/bestätigt es.
    keymap = { preset = "super-tab" },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      documentation = { auto_show = true },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    signature = { enabled = true },
  },
}
