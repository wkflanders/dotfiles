return {
  "miikanissi/modus-themes.nvim",
  name = "modus-themes",
  lazy = true,
  -- priority = 1000,
  config = function()
    require("modus-themes").setup({
      styles = { italic = false },
    })
    -- vim.cmd.colorscheme("modus_vivendi")
  end,
}
