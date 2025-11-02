return {
  dir = "~/Developer/anysphere-dark.nvim/",
  -- "wkflanders/anysphere-dark.nvim",
  name = "anysphere",
  lazy = false,
  priority = 1000,
  config = function()
    -- vim.api.nvim_set_hl(0, "NormalNC", { bg = "#1b1d2b" })
    -- vim.api.nvim_set_hl(0, "Normal", { bg = "#1f2233" })
    vim.cmd.colorscheme("anysphere")
  end,
}
