local configs = require("lspconfig.configs")
local util = require("lspconfig.util")

if not configs.vyper_lsp then
  configs.vyper_lsp = {
    default_config = {
      cmd = { vim.fn.exepath("vyper-lsp") },
      filetypes = { "vyper" },
      root_dir = util.root_pattern("pyproject.toml", ".git"),
      single_file_support = true,
    },
  }
end

require("lspconfig").vyper_lsp.setup({})
