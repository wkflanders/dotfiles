-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Disable netrw (built-in file explorer)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.listchars = { tab = "  " }

vim.api.nvim_create_user_command("HighlightHex", function()
  local highlights = vim.api.nvim_exec2("highlight", { output = true })
  for line in highlights.output:gmatch("[^\r\n]+") do
    local hl_name = line:match("^(%S+)")
    if hl_name then
      local fg = vim.fn.synIDattr(vim.fn.hlID(hl_name), "fg#")
      local bg = vim.fn.synIDattr(vim.fn.hlID(hl_name), "bg#")
      if fg ~= "" or bg ~= "" then
        print(string.format("%s: fg=%s bg=%s", hl_name, fg, bg))
      end
    end
  end
end, {})
