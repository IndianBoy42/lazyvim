local function custom_surroundings()
  local ms = require("mini.surround")
  local ts_input = ms.gen_spec.input.treesitter
  local tsi = function(id)
    return ts_input({ outer = id .. ".outer", inner = id .. ".inner" })
  end

  return {
    -- With Spaces
    [")"] = { output = { left = "(", right = ")" } },
    ["}"] = { output = { left = "{", right = "}" } },
    ["]"] = { output = { left = "[", right = "]" } },

    -- TODO: output
    c = {
      input = tsi("@call"),
      output = function()
        local fun_name = MiniSurround.user_input("Function name")
        if fun_name == nil then
          return nil
        end
        return { left = ("%s("):format(fun_name), right = ")" }
      end,
    },
    f = { input = tsi("@function") },
    B = { input = { "%b{}", "^.%s*().-()%s*.$" }, output = { left = "{ ", right = " }" } },

    -- o = {
    --   input = ts_input {
    --     outer = { "@block.outer", "@conditional.outer", "@loop.outer" },
    --     inner = { "@block.inner", "@conditional.inner", "@loop.inner" },
    --   },
    -- },
    -- TODO: jupyter cells
  }
end

return {
  {
    "mini.surround",
    keys = function(_, keys)
      local mappings = {
        { O.surrounds.add, desc = "Add surrounding" },
        { O.surrounds.vadd, desc = "Add surrounding", mode = { "x" } },
        { O.surrounds.vadd2, desc = "Add surrounding", mode = { "x" } },
        { O.surrounds.delete, desc = "Delete surrounding" },
        { O.surrounds.find, desc = "Find right surrounding" },
        { O.surrounds.find_left, desc = "Find left surrounding" },
        { O.surrounds.highlight, desc = "Highlight surrounding" },
        { O.surrounds.replace, desc = "Replace surrounding" },
        { O.surrounds.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
    opts = function()
      return {
        custom_surroundings = custom_surroundings(),
        mappings = O.surrounds,
        n_lines = 9999,
      }
    end,
    config = function(_, opts)
      require("mini.surround").setup(opts)
      -- Remap adding surrounding to Visual mode selection
      local map = vim.keymap.set
      vim.api.nvim_del_keymap("x", opts.mappings.add)
      map("x", opts.mappings.vadd, [[:<C-u>lua MiniSurround.add('visual')<CR>]], { noremap = true, silent = true })
      if opts.mappings.vadd2 then
        map("x", "S", [[:<C-u>lua MiniSurround.add('visual')<CR>]], { noremap = true, silent = true })
      end
      -- map("x", "(", opts.mappings.vadd .. [[(]], { remap = true, silent = true })
      -- map("x", "{", opts.mappings.vadd .. [[{]], { remap = true, silent = true })
      -- map("x", "[", opts.mappings.vadd .. [[[]], { remap = true, silent = true })
      -- map("x", '"', opts.mappings.vadd .. [["]], { remap = true, silent = true })
      -- map("x", "'", opts.mappings.vadd .. [[']], { remap = true, silent = true })

      -- Make special mapping for "add surrounding for line"
      map("n", "yss", "ysil", { remap = true, silent = true })
    end,
  },
}
