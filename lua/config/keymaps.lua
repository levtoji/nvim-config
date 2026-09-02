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
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>xl", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
