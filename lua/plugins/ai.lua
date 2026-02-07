return {
  -- {
  --   "sidekick.nvim",
  --   opts = {},
  -- },
  {
    "copilotlsp-nvim/copilot-lsp",
    init = function()
      vim.g.copilot_nes_debounce = 500
    end,
  },
  {
    "copilot.lua",
    keys = {},
    opts = {
      nes = {
        enabled = true,
        keymap = {
          accept_and_goto = "<leader>aa",
          accept = "<m-;>",
          dismiss = "<Plug>(copilot-dismiss-nes)",
        },
      },
    },
  },
}
