return {
  "datsfilipe/vesper.nvim",
  name = "vesper",
  lazy = true,
  -- lazy = false,
  -- priority = 1000,
  config = function()
    require("vesper").setup({
      italics = {
        comments = false, -- Boolean: Italicizes comments
        keywords = false, -- Boolean: Italicizes keywords
        functions = false, -- Boolean: Italicizes functions
        strings = false, -- Boolean: Italicizes strings
        variables = false, -- Boolean: Italicizes variables
      },
    })
    -- vim.cmd.colorscheme("vesper")
  end,
}
