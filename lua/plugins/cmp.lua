return {
  "blink.cmp",
  opts = {
    keymap = {
      preset = "super-tab",
      -- TODO: port my old config
      -- ['<Up>'] = { 'select_prev', 'fallback' },
      -- ['<Down>'] = { 'select_next', 'fallback' },
      --
      -- -- disable a keymap from the preset
      -- ['<C-e>'] = false, -- or {}
      --
      -- -- show with a list of providers
      -- ['<C-space>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },
      --
      -- -- control whether the next command will be run when using a function
      -- ['<C-n>'] = {
      --   function(cmp)
      --     if some_condition then return end -- runs the next command
      --     if some_other_condition then return "a" end -- simulate keypresses, doesn't run the next command
      --     return true -- doesn't run the next command
      --   end,
      --   'select_next'
      -- },
    },
  },
}
