return {
  "mikesmithgh/kitty-scrollback.nvim",
  build = ":KittyScrollbackGenerateKittens",
  cmd = {
    "KittyScrollbackGenerateKittens",
    "KittyScrollbackCheckHealth",
    "KittyScrollbackGenerateCommandLineEditing",
  },
  event = { "User KittyScrollbackLaunch" },
  opts = {
    {
      callbacks = {
        after_paste_window_ready = (function()
          local once = true
          return function(paste_window_data, kitty_data, opts)
            if once then
              once = false
              vim.keymap.set(
                "n",
                "<esc>",
                "<C-w>k",
                { desc = "Back to the scrollback", buffer = paste_window_data.paste_window.bufid }
              )
            end
          end
        end)(),
      },
    },
  },
}
