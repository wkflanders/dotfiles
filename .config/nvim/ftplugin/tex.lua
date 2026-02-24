vim.opt_local.synmaxcol = 0

vim.opt_local.spell = true
vim.opt_local.wrap = true
vim.opt_local.linebreak = true

do
  local ok, surround = pcall(require, "nvim-surround")
  if ok then
    surround.buffer_setup({
      surrounds = {
        -- LaTeX environments: yse{env}  (prompts for env name)
        ["e"] = {
          add = function()
            local env = vim.fn.input("Environment: ")
            if env == nil or env == "" then
              env = "env"
            end
            return { { "\\begin{" .. env .. "}" }, { "\\end{" .. env .. "}" } }
          end,
        },

        -- TeX quotes
        ["Q"] = {
          add = { "``", "''" },
          find = "%b``.-''",
          delete = "^(``)().-('')()$",
        },
        ["q"] = {
          add = { "`", "'" },
          find = "`.-'",
          delete = "^(`)().-(')()$",
        },

        -- Text formatting
        ["b"] = {
          add = { "\\textbf{", "}" },
          find = "\\%a-bf%b{}",
          delete = "^(\\%a-bf{)().-(})()$",
        },
        ["i"] = {
          add = { "\\textit{", "}" },
          find = "\\%a-it%b{}",
          delete = "^(\\%a-it{)().-(})()$",
        },
        ["t"] = {
          add = { "\\texttt{", "}" },
          find = "\\%a-tt%b{}",
          delete = "^(\\%a-tt{)().-(})()$",
        },

        ["$"] = { add = { "$", "$" } },
      },
    })
  end
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "tex" })
end

local function vimtex_root()
  if type(vim.b.vimtex) == "table" and vim.b.vimtex.root and vim.b.vimtex.root ~= "" then
    return vim.b.vimtex.root
  end
  return vim.fn.getcwd()
end

local function vimtex_main()
  if type(vim.b.vimtex) == "table" then
    if vim.b.vimtex.tex and vim.b.vimtex.tex ~= "" then
      return vim.b.vimtex.tex
    end
    if vim.b.vimtex.main and vim.b.vimtex.main ~= "" then
      return vim.b.vimtex.main
    end
  end

  -- Fallback: try VimTeX context (safe-guarded)
  local ok_ctx, ctx = pcall(function()
    return vim.fn["vimtex#context#get"]()
  end)
  if ok_ctx and type(ctx) == "table" and ctx.main and ctx.main ~= "" then
    return ctx.main
  end

  -- Last resort: current file
  return vim.fn.expand("%:p")
end

local function lcd_to_root()
  local root = vimtex_root()
  vim.cmd.lcd(vim.fn.fnameescape(root))
  notify("lcd → " .. root)
end

local function edit_main()
  local main = vimtex_main()
  if not main or main == "" then
    notify("Could not determine main TeX file", vim.log.levels.WARN)
    return
  end
  vim.cmd.edit(vim.fn.fnameescape(main))
end

local function pick_bib()
  local root = vimtex_root()
  local bibs = vim.fs.find(function(name)
    return name:match("%.bib$")
  end, { path = root, type = "file", limit = 20 })

  if not bibs or #bibs == 0 then
    notify("No .bib files found under: " .. root, vim.log.levels.WARN)
    return
  end

  if #bibs == 1 then
    vim.cmd.edit(vim.fn.fnameescape(bibs[1]))
    return
  end

  vim.ui.select(bibs, {
    prompt = "Open bibliography:",
    format_item = function(p)
      return vim.fn.fnamemodify(p, ":~:.")
    end,
  }, function(choice)
    if choice then
      vim.cmd.edit(vim.fn.fnameescape(choice))
    end
  end)
end

local function latexindent_format()
  if vim.fn.executable("latexindent") ~= 1 then
    notify("latexindent not found in PATH", vim.log.levels.WARN)
    return
  end

  -- Run latexindent on the current file.
  local file = vim.fn.expand("%:p")
  if file == "" then
    notify("No file path for current buffer", vim.log.levels.WARN)
    return
  end

  -- Save first, then format on disk, then reload.
  vim.cmd.write()
  local cmd = { "latexindent", "-w", file }
  local out = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    notify("latexindent failed:\n" .. tostring(out), vim.log.levels.ERROR)
    return
  end

  vim.cmd.edit()
  notify("Formatted with latexindent")
end

vim.keymap.set("n", "<localleader>pr", lcd_to_root, { buffer = true, desc = "Project: lcd to root" })
vim.keymap.set("n", "<localleader>pm", edit_main, { buffer = true, desc = "Project: open main.tex" })
vim.keymap.set("n", "<localleader>bb", pick_bib, { buffer = true, desc = "Bib: open .bib" })
vim.keymap.set("n", "<localleader>ff", latexindent_format, { buffer = true, desc = "Format: latexindent" })

-- which-key labels ------------------------------------------------------------
do
  local ok, wk = pcall(require, "which-key")
  if ok then
    wk.add({
      { "<localleader>p", group = "project", buffer = 0 },
      { "<localleader>b", group = "bib", buffer = 0 },
      { "<localleader>f", group = "format", buffer = 0 },
      { "<localleader>pr", lcd_to_root, desc = "lcd to root", buffer = 0 },
      { "<localleader>pm", edit_main, desc = "open main.tex", buffer = 0 },
      { "<localleader>bb", pick_bib, desc = "open .bib", buffer = 0 },
      { "<localleader>ff", latexindent_format, desc = "latexindent", buffer = 0 },
    })
  end
end
