-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>q", "<cmd>qa<cr>", { desc = "Quit all" })

local nav = require("utils.tmux-nav")
local opts = { silent = true }

-- Works in normal *and* terminal buffers
vim.keymap.set({ "n", "t" }, "<C-h>", function()
  nav.move("h")
end, opts)
vim.keymap.set({ "n", "t" }, "<C-j>", function()
  nav.move("j")
end, opts)
vim.keymap.set({ "n", "t" }, "<C-k>", function()
  nav.move("k")
end, opts)
vim.keymap.set({ "n", "t" }, "<C-l>", function()
  nav.move("l")
end, opts)

local function halfpage_then_center(key) -- key = "<C-d>" or "<C-u>"
  local before = vim.api.nvim_win_get_cursor(0)[1]
  local tc = vim.api.nvim_replace_termcodes(key, true, false, true)
  vim.api.nvim_feedkeys(tc, "n", false)
  local after = vim.api.nvim_win_get_cursor(0)[1]

  if after ~= before then
    vim.cmd("normal! zz")
  end
end

vim.keymap.set("n", "<C-d>", function()
  halfpage_then_center("<C-d>")
end, { noremap = true, silent = true, desc = "Half-page down then center" })

vim.keymap.set("n", "<C-u>", function()
  halfpage_then_center("<C-u>")
end, { noremap = true, silent = true, desc = "Half-page up then center" })
