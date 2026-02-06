local map = vim.keymap.set
local xcount = 0
local reg = '"x'
local not_repeat = true
local op = "v:lua.__merging_single_char_del"
_G.__merging_single_char_del = function()
  if not_repeat then
    not_repeat = false
  else
    vim.cmd("normal! " .. tostring(xcount) .. reg .. "x")
  end
end
local plug = vim.keycode("<Plug>(del-single-char)")
map("n", "x", function()
  vim.go.operatorfunc = op
  xcount = 1
  vim.api.nvim_feedkeys(reg .. "x", "n", false)
  vim.api.nvim_feedkeys(plug, "m", false)
end, { desc = "del single char" })
-- timed out, clear
map("n", "<Plug>(del-single-char)", function()
  not_repeat = true
  return "g@l"
end, { expr = true })
-- x was hit within the timeout
local cont = function()
  vim.cmd.undojoin()
  xcount = xcount + 1
  vim.api.nvim_feedkeys(reg:upper() .. "x", "n", false)
  vim.api.nvim_feedkeys(plug, "m", false)
end
map("n", "<Plug>(del-single-char)x", cont, {})
map("n", "<Plug>(del-single-char)i", function()
  vim.cmd.undojoin()
  vim.api.nvim_feedkeys("i", "n", false)
end, {})
