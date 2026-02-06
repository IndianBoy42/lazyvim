return {
  {
    "chrisgrieser/nvim-spider",
    -- TODO: subword hydra
    opts = { skipInsignificantPunctuation = true },
    config = function(_, opts)
      require("spider").setup(opts)
      require("hydra")({
        name = "Subwords",
        mode = "n",
        hint = false,
        body = "<Plug>(spider)",
        heads = {
          { "w", "<cmd>lua require('spider').motion('w')<cr>", desc = "Spider-w" },
          { "e", "<cmd>lua require('spider').motion('e')<cr>", desc = "Spider-e" },
          { "b", "<cmd>lua require('spider').motion('b')<cr>", desc = "Spider-b" },
          { "g", "<cmd>lua require('spider').motion('ge')<cr>", desc = "Spider-ge" },
        },
      })
    end,
    keys = { "<Plug>(spider)" },
  },
}
