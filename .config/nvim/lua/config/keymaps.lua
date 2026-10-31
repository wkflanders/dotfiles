-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>q", "<cmd>qa<cr>", { desc = "Quit all" })

local opts = { silent = true }

-- Works in normal *and* terminal buffers
vim.keymap.set({ "n", "t" }, "<C-h>", "<cmd>TmuxNavigateLeft<cr>", opts)
vim.keymap.set({ "n", "t" }, "<C-j>", "<cmd>TmuxNavigateDown<cr>", opts)
vim.keymap.set({ "n", "t" }, "<C-k>", "<cmd>TmuxNavigateUp<cr>", opts)
vim.keymap.set({ "n", "t" }, "<C-l>", "<cmd>TmuxNavigateRight<cr>", opts)

local function halfpage_then_center(key) -- key = "<C-d>" or "<C-u>"
  local before = vim.api.nvim_win_get_cursor(0)[1]
  local tc = vim.api.nvim_replace_termcodes(key, true, false, true)
  vim.api.nvim_feedkeys(tc, "n", false)
  local after = vim.api.nvim_win_get_cursor(0)[1]

  if after ~= before then
    vim.cmd("normal! zz")
  end
end

vim.keymap.set("i", "<M-n>", function()
  vim.notify("got M-n")
end)

vim.keymap.set("i", "<M-e>", function()
  vim.notify("got M-e")
end)

vim.keymap.set("n", "<C-d>", function()
  halfpage_then_center("<C-d>")
end, { noremap = true, silent = true, desc = "Half-page down then center" })

vim.keymap.set("n", "<C-u>", function()
  halfpage_then_center("<C-u>")
end, { noremap = true, silent = true, desc = "Half-page up then center" })

local function move_divider(dir)
  local vertical = dir == "h" or dir == "l"
  local after, before = vertical and "l" or "j", vertical and "h" or "k"
  local cur = vim.fn.winnr()
  local side = vim.fn.winnr(after) ~= cur and after or vim.fn.winnr(before) ~= cur and before
  if side then
    vim.cmd((vertical and "vertical " or "") .. "resize " .. (side == dir and "+5" or "-5"))
  elseif vim.env.TMUX then
    vim.fn.system({ "tmux", "resize-pane", "-" .. ({ h = "L", j = "D", k = "U", l = "R" })[dir], "5" })
  end
end

for _, dir in ipairs({ "h", "j", "k", "l" }) do
  vim.keymap.set({ "n", "t" }, "<M-" .. dir:upper() .. ">", function()
    move_divider(dir)
  end, { silent = true })
end
