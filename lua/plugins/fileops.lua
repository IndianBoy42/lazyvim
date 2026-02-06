return {
  { "jghauser/mkdir.nvim", event = "BufWritePre" },
  { "lambdalisue/suda.vim", event = "BufWritePre", cmd = { "SudaWrite", "SudaRead" } },
  {
    "chrisgrieser/nvim-genghis",
    init = function()
      local function abbr(lhs, rhs)
        vim.keymap.set("ca", lhs, function()
          if vim.fn.getcmdtype() == ":" then
            return "Genghis " .. rhs
          else
            return lhs
          end
        end, { expr = true })
        -- TODO: create a forwarding command (or make it not work in search mode)
      end
      abbr("New", "createNewFile")
      abbr("Move", "moveAndRenameFile")
      abbr("Rename", "renameFile")
      abbr("Trash", "trashFile")
      -- TODO: Snacks rename file
      -- Snacks.rename.on_rename_file(from, to, rename)
    end,
    opts = {},
    cmd = {
      "Genghis",
    },
  },
}
