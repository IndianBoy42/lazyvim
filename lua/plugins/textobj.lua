local custom_textobjects = function(ai)
  local s = ai.gen_spec
  local ts = s.treesitter
  local ex = require("mini.extra").gen_ai_spec

  return {
    k = ts({
      a = {
        "@function.outer",
        "@block.outer",
        "@class.outer",
        "@conditional.outer",
        "@loop.outer",
        "@return.outer",
      },
      i = {
        "@function.inner",
        "@block.inner",
        "@class.inner",
        "@conditional.inner",
        "@loop.inner",
        "@return.inner",
      },
    }, {}),
    j = ts({
      a = { "@parameter.outer", "@statement.outer", "@call.outer" },
      i = { "@parameter.inner", "@statement.inner", "@call.inner" },
    }, {}),
    -- a = ts({ a = "@parameter.outer", i = "@parameter.inner" }, {}),
    f = ts({ a = "@function.outer", i = "@function.inner" }, {}),
    -- C = ts({ a = "@class.outer", i = "@class.inner" }, {}),
    -- c = ts({ a = "@call.outer", i = "@call.inner" }, {}),
    -- c = s.function_call(),
    -- line textobject
    l = ex.line(),
    B = { "%b{}", "^.().*().$" },
    t = { "%b<>", "^.().*().$" },
    x = { "<(%w-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
    S = {
      {
        { "%u[%l%d]+[^%l%d]", "^().*()[^%l%d]$" },
        { "%S[%l%d]+[^%l%d]", "^%S().*()[^%l%d]$" },
        { "%P[%l%d]+[^%l%d]", "^%P().*()[^%l%d]$" },
        { "^[%l%d]+[^%l%d]", "^().*()[^%l%d]$" },
      },
    },
    -- Subword (TODO: 'a' variant)
    s = {
      {
        "%u[%l%d]+%f[^%l%d]",
        "%f[%S][%l%d]+%f[^%l%d]",
        "%f[%P][%l%d]+%f[^%l%d]",
        "^[%l%d]+%f[^%l%d]",
      },
      "^().*()$",
    },
    i = ex.indent(),
    e = ex.buffer(),
    d = ex.diagnostic(),
    N = ex.number(),
    -- B = function(ai_type)
    --   local n_lines = vim.fn.line "$"
    --   local start_line, end_line = 1, n_lines
    --   if ai_type == "i" then
    --     -- Skip first and last blank lines for `i` textobject
    --     local first_nonblank, last_nonblank = vim.fn.nextnonblank(1), vim.fn.prevnonblank(n_lines)
    --     start_line = first_nonblank == 0 and 1 or first_nonblank
    --     end_line = last_nonblank == 0 and n_lines or last_nonblank
    --   end
    --
    --   local to_col = math.max(vim.fn.getline(end_line):len(), 1)
    --   return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
    -- end,
    -- Code cell
    C = function(ai_type)
      local line_num = vim.fn.line(".")
      local first_line = 1
      local last_line = vim.fn.line("$")
      local line = vim.fn.getline(line_num)
      local cond = function(l)
        if l:len() > 3 then
          if l:sub(1, 4) == "# %%" then
            return true
          end
        end
        return false
      end
      local found_up = true

      -- Find first line in cell
      while not cond(line) do
        line_num = line_num - 1
        line = vim.fn.getline(line_num)
        if line_num == 1 then
          found_up = false
          break
        end
      end

      if not found_up then
        local cur_pos = vim.api.nvim_win_get_cursor(0)
        return {
          from = { line = cur_pos[1], col = cur_pos[2] + 1 },
        }
      end

      -- If inside, not include cell delimiter
      if ai_type == "i" then
        first_line = line_num + 1
      else
        first_line = line_num
      end

      -- Find last line in cell
      line_num = vim.fn.line(".")
      line = vim.fn.getline(line_num)
      local found_down = true
      while not cond(line) do
        if line_num == last_line then
          found_down = false
          break
        end
        line_num = line_num + 1
        line = vim.fn.getline(line_num)
      end
      local last_col = line:len()
      if found_down then
        last_line = line_num - 1
        line = vim.fn.getline(last_line)
        last_col = math.max(line:len(), 1)
      else
        last_col = math.max(last_col, 1)
      end
      return { from = { line = first_line, col = 1 }, to = { line = last_line, col = last_col } }
    end,
  }
end

return {
  "nvim-mini/mini.ai",
  dependencies = { "mini.extra" },
  opts = function(_, opts)
    local ai = require("mini.ai")
    return vim.tbl_deep_extend("force", opts, {
      n_lines = 1000,
      custom_textobjects = custom_textobjects(ai),
      search_method = "cover",
      mappings = {
        around = "a",
        inside = "i",
        around_next = O.select_next_outer, -- TODO: select_first.lua and repeatable
        inside_next = O.select_next,
        around_last = O.select_previous_outer,
        inside_last = O.select_previous,
        -- around_next = "an", -- TODO: select_first.lua and repeatable
        -- inside_next = "in",
        -- around_last = "aN",
        -- inside_last = "iN",
        goto_left = "",
        goto_right = "",
      },
      silent = true,
    })
  end,
}
