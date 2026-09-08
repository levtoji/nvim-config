-- Wurzelverzeichnisse, unter denen nach Repos gesucht wird (siehe ~/.claude/CLAUDE.md "Big 4")
local project_roots = {
  vim.fn.expand("~/RiderProjects"),
  vim.fn.expand("~/WebstormProjects"),
}

-- Cmd+O-Äquivalent: findet alle Git-Repos unter project_roots (auch verschachtelt),
-- wechselt beim Auswählen cwd dorthin und öffnet neo-tree an der neuen Wurzel.
local function find_project()
  local fd_cmd = "fd -H -t d -d 5 -E node_modules -E bin -E obj '^\\.git$' "
    .. table.concat(vim.tbl_map(vim.fn.shellescape, project_roots), " ")
    .. " | xargs -n1 dirname | sort -u"

  require("fzf-lua").fzf_exec(fd_cmd, {
    prompt = "Projects> ",
    actions = {
      ["default"] = function(selected)
        local dir = selected[1]
        vim.cmd.cd(dir)
        vim.cmd("Neotree action=focus dir=" .. vim.fn.fnameescape(dir))
      end,
    },
  })
end

return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {},
  keys = {
    { "<leader>ff", function() require("fzf-lua").files() end, desc = "Find Files" },
    { "<leader>fg", function() require("fzf-lua").live_grep() end, desc = "Live Grep" },
    { "<leader>fb", function() require("fzf-lua").buffers() end, desc = "Find Buffers" },
    { "<leader>fr", function() require("fzf-lua").oldfiles() end, desc = "Recent Files" },
    { "<leader>fs", function() require("fzf-lua").lsp_document_symbols() end, desc = "Document Symbols" },
    { "<leader>fw", function() require("fzf-lua").lsp_workspace_symbols() end, desc = "Workspace Symbols" },
    { "<leader>fd", function() require("fzf-lua").diagnostics_document() end, desc = "Diagnostics" },
    { "<leader>fp", find_project, desc = "Find Project (repo wechseln)" },
  },
}
