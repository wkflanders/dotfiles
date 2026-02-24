return {
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    config = function()
      local ls = require("luasnip")

      ls.config.set_config({
        history = false,
        enable_autosnippets = true,
        updateevents = "TextChanged,TextChangedI",
        region_check_events = "InsertEnter",
        delete_check_events = "InsertLeave",
      })

      require("luasnip.loaders.from_lua").lazy_load({
        paths = vim.fn.expand("~/.config/nvim/LuaSnip"),
      })

      vim.keymap.set("n", "<leader>U", function()
        require("luasnip.loaders.from_lua").load({
          paths = vim.fn.expand("~/.config/nvim/LuaSnip"),
        })
        vim.notify("Snippets refreshed!")
      end)
    end,
  },
}
