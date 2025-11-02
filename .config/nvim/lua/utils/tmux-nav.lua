local M = {}

local tmux_dir = { h = "L", j = "D", k = "U", l = "R" }

local function leave_terminal_mode_if_needed()
  if vim.bo.buftype == "terminal" then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
  end
end

local function try_vim_then_tmux(dir)
  -- 1) Try within Neovim splits
  leave_terminal_mode_if_needed()
  local cur = vim.api.nvim_get_current_win()
  vim.cmd("wincmd " .. dir)
  if vim.api.nvim_get_current_win() ~= cur then
    return
  end
  -- 2) No split there -> hop to tmux pane
  local tdir = tmux_dir[dir]
  if tdir then
    -- pcall to avoid messages if not in tmux
    pcall(vim.fn.system, { "tmux", "select-pane", "-" .. tdir })
  end
end

M.move = try_vim_then_tmux
return M
