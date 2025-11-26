return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        yamlls = {
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              schemaStore = {
                enable = false,
                url = "",
              },
              validate = true,
              schemas = {}, -- no remote schemas at all
            },
          },
        },
      },
    },
  },
}
