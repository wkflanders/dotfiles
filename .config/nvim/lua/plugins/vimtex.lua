return {
  {
    "lervag/vimtex",

    init = function()
      vim.g.vimtex_view_method = "sioyek"

      vim.g.vimtex_complete_enabled = 1

      vim.g.vimtex_indent_enabled = false
      vim.g.tex_indent_items = false
      vim.g.tex_indent_brace = false

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
      vim.g.vimtex_quickfix_ignore_filters = {
        "Underfull",
        "Overfull",
        "specifier changed to",
        "Token not allowed in a PDF string",
        "Package hyperref Warning",
      }
      vim.g.vimtex_log_ignore = {
        "Underfull",
        "Overfull",
        "specifier changed to",
        "Token not allowed in a PDF string",
      }

      vim.g.vimtex_mappings_enabled = true
      vim.g.tex_flavor = "latex"
    end,
  },
}
