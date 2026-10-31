return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  init = function()
    -- Optional: disable when a tmux pane is zoomed
    vim.g.tmux_navigator_disable_when_zoomed = 1
  end,
}
