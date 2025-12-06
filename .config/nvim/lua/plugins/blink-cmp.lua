return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    opts.keymap = vim.tbl_extend("force", opts.keymap or {}, {
      ["<Tab>"] = { "accept", "fallback" },
      ["<S-Tab>"] = { "select_next", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<CR>"] = false,
    })
  end,
}
