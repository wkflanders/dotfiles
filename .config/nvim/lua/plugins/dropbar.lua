return {
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
    },
    opts = {
      icons = {
        enable = true,
        ui = {
          bar = {
            separator = " › ",
          },
        },
      },
      bar = {
        truncate = true,
        hover = false,
      },
    },
    config = function(_, opts)
      require("dropbar").setup(opts)

      local normal = vim.api.nvim_get_hl(0, { name = "Normal" })

      local normal_bg = normal.bg and string.format("#%06x", normal.bg) or "NONE"
      local normal_fg = normal.fg and string.format("#%06x", normal.fg) or "#7a849c"

      vim.api.nvim_set_hl(0, "WinBar", {
        fg = normal_fg,
        bg = normal_bg,
        bold = false,
        italic = false,
      })

      vim.api.nvim_set_hl(0, "WinBarNC", {
        fg = normal_fg,
        bg = normal_bg,
        bold = false,
        italic = false,
      })

      vim.api.nvim_set_hl(0, "DropBarCurrentContext", {
        fg = normal_fg,
        bg = normal_bg,
        bold = false,
        italic = false,
      })

      vim.api.nvim_set_hl(0, "DropBarContext", {
        fg = normal_fg,
        bg = normal_bg,
        bold = false,
        italic = false,
      })

      vim.api.nvim_set_hl(0, "DropBarIconUISeparator", {
        fg = normal_fg,
        bg = normal_bg,
        bold = false,
        italic = false,
      })
    end,
  },
}
