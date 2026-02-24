return {
  {
    "stevearc/conform.nvim",
    opts = {
      notify_on_error = true,
      formatters_by_ft = {
        javascript = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        less = { "prettier" },
        markdown = { "prettier" },
        vue = { "prettier" },
        graphql = { "prettier" },
        lua = { "stylua" },
        python = { "black" },
        sh = { "shfmt" },
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
