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
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "tex", "latex" },
      callback = function(ev)
        vim.keymap.set("i", "<CR>", function()
          return require("blink.cmp").accept()
            or vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
        end, { buffer = ev.buf, expr = true })

        vim.keymap.set("i", "<Tab>", "<Tab>", { buffer = ev.buf })
      end,
    })
  end,
}
