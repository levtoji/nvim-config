-- Wurzelverzeichnisse, unter denen nach Repos gesucht wird (siehe ~/.claude/CLAUDE.md "Big 4")
local project_roots = {
  vim.fn.expand("~/RiderProjects"),
  vim.fn.expand("~/WebstormProjects"),
}

-- Cmd+O-Äquivalent: findet alle Git-Repos unter roots (auch verschachtelt),
-- wechselt beim Auswählen cwd dorthin und öffnet neo-tree an der neuen Wurzel.
local function find_repos_under(roots)
  local fd_cmd = "fd -H -t d -d 5 -E node_modules -E bin -E obj '^\\.git$' "
    .. table.concat(vim.tbl_map(vim.fn.shellescape, roots), " ")
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

local function find_project()
  find_repos_under(project_roots)
end

-- Wie find_project, aber der Startordner wird abgefragt (mit Tab-Completion) -
-- für Repos außerhalb der festen project_roots.
local function find_project_in()
  local root = vim.fn.input("Root: ", vim.fn.expand("~") .. "/", "dir")
  if root == "" then
    return
  end
  find_repos_under({ vim.fn.expand(root) })
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
    { "<leader>fP", find_project_in, desc = "Find Project in... (anderer Ordner)" },
  },
}
