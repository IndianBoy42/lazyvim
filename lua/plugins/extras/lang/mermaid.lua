return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "mermaid" } },
  },
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "mmdc" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        mmdc = {
          settings = {},
        },
      },
    },
  },
}
