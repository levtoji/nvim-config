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
- **Datei-/Git-Explorer:** Snacks Explorer (`<leader>e`, ersetzt netrw), gitsigns (`<leader>tb` Inline-Blame), neogit, [diffview.nvim](https://github.com/sindrets/diffview.nvim) (`<leader>gd` Projekt-Diff, `<leader>gh` File History), Lazygit (`<leader>gl`) für Rebases/Konflikte
- **Finder:** Snacks Picker (`<leader>fc` Command Palette, `<leader>fk` Keymap-Suche)
- **[snacks.nvim](https://github.com/folke/snacks.nvim):** Zen Mode (`<leader>z`), Notifier, Dashboard on-demand (`<leader>H`, nicht automatisch beim Start - das macht neovim-project's Session-Autoload), Indent Guides, Finder/Picker (`<leader>f*`), File Explorer (`<leader>e`), Terminal (`<C-\>`), Lazygit (`<leader>gl`), GitHub Issues/PRs (`<leader>gi`/`<leader>gI`/`<leader>gp`/`<leader>gP`, braucht `gh` CLI), Rename-mit-Import-Update (`<leader>cR`, auch über den Explorer's Rename-Aktion), Reference-Highlighting + Sprung (`]]`/`[[`), Git-Browse (`<leader>gB`), Fokus-Dimming (`<leader>uD`), Scratch-Buffer (`<leader>.`/`<leader>S`), Buffer schließen ohne Layout-Bruch (`<leader>bd`/`<leader>bo`), Smooth Scroll, Bigfile-Schutz, kombinierte Statuscolumn
- **Projekt-Switcher:** [neovim-project](https://github.com/coffebar/neovim-project) (`<leader>fp` Discover, `<leader>fP` Recent) – entdeckt Repos per Glob unter `~/RiderProjects`, `~/WebstormProjects`, `~/.config`, wechselt cwd und stellt die letzte Session wieder her
- **Terminal:** Snacks Terminal (`<C-\>`) – schwebendes Terminal für nx/ng-Kommandos etc.
- **Rider-Parität:**
  - [harpoon](https://github.com/ThePrimeagen/harpoon) (`<leader>ma` Add, `<leader>mm` Menü, `<leader>1-4` Sprung) – bis zu 4 Dateien anpinnen
  - [trouble.nvim](https://github.com/folke/trouble.nvim) (`<leader>xx` Diagnostics, `<leader>cs` Symbols, `<leader>cl` LSP) – Problems-Panel
  - [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) (`af`/`if`, `ac`/`ic`, `ap`/`ip`, `]m`/`[m`) + [inc-select.nvim](https://github.com/maxischmaxi/inc-select.nvim) (`<C-Space>` wiederholt drücken zum Erweitern, `<M-Space>` zum Verkleinern) – Smart Selection
  - [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) – Live-Template-artige Snippets über blink.cmp
  - [inc-rename.nvim](https://github.com/smjonas/inc-rename.nvim) (`<leader>rn`) – Rename mit Live-Vorschau
  - [kulala.nvim](https://github.com/mistweaverco/kulala.nvim) (`.http`-Dateien, `<leader>Rs`) – HTTP-Client für die *-bff-Services
  - `<A-j>`/`<A-k>` – Zeile(n) verschieben
- **Sonstiges:** treesitter, lualine, which-key, autopairs/surround (Kommentare `gc`/`gcc` kommen nativ aus Neovim-Core)

Keybindings sind Standard-Vim-Motions; Debug-Keys orientieren sich an Rider (`F9` Continue, `F8` Step Over, `F7` Step Into, `Shift+F8` Step Out).

## Installation auf einem neuen Rechner (macOS)

```bash
# Neovim + Treesitter-CLI (wird von nvim-treesitter zum Kompilieren der Parser gebraucht)
brew install neovim tree-sitter-cli

# Optional: Nerd Font für Icons in Snacks Explorer/lualine
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
  autocmds.lua           -- Autocommands (u.a. Go-Formatierung on save, 2-Space-Default für Web-Stack)
  lsp_inlay_hint_fix.lua   -- Workaround für einen Inlay-Hint-Bug in nvim 0.12
  lazy.lua                  -- lazy.nvim-Bootstrap
lua/plugins/
  *.lua                      -- ein Modul pro Plugin/Bereich
tests/
  run.sh                      -- Testlauf, siehe tests/README.md
```

## Tests

```sh
tests/run.sh          # alles
tests/run.sh unit     # nur Komponententests (isoliert, ~2 s)
tests/run.sh e2e      # nur End-to-End gegen die echte Config
```

Jede Komponente unter `lua/config/` und `lua/plugins/` hat einen eigenen Spec,
dazu kommen E2E-Tests, die die echte Config starten und echtes Editieren
durchspielen. Details in [`tests/README.md`](tests/README.md).

Sinnvoll nach jedem `brew upgrade neovim` und vor jedem Commit an der Config:
die Specs prüfen unter anderem, ob alle verwendeten `vim.*`-APIs in der
laufenden Neovim-Version noch existieren.
