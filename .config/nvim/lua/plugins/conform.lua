return {
  {
    "stevearc/conform.nvim",
    opts = {
      notify_on_error = true,
      formatters = {
        biome = {
          condition = function(_, ctx)
            return vim.fs.find("biome.json", { path = ctx.dirname, upward = true })[1] ~= nil
          end,
          args = { "check", "--write", "--stdin-file-path", "$FILENAME" },
        },
      },
      formatters_by_ft = {
        javascript = { "biome", "prettier", stop_after_first = true },
        typescript = { "biome", "prettier", stop_after_first = true },
        typescriptreact = { "biome", "prettier", stop_after_first = true },
        javascriptreact = { "biome", "prettier", stop_after_first = true },
        json = { "biome", "prettier", stop_after_first = true },
        jsonc = { "biome", "prettier", stop_after_first = true },
        html = { "biome", "prettier", stop_after_first = true },
        css = { "biome", "prettier", stop_after_first = true },
        yaml = { "prettier" },
        scss = { "prettier" },
        less = { "prettier" },
        markdown = { "prettier" },
        vue = { "prettier" },
        graphql = { "prettier" },
        lua = { "stylua" },
        python = { "black" },
        sh = { "shfmt" },
        vyper = { "mamushi" },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      format = {
        lsp_format = "never",
      },
    },
  },
}
