return {
  "saghen/blink.cmp",
  dependencies = {
    "krissen/blink-cmp-bibtex",
  },

  opts_extend = {
    "sources.default",
    "sources.providers",
    "sources.per_filetype",
  },

  opts = function(_, opts)
    opts.sources = opts.sources or {}
    opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }
    opts.sources.providers = opts.sources.providers or {}
    opts.sources.per_filetype = opts.sources.per_filetype or {}

    opts.sources.default = vim.list_extend(opts.sources.default, { "bibtex" })

    -- If want strictly tex-only, comment the line above and use this instead
    -- opts.sources.per_filetype.tex = { "lsp", "path", "snippets", "buffer", "bibtex" }
    -- opts.sources.per_filetype.plaintex = { "lsp", "path", "snippets", "buffer", "bibtex" }
    -- opts.sources.per_filetype.latex = { "lsp", "path", "snippets", "buffer", "bibtex" }

    opts.sources.providers.bibtex = {
      module = "blink-cmp-bibtex",
      name = "BibTeX",
      min_keyword_length = 0,
      score_offset = 10,
      async = true,
      opts = {},
      enabled = function()
        local ft = vim.bo.filetype
        return ft == "tex" or ft == "plaintex" or ft == "latex"
      end,
    }

    opts.completion = opts.completion or {}
    opts.completion.trigger = opts.completion.trigger or {}
    opts.completion.trigger.show_on_trigger_character = true

    opts.completion.trigger.show_on_blocked_trigger_characters = { "{", "," }

    opts.keymap = vim.tbl_extend("force", opts.keymap or {}, {
      ["<Tab>"] = { "accept", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<CR>"] = false,
    })
  end,
}
