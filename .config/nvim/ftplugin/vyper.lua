local configs = require("lspconfig.configs")
local util = require("lspconfig.util")

if not configs.vy_ls then
  configs.vy_ls = {
    default_config = {
      cmd = { "vyper-language-server" },
      filetypes = { "vyper" },
      root_dir = util.root_pattern("pyproject.toml", ".git"),
      single_file_support = true,
      on_new_config = function(new_config, root_dir)
        local venv = root_dir .. "/.venv/bin/vyper-language-server"
        if vim.fn.filereadable(venv) == 1 then
          new_config.cmd = { venv }
        end
      end,
    },
  }
end

require("lspconfig").vy_ls.setup({})
