return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.options = opts.options or {}
    opts.options.globalstatus = false
    opts.options.disabled_filetypes = opts.options.disabled_filetypes or {}
    local df = opts.options.disabled_filetypes
    df.statusline = df.statusline or {}
    local function ensure(ft)
      for _, v in ipairs(df.statusline) do
        if v == ft then
          return
        end
      end
      table.insert(df.statusline, ft)
    end
    ensure("snacks_layout_box")
    opts.inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    }
    opts.sections = opts.sections or {}
    opts.sections.lualine_z = {}
  end,
}
