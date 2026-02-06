-- Escape key clears search and spelling highlights
-- FIXME: why do you delete yourself??
map("n", "<esc>", function()
  vim.cmd("nohlsearch")

  vim.o.spell = false

  local ok, notify = pcall(require, "notify")
  if ok then
    notify.dismiss({ pending = true, silent = true })
  end

  return "<Plug>(double-esc)"
end, { silent = true, expr = true, remap = true })
map("i", "<esc>", function()
  vim.cmd.stopinsert()
  feedkeys(t("<esc>"), "n")
  feedkeys(t("<Plug>(double-esc)"), "n")
  -- vim.cmd.normal { bang = true, "==" } -- Reindent line
end, {})
map("n", "<Plug>(double-esc)<esc>", function()
  -- TODO: close floating windows
  pcall(vim.cmd.write)
  pcall(function()
    require("blinker").blink_cursorline()
  end)
end)
