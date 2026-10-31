local has_words_before = function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line, col = cursor[1], cursor[2]
  if col == 0 then
    return false
  end
  local text = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
  return text:sub(col, col):match("%s") == nil
end

return {
  "saghen/blink.cmp",
  opts = {
    enabled = function()
      local bt = vim.api.nvim_get_option_value("buftype", { buf = 0 })
      if bt == "prompt" or bt == "nofile" then
        return false
      end
      if vim.bo.filetype == "oil" then
        return false
      end
      return true
    end,
    keymap = {
      ["<CR>"] = false,
      ["<Tab>"] = {
        "select_and_accept",
        "snippet_forward",
        function(cmp)
          if has_words_before() then
            return cmp.show()
          end
        end,
        "fallback",
      },
      ["<M-n>"] = { "select_next" },
      ["<M-e>"] = { "select_prev" },
    },
    completion = {
      menu = {
        border = "none",
        winblend = 0,
        draw = {
          columns = { { "kind_icon" }, { "label" }, { "label_description" } },
        },
      },
    },
    fuzzy = {
      max_typos = function(keyword)
        return vim.bo.filetype == "solidity" and 0 or math.floor(#keyword / 4)
      end,
    },
    sources = {
      per_filetype = {
        solidity = { "lsp", "path", "snippets" },
      },
    },
    cmdline = { enabled = false },
  },
  -- dependencies = {
  --   "krissen/blink-cmp-bibtex",
  -- },
  --
  -- opts_extend = {
  --   "sources.default",
  --   "sources.providers",
  --   "sources.per_filetype",
  -- },
  --
  -- opts = function(_, opts)
  --   opts.sources = opts.sources or {}
  --   opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }
  --   opts.sources.providers = opts.sources.providers or {}
  --   opts.sources.per_filetype = opts.sources.per_filetype or {}
  --
  --   opts.sources.default = vim.list_extend(opts.sources.default, { "bibtex" })
  --
  --   -- If want strictly tex-only, comment the line above and use this instead
  --   -- opts.sources.per_filetype.tex = { "lsp", "path", "snippets", "buffer", "bibtex" }
  --   -- opts.sources.per_filetype.plaintex = { "lsp", "path", "snippets", "buffer", "bibtex" }
  --   -- opts.sources.per_filetype.latex = { "lsp", "path", "snippets", "buffer", "bibtex" }
  --
  --   opts.sources.providers.bibtex = {
  --     module = "blink-cmp-bibtex",
  --     name = "BibTeX",
  --     min_keyword_length = 0,
  --     score_offset = 10,
  --     async = true,
  --     opts = {},
  --     enabled = function()
  --       local ft = vim.bo.filetype
  --       return ft == "tex" or ft == "plaintex" or ft == "latex"
  --     end,
  --   }
  --
  --   opts.completion = opts.completion or {}
  --   opts.completion.trigger = opts.completion.trigger or {}
  --   opts.completion.trigger.show_on_trigger_character = true
  --
  --   opts.completion.trigger.show_on_blocked_trigger_characters = { "{", "," }
  --
  --   opts.keymap = vim.tbl_extend("force", opts.keymap or {}, {
  --     ["<Tab>"] = { "accept", "fallback" },
  --     ["<S-Tab>"] = { "select_prev", "fallback" },
  --     ["<C-n>"] = { "select_next", "fallback" },
  --     ["<C-p>"] = { "select_prev", "fallback" },
  --     ["<CR>"] = false,
  --   })
  -- end,
}
