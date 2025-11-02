return {
  "rose-pine/neovim",
  name = "rose-pine",
  lazy = true,
  -- priority = 1000,

  config = function()
    require("rose-pine").setup({
      variant = "moon",
      extend_background_behind_borders = true,
      styles = { italic = false, bold = true, transparency = true },
    })
    -- vim.api.nvim_set_hl(0, "Normal", { bg = "#17131E" })
    -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#17131E" })
    -- vim.api.nvim_set_hl(0, "NormalNC", { bg = "#17131E" })
    -- vim.cmd.colorscheme("rose-pine")
    -- vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#17131E", bg = "#17131E" })
    -- vim.api.nvim_set_hl(0, "SnacksNormal", { bg = "#17131E" })
    -- vim.api.nvim_set_hl(0, "SnacksNormalNC", { bg = "#17131E" })
    -- vim.api.nvim_set_hl(0, "SnacksBorder", { bg = "#17131E", fg = "#17131E" })
    -- vim.api.nvim_set_hl(0, "SnacksPanelBorder", { bg = "#17131E", fg = "#17131E" })
    -- vim.opt.signcolumn = "no"
    -- vim.opt.foldcolumn = "0"
  end,
}

-- return {
--   "rose-pine/neovim",
--   name = "rose-pine",
--   lazy = false,
--   priority = 1000,
--   config = function()
--     require("rose-pine").setup({
--       -- variant = "moon",
--       disable_background = true,
--       extend_background_behind_borders = true,
--       styles = { italic = false, bold = false, transparency = true },
--       before_highlight = function(group, highlight, palette)
--         if highlight.fg == palette.foam then
--           highlight.fg = "#b5bbc0"
--         end
--         if highlight.fg == palette.gold then
--           highlight.fg = "#AA9586"
--         end
--         if highlight.fg == palette.love then
--           highlight.fg = "#c45876"
--         end
--       end,
--     })
--
--     function ColorMyPencils()
--       vim.cmd.colorscheme("rose-pine")
--
--       vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
--       vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
--       vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
--
--       vim.o.background = "dark"
--     end
--
--     ColorMyPencils()
--
--     -- ensure background is black
--     -- vim.api.nvim_set_hl(0, "Normal", { bg = "black" })
--     -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "black" })
--     -- vim.api.nvim_set_hl(0, "NormalNC", { bg = "black" }) -- unfocused windows
--   end,
-- }
