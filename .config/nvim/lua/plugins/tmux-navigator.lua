return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  init = function()
    -- Optional: don't wrap from edge pane to the opposite side
    vim.g.tmux_navigator_no_wrap = 1
    -- Optional: disable when a tmux pane is zoomed
    vim.g.tmux_navigator_disable_when_zoomed = 1
  end,
}
