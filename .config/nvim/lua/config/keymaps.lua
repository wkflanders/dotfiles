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

vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })

vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
