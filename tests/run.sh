#!/usr/bin/env bash
# Testlauf fuer die Neovim-Config.
#
#   tests/run.sh          alle Suites (unit + e2e)
#   tests/run.sh unit     nur Unit-/Komponententests (ohne Plugins, schnell)
#   tests/run.sh e2e      nur End-to-End (echte Config inkl. lazy.nvim)
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export NVIM_CONFIG_ROOT="$ROOT"

suites=("$@")
if [ ${#suites[@]} -eq 0 ]; then
  suites=(unit e2e)
fi

status=0
for suite in "${suites[@]}"; do
  echo "════════════════════════════════════════════"
  echo " Suite: $suite"
  echo "════════════════════════════════════════════"
  case "$suite" in
    unit)
      # -u NONE: isoliert, ohne User-Config und ohne Plugins
      nvim --headless -u NONE -i NONE -l "$ROOT/tests/runner.lua" unit || status=1
      ;;
    e2e)
      # Echte Config inklusive lazy.nvim und allen Plugins
      nvim --headless -u "$ROOT/init.lua" -i NONE -l "$ROOT/tests/runner.lua" e2e || status=1
      ;;
    *)
      echo "Unbekannte Suite: $suite" >&2
      status=1
      ;;
  esac
  echo
done

exit "$status"
