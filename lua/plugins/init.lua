return {
  -- TODO: https://github.com/code-biscuits/nvim-biscuits
  { "nvimtools/hydra.nvim", lazy = false },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "just",
        "typst",
        "cmake",
        "make",
      })
    end,
  },
  {
    "mason.nvim",
    opts = function(_, opts)
      -- add tsx and treesitter
      vim.list_extend(opts.ensure_installed, {
        "just-lsp",
      })
    end,
  },
  { "nvim-mini/mini.extra", version = "*" },
  {
    "tzachar/highlight-undo.nvim",
    opts = {},
  },
  {
    "Aasim-A/scrollEOF.nvim",
    opts = {},
  },
  {
    "chrisgrieser/nvim-early-retirement",
    config = true,
    event = "VeryLazy",
  },
}
