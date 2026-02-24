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
      if not configs.vyper then
        configs.vyper = {
          default_config = {
            cmd = { "vyper-lsp" },
            filetypes = { "vyper", "vy" },
            root_dir = util.root_pattern("pyproject.toml", ".git"),
          },
        }
      end
      opts = opts or {}
      opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, {
        bashls = {},
        cssls = {},
        dockerls = {},
        docker_compose_language_service = {},
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
        vyper = { mason = false, filetypes = { "vyper", "vy" } },
        custom_elements_ls = false,
      })
      opts.setup = opts.setup or {}
      opts.setup.vyper = function(_, server_opts)
        local venv = vim.env.VIRTUAL_ENV
        if venv and vim.fn.executable(venv .. "/bin/vyper-lsp") == 1 then
          server_opts.cmd = { venv .. "/bin/vyper-lsp" }
        elseif vim.fn.executable("vyper-lsp") == 1 then
          server_opts.cmd = { "vyper-lsp" }
        end
        server_opts.filetypes = { "vyper", "vy" }
        return false
      end
      return opts
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "bashls",
        "cssls",
        "dockerls",
        "docker_compose_language_service",
        "eslint",
        "gopls",
        "html",
        "jsonls",
        "lua_ls",
        -- "rnix",
        "solidity_ls_nomicfoundation",
        "tailwindcss",
        -- "terraformls",
        -- "tflint",
        "yamlls",
        "ts_ls",
        "pyright",
      },
    },
  },
}
