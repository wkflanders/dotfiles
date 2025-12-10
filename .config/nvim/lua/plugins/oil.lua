return {
  "stevearc/oil.nvim",
  lazy = false,
  opts = {
    default_file_explorer = true,
    view_options = {
      show_hidden = true,
    },
    float = {
      padding = 0,
      -- max_width = 1,
      -- max_height = 1,
      border = "none",
      win_options = {
        winblend = 0,
      },
    },
    keymaps = {
      ["q"] = "actions.close",
      ["<Esc>"] = "actions.close",
    },
  },
  keys = {
    -- { "<leader>E", "<CMD>Oil<CR>", desc = "Oil: inline directory" },
    {
      "<leader>e",
      function()
        require("oil").toggle_float()
      end,
      desc = "Oil: floating window",
    },
  },
}
