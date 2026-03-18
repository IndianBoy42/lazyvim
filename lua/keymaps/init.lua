local M = {}

local keyset = vim.keymap.set
local keydel = vim.keymap.del
vim.keymap.set = function(mode, lhs, rhs, opts)
  keyset(mode, lhs, rhs, vim.tbl_extend("keep", opts or {}, { silent = true }))
end
vim.keymap.setl = function(mode, lhs, rhs, opts)
  keyset(mode, lhs, rhs, vim.tbl_extend("keep", opts or {}, { buffer = 0, silent = true }))
end
vim.keymap.dell = function(mode, lhs, rhs, opts)
  keydel(mode, lhs, vim.tbl_extend("keep", opts or {}, { buffer = 0, silent = true }))
end
vim.keymap.prefixed = function(prefix)
  return function(mode, lhs, rhs, opts)
    keyset(mode, prefix .. lhs, rhs, vim.tbl_extend("keep", opts or {}, { silent = true }))
  end
end
vim.keymap.prefixedl = function(prefix)
  return function(mode, lhs, rhs, opts)
    keyset(mode, prefix .. lhs, rhs, vim.tbl_extend("keep", opts or {}, { buffer = 0, silent = true }))
  end
end
vim.keymap.leader = vim.keymap.prefixed("<leader>")
vim.keymap.localleader = vim.keymap.prefixedl("<localleader>")

local mapl = vim.keymap.setl
local map = vim.keymap.set

local function obj_from(lhs, rhs, opts)
  opts = opts or {}
  rhs = rhs or lhs
  map("o", lhs, "<cmd>normal v" .. rhs .. "<cr>", opts)
end

M.obj_from = obj_from
local function sel_map(lhs, rhs, opts)
  opts = opts or {}

  map("x", lhs, rhs, opts)
  obj_from(lhs, rhs, opts)
end

M.sel_map = sel_map

return vim.tbl_extend("error", M, vim.keymap)
