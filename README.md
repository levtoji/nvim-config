# nvim-config

Minimale, aber IDE-taugliche Neovim-Config für Go-, .NET/C#- und
TypeScript/Angular-Entwicklung (LSP, Debugging, Test-Runner,
Git-Integration, Fuzzy-Finder).

## Stack

- **Plugin-Manager:** [lazy.nvim](https://github.com/folke/lazy.nvim)
- **LSP:** `gopls` (Go), [roslyn.nvim](https://github.com/seblyng/roslyn.nvim) (C#, Microsofts offizieller Roslyn-LSP statt OmniSharp), `ts_ls` + `angularls` (TypeScript/Angular), `eslint` (Lint-Diagnostics inline). Inlay Hints sind für alle Server aktiv (`<leader>th` zum Umschalten).
- **Completion:** [blink.cmp](https://github.com/Saghen/blink.cmp) (Preset `super-tab`: `<Tab>` wählt aus/bestätigt)
- **Formatting:** [conform.nvim](https://github.com/stevearc/conform.nvim) – Prettier on-save für ts/html/scss/css/json/yaml/markdown (Go bleibt bei `gofmt` via Autocmd)
- **Debugging:** [nvim-dap](https://github.com/mfussenegger/nvim-dap) + nvim-dap-ui, `delve` (Go), `netcoredbg` (.NET)
- **Tests:** [neotest](https://github.com/nvim-neotest/neotest) mit neotest-golang und neotest-dotnet
- **Datei-/Git-Explorer:** neo-tree, gitsigns, neogit
- **Finder:** fzf-lua
- **Projekt-Switcher:** [neovim-project](https://github.com/coffebar/neovim-project) (`<leader>fp` Discover, `<leader>fP` Recent) – entdeckt Repos per Glob unter `~/RiderProjects`, `~/WebstormProjects`, `~/.config`, wechselt cwd und stellt die letzte Session wieder her
- **Terminal:** [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) (`<C-\>`) – schwebendes Terminal für nx/ng-Kommandos etc.
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
(Versionen sind über `lazy-lock.json` gepinnt). `delve`, `netcoredbg`,
`roslyn-language-server`, `typescript-language-server`,
`angular-language-server` und `eslint-lsp` werden zusätzlich automatisch
über Mason nachgezogen (siehe `lua/plugins/lsp.lua`, mason.nvim-Config).

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
