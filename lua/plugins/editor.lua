-- gc/gcc/gc-Textobjekt kommen seit Neovim 0.10 nativ aus dem Core
-- (vim._comment, siehe :h gc-default) - kein Comment.nvim mehr nötig.
return {
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },
}
