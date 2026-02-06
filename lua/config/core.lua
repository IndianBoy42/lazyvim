-- Core configuration for Neovim
-- This file contains the global config table with essential settings

local O = {}

-- OS detection
O.os = {
  is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1,
  is_unix = vim.fn.has("unix") == 1,
  is_mac = vim.fn.has("mac") == 1,
}

-- Home path
O.home = vim.fn.expand("~")

-- Leader keys (defined in settings.lua but also referenced here for plugins)
O.leader_key = "<space>"
O.local_leader_key = "<backspace>"

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

-- Make the config table read-only to prevent accidental modifications
return setmetatable(O, {
  __index = O,
  __newindex = function(t, k, v)
    error("attempt to update a read-only table", 2)
  end,
})
