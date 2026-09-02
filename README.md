# nvim-config

Minimale, aber IDE-taugliche Neovim-Config für Go- und .NET/C#-Entwicklung
(LSP, Debugging, Test-Runner, Git-Integration, Fuzzy-Finder).

## Stack

- **Plugin-Manager:** [lazy.nvim](https://github.com/folke/lazy.nvim)
- **LSP:** `gopls` (Go), [roslyn.nvim](https://github.com/seblyng/roslyn.nvim) (C#, Microsofts offizieller Roslyn-LSP statt OmniSharp)
- **Completion:** [blink.cmp](https://github.com/Saghen/blink.cmp)
- **Debugging:** [nvim-dap](https://github.com/mfussenegger/nvim-dap) + nvim-dap-ui, `delve` (Go), `netcoredbg` (.NET)
- **Tests:** [neotest](https://github.com/nvim-neotest/neotest) mit neotest-golang und neotest-dotnet
- **Datei-/Git-Explorer:** neo-tree, gitsigns, neogit
- **Finder:** fzf-lua
- **Sonstiges:** treesitter, lualine, which-key, indent-blankline, Comment/autopairs/surround

Keybindings sind Standard-Vim-Motions; Debug-Keys orientieren sich an Rider (`F9` Continue, `F8` Step Over, `F7` Step Into, `Shift+F8` Step Out).

## Installation auf einem neuen Rechner (macOS)

```bash
# Neovim + Treesitter-CLI (wird von nvim-treesitter zum Kompilieren der Parser gebraucht)
brew install neovim tree-sitter-cli

# Optional: Nerd Font für Icons in neo-tree/lualine
brew install --cask font-jetbrains-mono-nerd-font

# Sprach-Tooling, das die Config voraussetzt
brew install go ripgrep fd fzf
go install golang.org/x/tools/gopls@latest
# .NET SDK je nach Bedarf: https://dotnet.microsoft.com/download

# Config klonen
git clone git@github.com:levtoji/nvim-config.git ~/.config/nvim
```

Beim ersten Start von `nvim` installiert lazy.nvim automatisch alle Plugins
(Versionen sind über `lazy-lock.json` gepinnt). `delve`, `netcoredbg` und
`roslyn-language-server` werden zusätzlich automatisch über Mason
nachgezogen (siehe `lua/plugins/dap.lua`).

Falls der erste automatische Mason-Install mal nicht durchläuft, manuell nachholen:

```vim
:MasonToolsInstallSync
```

## Struktur

```
init.lua              -- Bootstrap, lädt config/ und lazy.nvim
lua/config/
  options.lua          -- Editor-Optionen
  keymaps.lua           -- allgemeine Keymaps
  autocmds.lua           -- Autocommands (u.a. Go-Formatierung on save)
  lazy.lua                -- lazy.nvim-Bootstrap
lua/plugins/
  *.lua                    -- ein Modul pro Plugin/Bereich
```
