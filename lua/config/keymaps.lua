-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local K = require("keymaps")
local map = K.set
local mapl = K.setl

require("keymaps.nN_repeat").setup()

K.set("n", O.quicksave, "<cmd>wa<cr>", { desc = "Save All" })
K.set("n", "<leader><cr>", function()
  Snacks.picker.smart()
end, { desc = "Smart Find Files" })
K.set("n", ";", ":", { desc = "Quicker Cmdline" })
map("n", "<c-c>", "<C-w>q", {})
K.set("n", "<c-q>", "<C-w>q", { desc = "Close Window" })
K.set("n", "<tab>", "<cmd>e #<cr>", { desc = "Other Buffer" })
map("n", "<S-tab>", require("keymaps.buffer_mode").tab_new_or_next, { desc = "Next Tab" })
-- Leader shortcut for ][ jumping and )( swapping
map("n", "<leader>j", O.goto_next, { remap = true, desc = "Jump next (])" })
map("n", "<leader>k", O.goto_previous, { remap = true, desc = "Jump prev ([)" })
map("n", "<leader>J", O.goto_next_outer, { remap = true, desc = "Jump next outer (]])" })
map("n", "<leader>K", O.goto_previous_outer, { remap = true, desc = "Jump prev outer ([[)" })

map("x", "<M-p>", "pgv", { desc = "Paste and keep" })

local resize_prefix = "<C-"
if vim.fn.has("mac") == 1 then
  resize_prefix = "<M-"
end
map("n", resize_prefix .. "Up>", "<cmd>resize -2<cr>", {})
map("n", resize_prefix .. "Down>", "<cmd>resize +2<cr>", {})
map("n", resize_prefix .. "Left>", "<cmd>vertical resize -2<cr>", {})
map("n", resize_prefix .. "Right>", "<cmd>vertical resize +2<cr>", {})

-- Keep accidentally hitting J instead of j when first going visual mode
map("x", "J", "j")
map("x", "<M-j>", "J")

require("keymaps.smart_x")
require("keymaps.smart_esc")

-- Jumplist
map("n", "<M-h>", "<c-o>", {})
map("n", "<M-l>", "<c-i>", {})
-- TODO: hydra jumplist and changelist

-- Add meta version that doesn't affect the clipboard
local function dont_clobber_if_meta(m, c)
  if string.upper(c) == c then
    map(m, "<M-S-" .. string.lower(c) .. ">", '"_' .. c, {})
  else
    map(m, "<M-" .. c .. ">", '"_' .. c, {})
  end
end

-- Make the default not touch the clipboard, and add a meta version that does
local function dont_clobber_by_default(m, c)
  if string.upper(c) == c then
    map(m, "<M-S-" .. string.lower(c) .. ">", c, {})
  else
    map(m, "<M-" .. c .. ">", c, {})
  end
  -- map(m, c, '"_' .. c, {})
  vim.keymap.amend(m, c, function(orig)
    vim.feedkeys('"_', "ni") -- FIXME:
    vim.schedule(orig)
  end)
end

-- Search textobject
map("n", "<leader>*", utils.operatorfunc_keys("*"), { desc = "Search (op)", expr = true })

-- Continue the search and keep selecting (equivalent ish to doing `gn` in normal)
-- TODO: select the current search match if not selected
map("x", "n", "<esc>ngn", {})
map("x", "N", "<esc>NgN", {})
-- Select the current/next search match
map("x", "gn", "<esc>gn", {})
map("x", "gN", "<esc>NNgN", {}) -- current/prev

-- Repeat the recent edit with cgn
map("n", "g.", [[/\V<C-r>"<CR>]] .. "cgn<C-a><ESC>", { desc = "Repeat change" })

-- Start search and replace from search
map("c", "<M-r>", function()
  local mode = vim.fn.getcmdtype()
  if mode == "/" or mode == "?" then
    return [[<cr>:%s/<C-R>///g<Left><Left>]]
  else
    return ""
  end
end, { expr = true, desc = "and Replace" })
map("c", "<M-t>", function()
  local mode = vim.fn.getcmdtype()
  if mode == "/" or mode == "?" then
    -- TODO: from flash fuzzy search
    return [[<cr><leader>s/]]
  else
    return ""
  end
end, { expr = true, remap = true, desc = "to Telescope" })

dont_clobber_if_meta("n", "d")
dont_clobber_if_meta("n", "D")
dont_clobber_if_meta("x", "r")
-- dont_clobber_by_default("n", "c")
-- dont_clobber_by_default("x", "c")
-- dont_clobber_by_default("n", "C")

if false then
  -- move along visual lines, not numbered ones
  -- without interferring with {count}<down|up>
  map("n", "<up>", "v:count == 0 ? 'gk' : '<up>'", { expr = true })
  map("x", "<up>", "v:count == 0 ? 'gk' : '<up>'", { expr = true })
  map("n", "<down>", "v:count == 0 ? 'gj' : '<down>'", { expr = true })
  map("x", "<down>", "v:count == 0 ? 'gj' : '<down>'", { expr = true })
end

local function map_fast_indent()
  -- print "Setting up better indenting"
  mapl("n", ">", ">>", { nowait = true })
  mapl("n", "<", "<<", { nowait = true })
end
-- better indenting
-- FIXME: broken with autosession??
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "BufReadPost", "BufNewFile" }, {
  callback = map_fast_indent,
})
map("n", "g<", "<", {})
map("n", "g>", ">", {})
map("x", "<", "<gv", {})
map("x", ">", ">gv", {})

map("n", "<M-r>", function()
  -- TODO: use treesitter to detect identifiers
  local new_name = vim.fn.expand("<cword>")
  vim.cmd("undo!")
  vim.lsp.buf.rename(new_name)
end, { desc = "Rename after" })
map("i", "<M-r>", "<esc><M-r>", { remap = true, desc = "Rename after" })

-- Select last pasted
-- TODO: use yanky
map("x", "<leader>vo", "`[o`]", { desc = "Select Last Paste/Op" })
map("x", "<leader>vO", "V`[o`]", { desc = "SelLine Last Paste/Op" })
map("x", "<leader>v<C-o>", "<C-v>`[o`]", { desc = "SelBlock Last Paste/Op" })
map("n", "<leader>vo", "v`[o`]", { desc = "Select Last Paste/Op" })
map("n", "<leader>vO", "V`[o`]", { desc = "SelLine Last Paste/Op" })
map("n", "<leader>v<C-o>", "<C-v>`[o`]", { desc = "SelBlock Last Paste/Op" })
-- Use reselect as an operator
K.op_from("<leader>p")
K.op_from("<leader>P")
K.op_from("<leader><C-p>")

map("n", "gv", "'<v'>", {})
-- Reselect visual linewise
map("n", "gV", "'<V'>", {})
map("x", "gV", "<esc>gV", {})
-- Reselect visual block wise
map("n", "g<C-v>", "'<C-v>'>", {})
map("x", "g<C-v>", "<esc>g<C-v>", {})

map({ "n", "x", "o" }, "<c-e>", "ge", {})
map({ "n", "x", "o" }, "<c-s-e>", "gE", {})

local function undo_brkpt(key)
  -- map("i", key, key .. "<c-g>u", {})
  map("i", key, "<c-g>u" .. key, {})
end
local undo_brkpts = {
  "<cr>",
  ",",
  ".",
  ";",
  "{",
  "}",
  "[",
  "]",
  "(",
  ")",
  "'",
  '"',
}
for _, v in ipairs(undo_brkpts) do
  undo_brkpt(v)
end

-- Keymaps for easier access to 'ci' and 'di'
local function quick_inside(key, no_v)
  map("o", key, "i" .. key, { remap = true })
  if not no_v then
    -- TODO: weirdly buggy with mini.surround
    -- map("x", key, "i" .. key, { remap = true })
  end
  map("n", "<M-" .. key .. ">", "vi" .. key, { remap = true })
end

local function quick_around(key)
  map("o", key, "a" .. key, { remap = true })
  if not no_v then
    -- TODO: weirdly buggy with mini.surround
    map("x", key, "i" .. key, { remap = true })
  end
  map("n", "<M-" .. key .. ">", "va" .. key, { remap = true })
end

quick_inside("w")
quick_inside("W")
-- quick_inside("p", true)
-- quick_inside "b"
-- quick_inside "B"
-- quick_inside "["
-- quick_around "]"
-- quick_inside "("
-- quick_around ")"
-- quick_inside "{"
-- quick_around "}"
-- quick_inside '"'
-- quick_inside "'"
-- quick_inside "<"
-- quick_inside ">"
-- quick_inside "q"

map("x", ".", ":normal .<CR>", {})

map("n", "dd", function()
  if vim.api.nvim_get_current_line():match("^%s*$") then
    return '"_dd'
  else
    return "dd"
  end
end, { noremap = true, expr = true })

map({ "n", "x" }, "=", "gq", { desc = "Format Op" })
map("n", "==", "gqq", { desc = "Format Line" })
map({ "n", "x" }, "gq", "=", { desc = "Indent Op" })
map("n", "gqq", "==", { desc = "Indent Line" })

map("c", "<c-a>", function()
  local line = vim.fn.getcmdline()
  local pos = vim.fn.getcmdpos()
  if line:sub(1, 1) == "%" then
    line = line:sub(2)
    pos = pos - 1
  else
    line = "%" .. line
    pos = pos + 1
  end
  vim.fn.setcmdline(line, pos)
  -- TODO: refresh inccomand
  return "i<bs>"
end, { expr = true, desc = "Toggle file range" })
map("c", "<c-v>", function()
  local line = vim.fn.getcmdline()
  local pos = vim.fn.getcmdpos()
  local prefix = "'<,'>"
  if line:sub(1, #prefix) == prefix then
    line = line:sub(#prefix + 1)
    pos = pos - #prefix
  else
    line = prefix .. line
    pos = pos + #prefix
  end
  vim.fn.setcmdline(line, pos)
  -- TODO: refresh inccomand
  return "i<bs>"
end, { expr = true, desc = "Toggle visual range" })

require("keymappings.scroll_mode").setup()
require("keymappings.fold_mode").setup()

map("n", "<leader>bs", function()
  Snacks.picker.buffers()
end, { desc = "Pick buffers" })

-- TODO: auto repeatable [] mappings

-- TODO: quickly run short commands
-- local short_cmd = require("keymaps.short_cmd")
-- map({ "x", "n" }, "'", short_cmd(), { desc = "Short command" })
-- map({ "x", "n" }, "!", short_cmd("!"), { desc = "Short command" })
