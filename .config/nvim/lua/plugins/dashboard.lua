return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}

      local function set_hl()
        vim.api.nvim_set_hl(0, "Dash1", { fg = "#5ea1ff", bold = true })
        vim.api.nvim_set_hl(0, "Dash2", { fg = "#6da8ff", bold = true })
        vim.api.nvim_set_hl(0, "Dash3", { fg = "#7caeff", bold = true })
        vim.api.nvim_set_hl(0, "Dash4", { fg = "#8bb2ff", bold = true })
        vim.api.nvim_set_hl(0, "Dash5", { fg = "#9ab3fd", bold = true })
        vim.api.nvim_set_hl(0, "Dash6", { fg = "#acb1f8", bold = true })
        vim.api.nvim_set_hl(0, "Dash7", { fg = "#beacef", bold = true })
        vim.api.nvim_set_hl(0, "Dash8", { fg = "#d0a6e2", bold = true })
        vim.api.nvim_set_hl(0, "Dash9", { fg = "#e29fd2", bold = true })
        vim.api.nvim_set_hl(0, "Dash10", { fg = "#f099bf", bold = true })

        vim.api.nvim_set_hl(0, "SnacksDashboardIcon", { fg = "#e29fd2" })
        vim.api.nvim_set_hl(0, "SnacksDashboardDesc", { fg = "#a9bdf5" })
        vim.api.nvim_set_hl(0, "SnacksDashboardKey", { fg = "#e5a1a1" })
      end

      set_hl()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_hl,
      })

      opts.dashboard.preset = {
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      }

      opts.dashboard.sections = {
        {
          text = {
            {
              [[                                                                       ]],
              hl = "Dash1",
              align = "center",
            },
          },
        },
        {
          text = {
            {
              [[                                                                     ]],
              hl = "Dash2",
              align = "center",
            },
          },
        },
        {
          text = {
            {
              [[       ████ ██████           █████      ██                     ]],
              hl = "Dash3",
              align = "center",
            },
          },
        },
        {
          text = {
            {
              [[      ███████████             █████                             ]],
              hl = "Dash4",
              align = "center",
            },
          },
        },
        {
          text = {
            {
              [[      █████████ ███████████████████ ███   ███████████   ]],
              hl = "Dash5",
              align = "center",
            },
          },
        },
        {
          text = {
            {
              [[     █████████  ███    █████████████ █████ ██████████████   ]],
              hl = "Dash6",
              align = "center",
            },
          },
        },
        {
          text = {
            {
              [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
              hl = "Dash7",
              align = "center",
            },
          },
        },
        {
          text = {
            {
              [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
              hl = "Dash8",
              align = "center",
            },
          },
        },
        {
          text = {
            {
              [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
              hl = "Dash9",
              align = "center",
            },
          },
        },
        {
          text = {
            {
              [[                                                                       ]],
              hl = "Dash10",
              align = "center",
            },
          },
          padding = 1,
        },
        { section = "keys", gap = 1, padding = 1 },
      }

      return opts
    end,
  },
}
