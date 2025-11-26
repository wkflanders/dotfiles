return {
  "folke/noice.nvim",
  opts = function(_, opts)
    opts = opts or {}

    opts.cmdline = vim.tbl_deep_extend("force", {
      enabled = true,
      view = "cmdline",
      format = {
        -- ":" commands
        cmdline = { pattern = "^:", icon = "", lang = "vim" },
        -- "/" search
        search_down = { kind = "search", pattern = "^/", icon = "", lang = "regex" },
        -- "?" search
        search_up = { kind = "search", pattern = "^?", icon = "", lang = "regex" },
      },
    }, opts.cmdline or {})

    return opts
  end,

  init = function()
    local group = vim.api.nvim_create_augroup("NoiceCmdlineStatus", { clear = true })

    vim.api.nvim_create_autocmd("CmdlineEnter", {
      group = group,
      callback = function()
        -- Save whatever laststatus you’re using (2 or 3) and hide it.
        if vim.g.__saved_laststatus == nil then
          vim.g.__saved_laststatus = vim.o.laststatus
        end
        vim.o.laststatus = 0
      end,
    })

    vim.api.nvim_create_autocmd("CmdlineLeave", {
      group = group,
      callback = function()
        if vim.g.__saved_laststatus ~= nil then
          vim.o.laststatus = vim.g.__saved_laststatus
          vim.g.__saved_laststatus = nil
        else
          -- Fallback if somehow not saved; LazyVim defaults to 3 (globalstatus)
          vim.o.laststatus = 3
        end
      end,
    })
  end,
}
