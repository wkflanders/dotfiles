-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.g.python3_host_prog = vim.fn.expand("~/.config/nvim/python/env/bin/python3")

vim.filetype.add({
  extension = {
    ctmpl = "gotmpl",
    vy = "vyper",
  },
})

vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.g.vimtex_syntax_enabled = 0

-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
