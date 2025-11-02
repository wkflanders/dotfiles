return {
  "zenbones-theme/zenbones.nvim",
  name = "zenbones",
  dependencies = "rktjmp/lush.nvim",
  lazy = true,
  -- priority = 1000,
  config = function()
    vim.g.zenbones_compat = 1 -- Optional: for better compatibility
    -- vim.cmd.colorscheme("rosebones")
  end,
}
