-- Core configuration for Neovim
-- This file contains the global config table with essential settings

local O = {}

vim.g.kitty_scrollback = vim.env.KITTY_SCROLLBACK_NVIM == "true"

-- Hint labels for hop/hint-based navigation
-- Optimized for home row keys with frequency-based ordering
O.hint_labels = "jklfdsahgnmervcxzbuioyptwq"

-- Convert hint_labels to array for plugins that need it
O.hint_labels_array = {}
for c in O.hint_labels:gmatch(".") do
  table.insert(O.hint_labels_array, c)
end

-- Commenting configuration with extended language support
O.commenting = {
  -- Core commenting mappings
  op = "yc", -- Operator pending mode
  vi = "C", -- Visual mode
  obj = "ic", -- Text object

  -- Extended language support (ported from old config)
  tsx = {
    filetypes = { "typescriptreact", "javascriptreact" },
    config = {
      jsx = true,
      tsx = true,
    },
  },

  -- C-style commenting (// for single line, /* */ for multi)
  c_style = {
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "java", "scala", "kotlin" },
  },

  -- Vue Single File Component support
  vue = {
    filetypes = { "vue" },
    -- Each section uses appropriate comment style
    sections = {
      template = "html", -- <!-- -->
      script = "javascript", -- // or /* */
      style = "css", -- /* */
    },
  },

  -- Markdown support (HTML comments)
  markdown = {
    filetypes = { "markdown", "mdx", "quarto", "rmd" },
    commentstring = "<!-- %s -->",
  },
}

-- Compute derived commenting mappings
local c = O.commenting
if c.vi == nil then
  c.vi = c.op
end
if c.line == nil then
  c.line = c.op .. c.op:sub(-1)
end
if c.obj == nil then
  c.obj = "i" .. c.op
end

-- Copy variants (prefixed with <leader>)
if c.copy == nil then
  c.copy = {}
end
local cc = c.copy
if cc.op == nil then
  cc.op = "<leader>" .. c.op
end
if cc.vi == nil then
  cc.vi = "<leader>" .. c.vi
end
if cc.line == nil then
  cc.line = "<leader>" .. c.line
end

O.surrounds = {
  add = "ys", -- Add surrounding in Normal and Visual modes
  vadd = "s", -- Add surrounding in Normal and Visual modes
  delete = "ds", -- Delete surrounding
  find = "]s", -- Find surrounding (to the right)
  find_left = "[s", -- Find surrounding (to the left)
  highlight = "<leader>vs", -- Highlight surrounding
  replace = "cs", -- Replace surrounding
  update_n_lines = "<leader>T<leader>n", -- Update `n_lines`
}

O.multi_leader_key = "_"
O.goto_prefix = "<cr>"
O.goto_next = "]"
O.goto_previous = "["
O.goto_next_outer = ")"
O.goto_previous_outer = "("
O.goto_next_end = "<leader>]" -- ")"
O.goto_previous_end = "<leader>[" -- "("
O.goto_next_outer_end = "<leader>)" -- "))"
O.goto_previous_outer_end = "<leader>)" -- "(("
O.select = "&"
O.select_dynamic = "v"
O.select_dynamic_around = "am"
O.select_remote = "r"
O.select_remote_dynamic = "m"
O.select_outer = "<M-S-7>" -- M-&
O.select_less = "<C-S-7>" -- C-&
O.select_next = "in"
O.select_previous = "iN"
O.select_next_outer = "an"
O.select_previous_outer = "aN"

O.hover_key = "H"
O.action_key = "K"
O.action_key_vis = "K"
-- TODO:?
-- O.hover_key = "K"
-- O.action_key = "co"
-- O.action_key_vis = "C"

O.quicksave = "<leader><leader>"

-- Make the config table read-only to prevent accidental modifications
return setmetatable(O, {
  __index = O,
  __newindex = function(t, k, v)
    error("attempt to update a read-only table", 2)
  end,
})
