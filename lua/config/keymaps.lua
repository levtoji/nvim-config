local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Fenster-Navigation
map("n", "<C-h>", "<C-w><C-h>", { desc = "Focus window left" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Focus window right" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Focus window down" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Focus window up" })

map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

-- Visual: Einrücken ohne Selektion zu verlieren
map("v", "<", "<gv", { desc = "Indent left, keep selection" })
map("v", ">", ">gv", { desc = "Indent right, keep selection" })

-- Diagnostics
-- vim.diagnostic.goto_prev/goto_next sind seit Neovim 0.12 deprecated
-- (Removal in 0.13) - vim.diagnostic.jump() ist der Ersatz. on_jump statt
-- des ebenfalls deprecateten opts.float repliziert das bisherige Verhalten
-- (Float mit der Diagnose beim Sprung), s. vim.diagnostic.goto_next-Quelle.
local function open_diagnostic_float(_, bufnr)
  vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor" })
end
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, on_jump = open_diagnostic_float })
end, { desc = "Previous diagnostic" })
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, on_jump = open_diagnostic_float })
end, { desc = "Next diagnostic" })
map("n", "<leader>xl", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- Zeilen verschieben (Rider: Alt+Shift+Up/Down). <A-Up>/<A-Down> werden von
-- vielen Terminals nicht zuverlässig durchgereicht, daher <A-j>/<A-k>.
map("n", "<A-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
