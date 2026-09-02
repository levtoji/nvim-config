local parsers = {
  "go",
  "gomod",
  "gowork",
  "gosum",
  "c_sharp",
  "lua",
  "vim",
  "vimdoc",
  "json",
  "yaml",
  "markdown",
  "markdown_inline",
  "bash",
  "query",
}

-- Vim-Filetypes, für die Highlighting aktiviert werden soll.
-- Neovim kennt "cs" nicht automatisch als "c_sharp" - muss explizit registriert werden.
local filetypes = {
  "go",
  "gomod",
  "gowork",
  "gosum",
  "cs",
  "lua",
  "vim",
  "help",
  "json",
  "yaml",
  "markdown",
  "bash",
  "query",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    vim.treesitter.language.register("c_sharp", "cs")

    require("nvim-treesitter").install(parsers)

    vim.api.nvim_create_autocmd("FileType", {
      pattern = filetypes,
      callback = function()
        vim.treesitter.start()
        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo.foldenable = false
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
