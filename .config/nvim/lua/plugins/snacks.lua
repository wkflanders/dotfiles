return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>sL",
      function()
        local Snacks = require("snacks")
        local ls = require("luasnip")
        local util = require("luasnip.util.util")

        local fts = util.get_snippet_filetypes()
        if not fts or #fts == 0 then
          fts = { vim.bo.filetype }
        end

        local items = {}

        local function doc_lines_for(snip, trig, desc, ft, kind)
          if type(snip.get_docstring) == "function" then
            local ok, lines = pcall(snip.get_docstring, snip)
            if ok and type(lines) == "table" and #lines > 0 then
              return lines
            end
          end

          local lines = {
            ("trigger: %s"):format(trig),
            ("type:    %s"):format(kind),
            ("ft:      %s"):format(ft),
          }
          if desc and desc ~= "" and desc ~= trig then
            table.insert(lines, "")
            table.insert(lines, desc)
          end
          return lines
        end

        local function add(ft, snip, is_auto)
          local trig = snip.trigger or snip.trig
          if type(trig) ~= "string" or trig == "" then
            return
          end

          local desc = snip.name or snip.dscr or ""
          if type(desc) ~= "string" then
            desc = ""
          end

          local kind = is_auto and "autosnippet" or "snippet"
          local lines = doc_lines_for(snip, trig, desc, ft, kind)

          local tmp = vim.fn.tempname() .. ".snip"
          vim.fn.writefile(lines, tmp)

          items[#items + 1] = {
            trig = trig,
            desc = desc,
            ft = ft,
            auto = is_auto,
            file = tmp,
            lnum = 1,
            col = 1,
            text = trig .. " " .. desc .. " " .. ft,
          }
        end

        for _, ft in ipairs(fts) do
          for _, snip in ipairs(ls.get_snippets(ft) or {}) do
            add(ft, snip, false)
          end
          for _, snip in ipairs(ls.get_snippets(ft, { type = "autosnippets" }) or {}) do
            add(ft, snip, true)
          end
        end

        table.sort(items, function(a, b)
          if a.trig == b.trig then
            return (a.ft or "") < (b.ft or "")
          end
          return a.trig < b.trig
        end)

        Snacks.picker.pick({
          title = "LuaSnip Snippets",
          items = items,
          format = function(item)
            local badge = item.auto and "A" or "S"
            local desc = (item.desc ~= "" and item.desc ~= item.trig) and item.desc or nil
            return {
              { badge .. " ", "Comment" },
              { item.trig, "Identifier" },
              desc and { "  " .. desc, "Comment" } or nil,
              { "  [" .. (item.ft or "?") .. "]", "Comment" },
            }
          end,
          confirm = function(picker, item)
            picker:close()
            if item and item.trig then
              vim.api.nvim_put({ item.trig }, "c", true, true)
            end
          end,
        })
      end,
      desc = "Snippets (LuaSnip list)",
    },
  },
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
          layout = {
            preset = "telescope",
            preview = { enabled = false },
            layout = {
              width = 0.8,
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
            },
          },
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
                vim.fn.setreg('"', result)
                vim.fn.setreg("+", result)
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
