return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            -- Disable a keymap
            { "<m-n>", false },
          },
        },
      },
    },
  },
  { -- "IndianBoy42/actions-preview.nvim",
    "aznhe21/actions-preview.nvim",
    opts = function()
      return {
        highlight_command = {
          require("actions-preview.highlight").delta(),
          -- require("actions-preview.highlight").diff_so_fancy(),
          -- require("actions-preview.highlight").diff_highlight(),
        },
      }
    end,
    keys = {
      {
        "co",
        function()
          require("actions-preview").code_actions()
        end,
        desc = "Actions Previewed",
      },
      {
        "K",
        function()
          require("actions-preview").code_actions()
        end,
        mode = "x",
        desc = "Actions Previewed",
      },
    },
  },
  -- TODO: https://github.com/jan-xyz/lsp-preview.nvim/tree/main
  -- TODO: https://github.com/DNLHC/glance.nvim
}
