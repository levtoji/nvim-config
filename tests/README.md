# Tests

Regressionstests für diese Neovim-Config. Kein plenary/busted als Abhängigkeit –
die Tests laufen auch in einer frisch geklonten Config, in der lazy.nvim noch
nichts installiert hat.

```sh
tests/run.sh          # alles
tests/run.sh unit     # nur Komponententests (isoliert, ~2 s)
tests/run.sh e2e      # nur End-to-End (echte Config inkl. Plugins)
```

Exit-Code 0 = alles grün.

## Aufbau

| Datei | Zweck |
|---|---|
| `framework.lua` | Mini-Framework: `describe`/`it`, `eq`/`truthy`/`falsy`/`contains`/`no_error` |
| `runner.lua` | Lädt eine Suite und meldet das Ergebnis über den Exit-Code |
| `helpers/lsp_stub.lua` | In-Process-LSP-Server. Antwortet erst, wenn der Test es sagt – damit lassen sich Races zwischen mehreren Clients deterministisch nachstellen |

### `unit/` – eine Komponente pro Datei, ohne Plugins

Läuft mit `nvim -u NONE`, kennt also nur `lua/config/` und `lua/plugins/` als
Quelltext.

| Spec | Deckt ab |
|---|---|
| `options_spec.lua` | `config/options.lua`: Leader, Editor-Optionen, Indent-Defaults, `listchars` |
| `keymaps_spec.lua` | `config/keymaps.lua`: jedes Mapping mit Modus und Beschreibung |
| `autocmds_spec.lua` | `config/autocmds.lua`: Gruppe, Yank-Highlight, Go-Tabs (Effekt, nicht nur Existenz), Format-on-Save |
| `lazy_spec.lua` | `config/lazy.lua` + `lazy-lock.json` (gültiges JSON, jeder Eintrag mit Commit) |
| `plugin_specs_spec.lua` | **alle** `lua/plugins/*.lua` generisch: lädt fehlerfrei, gültige lazy-Spec, nur bekannte lazy-Felder (fängt Tippfehler, die lazy sonst still ignoriert), `owner/repo`-Format, jedes Keymap mit `desc`, keine doppelten Plugins, keine Kollision mit den globalen Keymaps |
| `lsp_spec.lua` | `plugins/lsp.lua`: Server, Mason-Tools, Lazy-Loading, Inlay-Hint-Aktivierung |
| `inlay_hint_spec.lua` | Regression zum `Invalid 'col': out of range`-Absturz (s.u.) |

Mehrere Specs prüfen zusätzlich, ob die verwendeten `vim.*`-APIs in der
laufenden Neovim-Version noch existieren. Das fängt Deprecations nach einem
`brew upgrade neovim`, bevor sie im Alltag als Laufzeitfehler auftauchen.

### `e2e/` – echte Config

Läuft mit `nvim -u init.lua`, also inklusive lazy.nvim und aller Plugins.

| Spec | Deckt ab |
|---|---|
| `startup_spec.lua` | Start ohne Fehler, alle Module geladen, alle Plugins installiert und fehlerfrei, Optionen aktiv, Colorscheme gesetzt |
| `editing_spec.lua` | Echte Datei öffnen, echtes `ci{` per `feedkeys`, zwei LSP-Server antworten versetzt, danach `redraw!` – prüft, dass kein Decoration-Provider-Fehler entsteht |

## Der Inlay-Hint-Bug

`inlay_hint_spec.lua` und der `ci{`-Test in `editing_spec.lua` schlagen fehl,
sobald `lua/config/lsp_inlay_hint_fix.lua` deaktiviert wird. Die Ursache ist im
Fix-Modul dokumentiert; kurz: Neovim führt die Buffer-Version für Inlay Hints
nur einmal pro Buffer, speichert die Hints aber pro Client. Antwortet ein
zweiter Server für eine neuere Version, gelten die veralteten Hints des ersten
wieder als gültig und zeigen hinter das Zeilenende.

## Neuen Test ergänzen

Datei nach `tests/unit/<name>_spec.lua` bzw. `tests/e2e/` legen, `_spec.lua` als
Endung. Der Runner stellt `describe`, `it`, `eq`, `truthy`, `falsy`, `contains`,
`no_error`, `T` und `CONFIG_ROOT` als Globals bereit.
