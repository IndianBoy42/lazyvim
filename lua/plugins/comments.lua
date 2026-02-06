local cmt_op = O.commenting.op
local cmt_vi = O.commenting.vi
local cmt_li = O.commenting.line
local cmt_to = O.commenting.obj
return {
  "nvim-mini/mini.comment",
  optional = true,
  opts = {
    mappings = {
      comment = cmt_op,
      comment_visual = cmt_vi,
      comment_line = cmt_li,
      textobject = cmt_to,
    },

    -- Hook functions to be executed at certain stage of commenting
    -- hooks = {
    --   pre = function() require("ts_context_commentstring.internal").update_commentstring {} end,
    -- },
  },
  config = function(_, opts)
    require("mini.comment").setup(opts)

    local map = vim.keymap.set
    map(
      "x",
      O.commenting.copy.vi,
      -- TODO: dot repeatable
      -- TODO: make it a function
      '"zy' -- Yank it
        .. "mz" -- Remember the original position
        .. "`<" -- Go back to the original position
        .. '"zP' -- Duplicate above
        .. "`[V`]" -- reselect original
        .. ":<C-u>lua MiniComment.operator('visual')<CR>" -- Comment it
        .. "`z",
      -- function()
      --   _G.__commenting_copy_opfunc = vim.schedule_wrap(function()
      --     local keys = '"zy' -- Yank it
      --       .. "mz" -- Remember the original position
      --       .. "`<" -- Go back to the original position
      --       .. '"zP' -- Duplicate above
      --       .. "`[V`]" -- reselect original
      --       .. ":<C-u>lua MiniComment.operator('visual')<CR>" -- Comment it
      --       .. "`z"
      --     vim.api.nvim_feedkeys(vim.keycode(keys), "n", false)
      --   end)
      --   vim.go.operatorfunc = "v:lua.__commenting_copy_opfunc"
      --   return "g@"
      -- end, -- Go back to the original position
      { desc = "copy and comment" }
    )
    map(
      "n",
      O.commenting.copy.op,
      -- TODO: dot repeatable
      utils.operatorfunc_Vkeys(O.commenting.copy.vi),
      { desc = "copy and comment op", expr = true }
    )
    map("n", O.commenting.copy.line, "V" .. O.commenting.copy.vi, { remap = true, desc = "copy and comment line" })
  end,
}
