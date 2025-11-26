return {
  {
    "SirVer/ultisnips",
    event = "InsertEnter",
    init = function()
      -- Use Tab to expand and jump
      vim.g.UltiSnipsExpandTrigger = "<tab>"
      vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
      vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"

      -- Tell UltiSnips where the snippet folder is
      vim.g.UltiSnipsSnippetDirectories = { "UltiSnips" }
    end,
  },

  {
    "KeitaNakamura/tex-conceal.vim",
    ft = { "tex", "plaintex", "latex" },
    init = function()
      vim.opt.conceallevel = 2
      vim.g.tex_conceal = "abdmg"
    end,
  },
}
