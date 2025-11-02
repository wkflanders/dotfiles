return {
  {
    "EdenEast/nightfox.nvim",
    name = "nightfox",
    lazy = true,
    -- priority = 1000,
    config = function()
      require("nightfox").setup({
        italics = false,
        options = {
          colorblind = {
            enable = true,
            simulate_only = true,
            severity = {
              tritan = 1,
            },
          },
        },
      })
      -- vim.cmd.colorscheme("nightfox")
    end,
  },
}
