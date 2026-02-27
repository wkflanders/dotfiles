local customizations = {
  { rule = "style/*", severity = "off", fixable = true },
  { rule = "format/*", severity = "off", fixable = true },
  { rule = "*-indent", severity = "off", fixable = true },
  { rule = "*-spacing", severity = "off", fixable = true },
  { rule = "*-spaces", severity = "off", fixable = true },
  { rule = "*-order", severity = "off", fixable = true },
  { rule = "*-dangle", severity = "off", fixable = true },
  { rule = "*-newline", severity = "off", fixable = true },
  { rule = "*quotes", severity = "off", fixable = true },
  { rule = "*semi", severity = "off", fixable = true },
}

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local configs = require("lspconfig.configs")
      local util = require("lspconfig.util")

      local vyper_cmd = { "vyper-lsp" }
      local venv = vim.env.VIRTUAL_ENV
      if venv and vim.fn.executable(venv .. "/bin/vyper-lsp") == 1 then
        vyper_cmd = { venv .. "/bin/vyper-lsp" }
      end

      if not configs.vyper_lsp then
        configs.vyper_lsp = {
          default_config = {
            cmd = vyper_cmd,
            filetypes = { "vyper" },
            root_dir = util.root_pattern("pyproject.toml", ".git"),
            single_file_support = true,
          },
        }
      end
      opts = opts or {}
      opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, {
        bashls = {},
        cssls = {},
        dockerls = {},
        docker_compose_language_service = {},
        biome = {},
        eslint = {
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
            "vue",
            "html",
            "markdown",
            "json",
            "jsonc",
            "yaml",
            "toml",
            "xml",
            "gql",
            "graphql",
            "astro",
            "svelte",
            "css",
            "less",
            "scss",
            "pcss",
            "postcss",
          },
          settings = {
            rulesCustomizations = customizations,
          },
        },
        gopls = {},
        html = {},
        jsonls = {},
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = {
                globals = { "vim", "ls", "s", "t", "i", "f", "d", "fmt", "rep", "fmta", "line_begin" },
              },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        marksman = {},
        pyright = { single_file_support = true, filetypes = { "python" } },
        tailwindcss = {},
        yamlls = {},
        ts_ls = {},
        ruff = { filetypes = { "python" } },
        vyper_lsp = {
          mason = false,
          filetypes = { "vyper" },
          single_file_support = true,
        },
        custom_elements_ls = false,
      })
      opts.setup = opts.setup or {}
      opts.setup.vyper_lsp = function(_, server_opts)
        local venv = vim.env.VIRTUAL_ENV
        if venv and vim.fn.executable(venv .. "/bin/vyper-lsp") == 1 then
          server_opts.cmd = { venv .. "/bin/vyper-lsp" }
        end
        server_opts.root_dir = util.root_pattern("pyproject.toml", ".git")
        return false
      end

      return opts
    end,
  },
}
