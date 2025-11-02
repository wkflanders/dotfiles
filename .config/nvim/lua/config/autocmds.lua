-- vim.api.nvim_create_autocmd("ColorScheme", {
--   pattern = "*",
--   callback = function()
--     vim.api.nvim_set_hl(0, "SnacksPicker", { bg = "none", nocombine = true })
--     vim.api.nvim_set_hl(0, "SnacksPickerBorder", { fg = "#316c71", bg = "none", nocombine = true })
--   end,
-- })

-- local aug = vim.api.nvim_create_augroup("no_truecolor", { clear = true })
--
-- -- Re-disable after startup and after any colorscheme change
-- vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
--   group = aug,
--   callback = function()
--     vim.opt.termguicolors = false
--   end,
-- })
--
-- -- One more belt-and-suspenders: run after the entire event loop settles
-- vim.schedule(function()
--   vim.opt.termguicolors = false
-- end)
--
-- vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }
vim.g.root_spec = { "cwd" }
vim.filetype.add({
  extension = { sol = "solidity" },
})

-- Vyper LSP
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "*.vy" },
  callback = function()
    vim.lsp.start({
      name = "vyper-lsp",
      cmd = { "vyper-lsp" },
      root_dir = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1]),
    })
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "*.vy" },
  callback = function()
    vim.lsp.start({
      name = "vyper-lsp",
      cmd = { "vyper-lsp" },
      root_dir = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1]),
    })
  end,
})
