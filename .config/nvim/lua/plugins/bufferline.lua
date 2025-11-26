return {
  "akinsho/bufferline.nvim",
  opts = {
    -- options = {
    -- offsets = {
    --   {
    --     filetype = "snacks_layout_box",
    --     text = "Explorer",
    --     highlight = "Directory",
    --     text_align = "left",
    --   },
    -- },
    -- },
    highlights = {
      buffer_selected = {
        fg = "#FFFFFF",
        bold = true,
      },
      buffer_visible = {
        fg = "#000000", -- slightly faded
        italic = true,
      },
      buffer = {
        fg = "#000000", -- fully inactive + most faded
        italic = true,
      },
    },
  },
}
-- return {
--   "akinsho/bufferline.nvim",
--   opts = function(_, opts)
--     local c = {
--       bg = "#191719", -- main editor bg
--       bg_sel = "#2f2b30", -- selected tab bg (matches StatusLine)
--       fg = "#d6c1c5", -- normal fg
--       fg_dim = "#5a525b", -- dim text
--       accent = "#c5a3a9", -- soft accent (for underline/extra if you want)
--     }
--
--     opts.options = opts.options or {}
--     opts.options.separator_style = "thin"
--     opts.options.show_buffer_close_icons = false
--     opts.options.show_close_icon = false
--
--     opts.highlights = {
--       -- whole bar background
--       fill = {
--         bg = c.bg,
--       },
--
--       -- inactive buffers
--       background = {
--         fg = c.fg_dim,
--         bg = c.bg,
--       },
--
--       -- visible but not current (e.g. other window)
--       buffer_visible = {
--         fg = c.fg_dim,
--         bg = c.bg,
--       },
--
--       -- current buffer
--       buffer_selected = {
--         fg = c.fg,
--         bg = c.bg_sel,
--         bold = true,
--       },
--
--       -- tabs (if you use them)
--       tab = {
--         fg = c.fg_dim,
--         bg = c.bg,
--       },
--       tab_selected = {
--         fg = c.fg,
--         bg = c.bg_sel,
--         bold = true,
--       },
--       tab_close = {
--         fg = c.fg_dim,
--         bg = c.bg,
--       },
--
--       -- separators basically invisible
--       separator = {
--         fg = c.bg,
--         bg = c.bg,
--       },
--       separator_visible = {
--         fg = c.bg,
--         bg = c.bg,
--       },
--       separator_selected = {
--         fg = c.bg_sel,
--         bg = c.bg_sel,
--       },
--
--       -- close buttons dimmed
--       close_button = {
--         fg = c.fg_dim,
--         bg = c.bg,
--       },
--       close_button_visible = {
--         fg = c.fg_dim,
--         bg = c.bg,
--       },
--       close_button_selected = {
--         fg = c.fg_dim,
--         bg = c.bg_sel,
--       },
--     }
--
--     return opts
--   end,
-- }
