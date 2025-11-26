return {
  "lervag/vimtex",

  init = function()
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_view_skim_sync = 1
    vim.g.vimtex_view_skim_activate = 1

    vim.g.vimtex_format_enabled = true
    vim.g.vimtex_format_program = "latexindent"

    vim.g.vimtex_indent_enabled = false
    vim.g.tex_flavor = "latex"

    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_compiler_latexmk = {
      build_dir = "build",
      out_dir = "build",
      aux_dir = "build",
      options = {
        "-xelatex",
        "-interaction=nonstopmode",
        "-file-line-error",
        "-synctex=1",
      },
    }

    vim.g.vimtex_quickfix_mode = 0
  end,

  config = function()
    local grp = vim.api.nvim_create_augroup("LatexSpell", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = grp,
      pattern = { "tex", "plaintex", "latex" },
      callback = function()
        vim.opt_local.spell = true
        vim.opt_local.spelllang = { "en_us" }
        vim.opt_local.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"

        -- insert: fix previous misspelling, first suggestion
        vim.keymap.set("i", "\\ls", "<c-g>u<Esc>[s1z=`]a<c-g>u", { buffer = true, silent = true })

        -- normal: next / previous misspelling
        vim.keymap.set("n", "\\ln", "]s", { buffer = true, silent = true })
        vim.keymap.set("n", "\\lp", "[s", { buffer = true, silent = true })

        -- normal: fix current word with first suggestion
        vim.keymap.set("n", "\\l1", "1z=", { buffer = true, silent = true })

        -- normal: fix all misspellings in buffer (first suggestion)
        vim.keymap.set("n", "\\lS", function()
          local cur = vim.api.nvim_win_get_cursor(0)
          vim.cmd("normal! gg")
          while true do
            vim.cmd("normal! ]s")
            local bad = vim.fn.spellbadword()
            if bad[1] == "" or bad[2] == "" then
              break
            end
            vim.cmd("normal! 1z=")
          end
          pcall(vim.api.nvim_win_set_cursor, 0, cur)
        end, { buffer = true, silent = true })
      end,
    })
  end,
}
