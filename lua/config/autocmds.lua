local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = "go",
  desc = "Go verwendet Tabs statt Spaces (gofmt-Konvention)",
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  pattern = "*.go",
  desc = "Go-Dateien beim Speichern formatieren (gopls/gofumpt)",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
