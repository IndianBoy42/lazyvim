local M = {}

F = loadstring

local feedkeys = vim.api.nvim_feedkeys
local t = vim.keycode

-- M.set_opfunc = vim.fn[vim.api.nvim_exec(
--   [[
-- func s:set_opfunc(val)
--     let &opfunc = a:val
-- endfunc
-- echon get(function('s:set_opfunc'), 'name')
-- ]],
--   true
-- )]
M.set_opfunc = function(val)
  if type(val) == "function" then
    M.__set_opfunc_callback = val
    vim.go.opfunc = "v:lua.utils.__set_opfunc_callback"
  end
end

-- TODO: improve this
function M.operatorfunc_helper_select(vmode)
  local start_row, start_col = unpack(vim.api.nvim_buf_get_mark(0, "["))
  local end_row, end_col = unpack(vim.api.nvim_buf_get_mark(0, "]"))

  vim.fn.setpos(".", { 0, start_row, start_col + 1, 0 })
  if type(vmode) == "string" then
    vim.cmd("normal! " .. vim.keycode(vmode))
  elseif vmode then
    vim.cmd("normal! V")
  else
    vim.cmd("normal! v")
  end
  if end_col == 1 then
    vim.fn.setpos(".", { 0, end_row - 1, -1, 0 })
  else
    vim.fn.setpos(".", { 0, end_row, end_col + 1, 0 })
  end
end

-- wrapper for making operators easily
function M.operatorfunc_scaffold(operatorfunc, op_pending)
  local wrapped = operatorfunc

  if op_pending == nil then
    return function()
      M.set_opfunc(wrapped)
      return "g@"
    end
  else
    return function()
      M.set_opfunc(wrapped)
      feedkeys(
        "g@" .. (op_pending and type(op_pending) == "string" and op_pending or ""),
        op_pending and type(op_pending) == "string" and "m" or "n",
        false
      )
      if type(op_pending) == "function" then
        op_pending()
      end
    end
  end
end

-- keys linewise
function M.operatorfunc_Vkeys(verbkeys, op_pending)
  return M.operatorfunc_scaffold(function()
    M.operatorfunc_helper_select(true)
    if #verbkeys > 0 then
      feedkeys(t(verbkeys), "m", false)
    end
  end, op_pending)
end

-- keys blockwise
function M.operatorfunc_cvkeys(verbkeys, op_pending)
  return M.operatorfunc_scaffold(function()
    M.operatorfunc_helper_select("<C-v>")
    if #verbkeys > 0 then
      feedkeys(t(verbkeys), "m", false)
    end
  end, op_pending)
end

-- keys charwise
function M.operatorfunc_keys(verbkeys, op_pending)
  return M.operatorfunc_scaffold(function()
    M.operatorfunc_helper_select(false)
    if #verbkeys > 0 then
      feedkeys(t(verbkeys), "m", false)
    end
  end, op_pending)
end

-- cmd linewise
function M.operatorfunc_Vcmd(verbkeys, op_pending)
  return M.operatorfunc_scaffold(function()
    M.operatorfunc_helper_select(true)
    vim.cmd(verbkeys)
  end, op_pending)
end

-- cmd charwise
function M.operatorfunc_cmd(verbkeys, op_pending)
  return M.operatorfunc_scaffold(function()
    M.operatorfunc_helper_select(false)
    vim.cmd(verbkeys)
  end, op_pending)
end

-- fn linewise
function M.operatorfunc_Vfn(func, op_pending)
  return M.operatorfunc_scaffold(function()
    M.operatorfunc_helper_select(true)
    func()
  end, op_pending)
end

-- fn charwise
function M.operatorfunc_fn(func, op_pending)
  return M.operatorfunc_scaffold(function()
    M.operatorfunc_helper_select(false)
    func()
  end, op_pending)
end

-- TODO: operator that when repeated does a replace instead
M.dual_operator = function(op1, op2)
  op1 = op1 or "y"
  op2 = op2 or "r"
  local is_repeat = false
  return function()
    _G.__repeatable_opfunc = function()
      if is_repeat then
        vim.api.nvim_feedkeys("`[" .. op2 .. "`]", "m", false)
      else
        vim.api.nvim_feedkeys("`[" .. op1 .. "`]", "m", false)
      end
    end
    vim.go.operatorfunc = "v:lua.__repeatable_opfunc"
    is_repeat = true
    return "g@"
  end
end

M.nav = require("utils.nav")

vim.feedkeys = function(keys, o)
  if o == nil then
    o = "m"
  end
  feedkeys(t(keys), o, false)
end

M.lsp_attach = function(on_attach, group)
  if type(group) == "string" then
    group = vim.api.nvim_create_augroup(group, { clear = true })
  end
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
    end,
  })
end

M.augrp = function(name, fn)
  local group = vim.api.nvim_create_augroup(name, { clear = true })
  fn(function(evt, opts)
    if type(opts) == "function" then
      opts = { callback = opts }
    end
    vim.api.nvim_create_autocmd(evt, vim.tbl_extend("force", { group = group }, opts))
  end)
end

return M
