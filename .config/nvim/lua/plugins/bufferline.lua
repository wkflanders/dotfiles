return {
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.always_show_bufferline = true
      opts.options.custom_filter = function(bufnr, _)
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name == nil or name == "" then
          return false
        end
        return true
      end

      opts.options.show_buffer_close_icons = false
      opts.options.show_close_icon = false
      opts.options.separator_style = "thin"

      opts.options.indicator = {
        style = "none",
      }

      opts.highlights = opts.highlights or {}

      local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
      local normal_bg = normal.bg and string.format("#%06x", normal.bg) or "NONE"

      opts.highlights.fill = {
        bg = normal_bg,
      }
      opts.highlights.background = {
        bg = normal_bg,
      }
      opts.highlights.buffer_visible = {
        bg = normal_bg,
      }
      opts.highlights.close_button_visible = {
        bg = normal_bg,
      }

      opts.highlights.separator = {
        fg = normal_bg,
        bg = normal_bg,
      }
      opts.highlights.separator_selected = {
        fg = normal_bg,
        bg = normal_bg,
      }
      opts.highlights.separator_visible = {
        fg = normal_bg,
        bg = normal_bg,
      }

      return opts
    end,
  },
}
