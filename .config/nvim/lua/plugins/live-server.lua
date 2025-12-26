-- return {
--   "barrett-ruth/live-server.nvim",
--   build = "npm install -g live-server", -- or "pnpm add -g live-server"
--   cmd = {
--     "LiveServerStart",
--     "LiveServerStop",
--   },
--   config = true,
--   keys({
--     {
--       "<leader>is",
--       "<cmd>LiveServerStart<cr>",
--       desc = "Start live-server",
--     },
--     {
--       "<leader>ix",
--       "<cmd>LiveServerStop<cr>",
--       desc = "Stop live-server",
--     },
--   }),
-- }
--
return {
  {
    "barrett-ruth/live-server.nvim",
    build = "npm install -g live-server", -- or "pnpm add -g live-server"
    cmd = { "LiveServerStart", "LiveServerStop" },
    config = true,
    keys = {
      { "<leader>is", "<cmd>LiveServerStart<cr>", desc = "Live Server Start" },
      { "<leader>ix", "<cmd>LiveServerStop<cr>", desc = "Live Server Stop" },
    },
  },
}
