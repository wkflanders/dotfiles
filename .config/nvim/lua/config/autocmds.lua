-- vim.api.nvim_create_autocmd("ColorScheme", {
--   pattern = "*",
--   callback = function()
--     vim.api.nvim_set_hl(0, "SnacksPicker", { bg = "none", nocombine = true })
--     vim.api.nvim_set_hl(0, "SnacksPickerBorder", { fg = "#316c71", bg = "none", nocombine = true })
--   end,
-- })

-- local aug = vim.api.nvim_create_augroup("no_truecolor", { clear = true })
--
-- -- Re-disable after startup and after any colorscheme change
-- vim.api.nvim_create_autocmd({ "VimEnter", "ColorScheme" }, {
--   group = aug,
--   callback = function()
--     vim.opt.termguicolors = false
--   end,
-- })
--
-- -- One more belt-and-suspenders: run after the entire event loop settles
-- vim.schedule(function()
--   vim.opt.termguicolors = false
-- end)
--
-- vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

vim.g.root_spec = { "cwd" }
vim.filetype.add({
  extension = { sol = "solidity" },
})

local group = vim.api.nvim_create_augroup("bufferline_visibility", { clear = true })

local function has_named_file_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_loaded(buf)
      and vim.bo[buf].buflisted
      and vim.bo[buf].buftype == ""
      and vim.api.nvim_buf_get_name(buf) ~= ""
    then
      return true
    end
  end
  return false
end

local function update_showtabline()
  vim.o.showtabline = has_named_file_buffers() and 2 or 0
end

vim.api.nvim_create_autocmd({
  "BufAdd",
  "BufDelete",
  "BufEnter",
  "BufFilePost",
  "VimEnter",
}, {
  group = group,
  callback = update_showtabline,
})

-- Override diagnostic handler to filter ModuleNotFound
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "vyper_lsp" then
      local original_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]

      vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
        if result and result.diagnostics then
          result.diagnostics = vim.tbl_filter(function(diagnostic)
            return not diagnostic.message:match("ModuleNotFound")
          end, result.diagnostics)
        end
        original_handler(err, result, ctx, config)
      end
    end
  end,
})
