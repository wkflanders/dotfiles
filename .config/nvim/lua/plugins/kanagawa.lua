return {
  "rebelot/kanagawa.nvim",
  name = "kanagawa",
  lazy = true,
  -- priority = 1005,
  config = function()
    require("kanagawa").setup({
      styles = { italic = false },
    })
  end,
}
