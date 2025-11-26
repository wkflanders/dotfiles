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

-- Vyper LSP
vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = { "*.vy" },
  callback = function()
    vim.lsp.start({
      name = "vyper-lsp",
      cmd = { "vyper-lsp" },
      root_dir = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1]),
    })
  end,
})

-- Override diagnostic handler to filter ModuleNotFound
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "vyper-lsp" then
      -- Store original handler
      local original_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]

      -- Override with filtering handler
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

-- -- LaTeX format on save
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = "*.tex",
--   callback = function()
--     -- Only run if VimtexFormat exists
--     if vim.fn.exists(":VimtexFormat") == 2 then
--       vim.cmd("silent VimtexFormat")
--     end
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "snacks_layout_box",
--   callback = function()
--     vim.opt_local.statusline = ""
--   end,
-- })
