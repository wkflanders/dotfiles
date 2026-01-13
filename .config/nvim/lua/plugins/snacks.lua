return {
  "folke/snacks.nvim",
  opts = {
    explorer = { enabled = false },
    dashboard = { enabled = true },
    indent = {
      indent = { enabled = false },
      chunk = { enabled = false },
      scope = { enabled = false },
    },
    -- animate = {
    --   enabled = vim.fn.has("nvim-0.10") == 1,
    --   style = "out",
    --   easing = "linear",
    --   duration = {
    --     step = 20,
    --     total = 10000,
    --   },
    -- },
    -- indent = {
    --   indent = {
    --     enabled = false,
    --   },
    --   chunk = {
    --     -- enabled = true,
    --     enabled = false,
    --     char = {
    --       horizontal = "─",
    --       vertical = "│",
    --       corner_top = "╭",
    --       corner_bottom = "╰",
    --       arrow = "─",
    --     },
    --   },
    -- },
    picker = {
      win = {
        input = {
          keys = {
            ["<Esc>"] = { "close", mode = { "n", "i" } },
          },
        },
      },
      sources = {
        files = {
          hidden = true,
          -- layout = {
          --   layout = {
          --     -- backdrop = false,
          --     row = 1,
          --     width = 0.5,
          --     min_width = 60,
          --     height = 0.9,
          --     border = "none",
          --     box = "vertical",
          --     { win = "preview", title = "{preview}", height = 0.45, border = true },
          --     {
          --       box = "vertical",
          --       border = true,
          --       title = "{title} {live} {flags}",
          --       title_pos = "center",
          --       { win = "input", height = 1, border = "bottom" },
          --       { win = "list", border = "none" },
          --     },
          --   },
          -- },
        },
        explorer = {
          enabled = false,
          auto_open = false,
          replace_netrw = true,
          win = {
            list = {
              keys = {
                ["Y"] = "copy_path",
              },
            },
          },
          actions = {
            copy_path = function(_, item)
              local modify = vim.fn.fnamemodify
              local filepath = item.file
              local filename = modify(filepath, ":t")
              local values = {
                filepath,
                modify(filepath, ":."),
                modify(filepath, ":~"),
                filename,
                modify(filename, ":r"),
                modify(filename, ":e"),
              }
              local items = {
                "Absolute path: " .. values[1],
                "Path relative to CWD: " .. values[2],
                "Path relative to HOME: " .. values[3],
                "Filename: " .. values[4],
              }
              if vim.fn.isdirectory(filepath) == 0 then
                vim.list_extend(items, {
                  "Filename without extension: " .. values[5],
                  "Extension of the filename: " .. values[6],
                })
              end
              vim.ui.select(items, { prompt = "Choose to copy to clipboard:" }, function(choice, i)
                if not choice then
                  vim.notify("Selection cancelled")
                  return
                end
                if not i then
                  vim.notify("Invalid selection")
                  return
                end
                local result = values[i]
                vim.fn.setreg('"', result) -- Neovim unnamed register
                vim.fn.setreg("+", result) -- System clipboard
                vim.notify("Copied: " .. result)
              end)
            end,
          },
          icons = {
            tree = {
              vertical = "  ",
              middle = "  ",
              last = "  ",
            },
          },
          auto_jump = false,
          lines = false,
          hidden = true,
          follow_file = true,
          ignored = true, -- <— explorer does not respect .gitignore
          ui = {
            indent = {
              enabled = false, -- disable indent guides in the explorer
            },
            icons = {
              indent = {
                enabled = false, -- disable indent icons (lines)
              },
            },
          },
          exclude = {
            ".git",
            "**/.git/",
            ".DS_Store",
            "**/.DS_Store",
          },
          -- Optional: keep explorer clean but still allow dist/
          -- filter = function(entry)
          --   local name = entry.name
          --   if name == ".git" or name == "node_modules" then
          --     return false
          --   end
          --   return true
          -- end,
          -- layout = {
          --   { preview = true },
          --   layout = {
          --     box = "horizontal",
          --     width = 0.8,
          --     height = 0.8,
          --     {
          --       box = "vertical",
          --       border = "rounded",
          --       title = "{source} {live} {flags}",
          --       title_pos = "center",
          --       { win = "input", height = 1, border = "bottom" },
          --       { win = "list", border = "none" },
          --     },
          --     { win = "preview", border = "rounded", width = 0.7, title = "{preview}" },
          --   },
          -- },
          layout = {
            box = "vertical",
            auto_hide = { "input" },
            layout = {
              width = 30,
              height = 100,
            },
          },
        },
        -- The settings below apply to the file picker (<leader>ff)
        -- files = {
        --   hidden = true,
        -- },
      },
    },
  },
  -- vim.api.nvim_create_autocmd("ColorScheme", {
  --   pattern = "*",
  --   callback = function()
  --     vim.api.nvim_set_hl(0, "SnacksPicker", { bg = "none", nocombine = true })
  --     vim.api.nvim_set_hl(0, "SnacksPickerBorder", { fg = "#316c71", bg = "none", nocombine = true })
  --   end,
  -- }),
}
