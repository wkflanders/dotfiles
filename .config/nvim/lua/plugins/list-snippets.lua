return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>sL",
      function()
        local Snacks = require("snacks")
        local ls = require("luasnip")

        local ok_util, util = pcall(require, "luasnip.util.util")
        local fts = ok_util and util.get_snippet_filetypes() or { vim.bo.filetype }
        if not fts or #fts == 0 then
          fts = { vim.bo.filetype }
        end

        local items = {}
        local idx = 0

        local function add_snips(ft, snips, kind)
          if type(snips) ~= "table" then
            return
          end
          for _, snip in ipairs(snips) do
            local trig = snip.trigger or snip.trig or ""
            if trig ~= "" then
              idx = idx + 1
              local desc = snip.name or snip.dscr or snip.description or ""
              local doc = {}

              if type(snip.get_docstring) == "function" then
                local ok_doc, got = pcall(snip.get_docstring, snip)
                if ok_doc and type(got) == "table" then
                  doc = got
                end
              end

              local preview_text
              if type(doc) == "table" and #doc > 0 then
                preview_text = table.concat(doc, "\n")
              else
                preview_text = table.concat({
                  ("trigger: %s"):format(trig),
                  ("desc: %s"):format(desc ~= "" and desc or "-"),
                  ("ft: %s"):format(ft),
                  ("type: %s"):format(kind),
                }, "\n")
              end

              items[#items + 1] = {
                idx = idx,
                score = 1000,
                text = ("%s  —  %s  [%s]"):format(trig, desc ~= "" and desc or trig, ft),
                trig = trig,
                desc = desc ~= "" and desc or trig,
                ft = ft,
                kind = kind,
                preview = {
                  text = preview_text,
                  ft = ft == "" and nil or ft,
                  loc = false,
                },
              }
            end
          end
        end

        for _, ft in ipairs(fts) do
          local ok1, reg = pcall(ls.get_snippets, ft)
          if ok1 then
            add_snips(ft, reg, "snippet")
          end

          local ok2, auto = pcall(ls.get_snippets, ft, { type = "autosnippets" })
          if ok2 then
            add_snips(ft, auto, "autosnippet")
          end
        end

        if #items == 0 then
          items = {
            {
              idx = 1,
              score = 1000,
              text = "No LuaSnip snippets found for this buffer",
              preview = { text = "No snippets loaded for: " .. table.concat(fts, ", "), loc = false },
            },
          }
        end

        Snacks.picker.pick({
          title = "LuaSnip Snippets",
          items = items,
          format = "text",
          preview = "preview",
          layout = { preset = "vscode" },
          confirm = function(picker, item)
            picker:close()
            if not item or not item.trig then
              return
            end
            vim.fn.setreg('"', item.trig)
            vim.fn.setreg("+", item.trig)
            vim.notify("Copied snippet trigger: " .. item.trig)
          end,
        })
      end,
      desc = "Snippets (LuaSnip)",
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
              local items_ = {
                "Absolute path: " .. values[1],
                "Path relative to CWD: " .. values[2],
                "Path relative to HOME: " .. values[3],
                "Filename: " .. values[4],
              }
              if vim.fn.isdirectory(filepath) == 0 then
                vim.list_extend(items_, {
                  "Filename without extension: " .. values[5],
                  "Extension of the filename: " .. values[6],
                })
              end
              vim.ui.select(items_, { prompt = "Choose to copy to clipboard:" }, function(choice, i)
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
          ignored = true,
          ui = {
            indent = {
              enabled = false,
            },
            icons = {
              indent = {
                enabled = false,
              },
            },
          },
          exclude = {
            ".git",
            "**/.git/",
            ".DS_Store",
            "**/.DS_Store",
          },
          layout = {
            box = "vertical",
            auto_hide = { "input" },
            layout = {
              width = 30,
              height = 100,
            },
          },
        },
      },
    },
  },
}
