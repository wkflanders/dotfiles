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
        custom_elements_ls = false,
      })
      opts.setup = opts.setup or {}
      return opts
    end,
  },
}
