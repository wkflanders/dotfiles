return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts = opts or {}
      opts.ensure_installed = opts.ensure_installed or {}
      if not vim.tbl_contains(opts.ensure_installed, "solidity") then
        table.insert(opts.ensure_installed, "solidity")
      end
    end,
  },

  -- Mason (use mason-org)
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.ensure_installed = opts.ensure_installed or {}
      local want = {
        "nomicfoundation-solidity-language-server",
      }
      for _, pkg in ipairs(want) do
        if not vim.tbl_contains(opts.ensure_installed, pkg) then
          table.insert(opts.ensure_installed, pkg)
        end
      end
    end,
  },

  -- LSP: Nomic Foundation
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local util = require("lspconfig.util")
      opts = opts or {}
      opts.servers = opts.servers or {}
      opts.setup = opts.setup or {}

      -- block accidental solc “server”
      opts.setup.solc = function()
        return true
      end
      opts.servers.solidity = false
      opts.servers.solidity_ls = false
      opts.servers.vscode_solidity_server = false

      local roots = util.root_pattern(
        "foundry.toml",
        "hardhat.config.ts",
        "hardhat.config.js",
        "truffle-config.js",
        "package.json",
        ".git"
      )

      opts.servers.solidity_ls_nomicfoundation = {
        cmd = { "nomicfoundation-solidity-language-server", "--stdio" },
        filetypes = { "solidity" },
        root_dir = function(fname)
          return roots(fname) or vim.fs.dirname(fname)
        end,
      }

      -- ensure *.sol gets the right filetype
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        group = vim.api.nvim_create_augroup("SolidityFiletype", { clear = true }),
        pattern = "*.sol",
        callback = function()
          if vim.bo.filetype ~= "solidity" then
            vim.bo.filetype = "solidity"
          end
        end,
      })

      -- force-start if not attached (Neovim 0.10+ APIs)
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("SolidityForceLsp", { clear = true }),
        pattern = "solidity",
        callback = function(args)
          local bufnr = args.buf
          local attached = false
          for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            if c.name == "solidity_ls_nomicfoundation" then
              attached = true
              break
            end
          end
          if not attached then
            -- use the user-facing command; works across LazyVim setups
            vim.cmd("LspStart solidity_ls_nomicfoundation")
          end
        end,
      })
    end,
  },

  -- Formatting: forge fmt via Conform (stdin)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        forge_fmt = {
          command = "forge",
          args = { "fmt", "--raw", "-" },
          stdin = true,
        },
      },
      formatters_by_ft = {
        solidity = { "forge_fmt" },
      },
    },
  },

  -- Linting: solhint via nvim-lint
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts = opts or {}
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.solidity = { "solhint" }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("SolidityLint", { clear = true }),
        pattern = "*.sol",
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
