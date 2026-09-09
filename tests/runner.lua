-- Test-Runner. Wird von tests/run.sh aufgerufen:
--   nvim --headless -l tests/runner.lua unit
--   nvim --headless -u init.lua -l tests/runner.lua e2e

local root = vim.env.NVIM_CONFIG_ROOT or vim.fn.getcwd()

-- Config-Verzeichnis in den runtimepath, damit require("config.*") und
-- require("plugins.*") auch ohne geladene User-Config aufloesen.
vim.opt.rtp:prepend(root)

local T = dofile(root .. "/tests/framework.lua")

-- Globals fuer knappe Specs
_G.T = T
_G.describe = T.describe
_G.it = T.it
_G.eq = T.eq
_G.truthy = T.truthy
_G.falsy = T.falsy
_G.contains = T.contains
_G.no_error = T.no_error
_G.CONFIG_ROOT = root

local suites = {}
for i = 1, #_G.arg do
  table.insert(suites, _G.arg[i])
end
if #suites == 0 then
  suites = { "unit" }
end

for _, suite in ipairs(suites) do
  local dir = root .. "/tests/" .. suite
  local files = vim.fn.glob(dir .. "/*_spec.lua", false, true)
  table.sort(files)
  if #files == 0 then
    io.write("Keine Specs in ", dir, "\n")
  end
  for _, file in ipairs(files) do
    io.write("\n", vim.fn.fnamemodify(file, ":t"), "\n")
    local chunk, load_err = loadfile(file)
    if not chunk then
      T.failed = T.failed + 1
      table.insert(T.failures, { name = file, err = load_err })
      io.write("  ✗ Datei laedt nicht\n")
    else
      local ok, err = pcall(chunk)
      if not ok then
        T.failed = T.failed + 1
        table.insert(T.failures, { name = file, err = err })
        io.write("  ✗ Spec brach ab\n")
      end
    end
  end
end

local success = T.report()
vim.cmd("cq " .. (success and 0 or 1))
