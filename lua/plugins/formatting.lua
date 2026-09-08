-- Format-on-save für Web-Dateitypen via Prettier (nutzt automatisch das
-- projekt-lokale node_modules/.bin/prettier, z.B. in agent-portal).
-- Go bleibt beim bestehenden gofmt-Autocmd in autocmds.lua.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  opts = {
    formatters_by_ft = {
      typescript = { "prettier" },
      typescriptreact = { "prettier" },
      javascript = { "prettier" },
      javascriptreact = { "prettier" },
      html = { "prettier" },
      scss = { "prettier" },
      css = { "prettier" },
      json = { "prettier" },
      yaml = { "prettier" },
      markdown = { "prettier" },
    },
    format_on_save = {
      timeout_ms = 2000,
      lsp_fallback = true,
    },
  },
}
