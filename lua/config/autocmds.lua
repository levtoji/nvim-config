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

-- Web-Stack verwendet 2 statt der globalen 4 Spaces (Prettier-/Angular-
-- Konvention, siehe die .editorconfig von agent-portal/developer-portal).
-- Ohne das rechnet z.B. der Treesitter-indentexpr beim Einfügen einer neuen
-- Zeile (o/O) mit shiftwidth=4 und landet eine Stufe zu weit rechts, sobald
-- die Datei selbst 2-space-eingerückt ist - passiert in jedem Projekt ohne
-- eigene .editorconfig (z.B. ~/NodeProjects, ~/Spielereien).
--
-- Hat ein Projekt eine eigene .editorconfig, hat die immer Vorrang: der
-- eingebaute editorconfig-Support (:h editorconfig, standardmäßig an) läuft
-- über denselben FileType-Zeitpunkt und würde sonst je nach Autocmd-
-- Reihenfolge von diesem Default wieder überschrieben werden.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "jsonc",
    "yaml",
    "html",
    "css",
    "scss",
  },
  desc = "Web-Stack verwendet 2 Spaces (Prettier-/Angular-Konvention), außer ein Projekt sagt per .editorconfig etwas anderes",
  callback = function(args)
    local dir = vim.fn.expand("%:p:h")
    if #vim.fs.find(".editorconfig", { path = dir, upward = true }) > 0 then
      return
    end
    vim.bo[args.buf].shiftwidth = 2
    vim.bo[args.buf].tabstop = 2
  end,
})
