-- Rider's Rename-Dialog zeigt live alle betroffenen Stellen während du tippst -
-- inc-rename.nvim macht das über :IncRename statt blind vim.lsp.buf.rename.
return {
  "smjonas/inc-rename.nvim",
  cmd = "IncRename",
  opts = {},
}
