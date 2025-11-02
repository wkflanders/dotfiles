return {
  {
    "nvim-mini/mini.icons",
    opts = function(_, opts)
      vim.api.nvim_set_hl(0, "MiniIconsVyper", { fg = "#62688F" })
      opts = opts or {}
      opts.extension = opts.extension or {}
      opts.filetype = opts.filetype or {}
      opts.extension.vy = { glyph = "\u{E8DF}", hl = "MiniIconsVyper" }
      opts.extension.vyi = { glyph = "\u{E8DF}", hl = "MiniIconsVyper" }
      opts.filetype.vyper = { glyph = "\u{E8DF}", hl = "MiniIconsVyper" }
      return opts
    end,
    init = function()
      pcall(function()
        require("mini.icons").mock_nvim_web_devicons()
      end)
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    opts = {
      override_by_extension = {
        vy = { icon = "\u{E8DF}", color = "#62688F", name = "Vyper" },
        vyi = { icon = "\u{E8DF}", color = "#62688F", name = "Vyper Interface" },
      },
    },
  },
}
