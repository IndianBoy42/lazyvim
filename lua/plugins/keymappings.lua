return {
  "zdcthomas/yop.nvim", -- User operators, TODO: port from my own impl maybe
  {
    "max397574/better-escape.nvim",
    opts = function()
      local kj = {
        j = {
          -- These can all also be functions
          k = "<Esc>",
        },
        k = { j = "<Esc>" },
      }
      return {
        default_mappings = false,
        mappings = {
          i = kj,
          c = kj,
          t = kj,
          -- TODO: investigate if double-esc can be done here
        },
      }
    end,
    event = "InsertEnter",
  },
  {
    -- Search for mnemonic keymaps
    "tris203/hawtkeys.nvim",
    opts = {
      -- an empty table will work for default config
      --- if you use functions, or whichkey, or lazy to map keys
      --- then please see the API below for options
    },
    cmd = { "Hawtkeys", "HawtkeysAll" },
  },
  {
    "indianboy42/keymap-amend.nvim",
    config = function()
      local a = require("keymap-amend")
      vim.keymap.amend = a.amend
      vim.keymap.get = a.get
    end,
    lazy = false,
  },
}
