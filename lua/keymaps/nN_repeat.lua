local M = {}

local custom_n_repeat = nil
local custom_N_repeat = nil

local feedkeys = vim.feedkeys

function M.n_repeat()
  -- vim.cmd [[normal! m']]
  if custom_n_repeat == nil then
    feedkeys("n", "n")
    vim.opt.wrapscan = true
  elseif type(custom_n_repeat) == "string" then
    feedkeys(custom_n_repeat)
  else
    custom_n_repeat()
  end
end
function M.N_repeat()
  -- vim.cmd [[normal! m']]
  if custom_N_repeat == nil then
    feedkeys("N", "n")
    vim.opt.wrapscan = true
  elseif type(custom_N_repeat) == "string" then
    feedkeys(custom_N_repeat)
  else
    custom_N_repeat()
  end
end
-- TODO: this could use buffer local (or name spaced keymaps in the future)
function M.register(nN)
  nN = nN or { nil, nil }
  custom_n_repeat = nN[1]
  custom_N_repeat = nN[2]
end
function M.make_nN_pair(pair, pre_action)
  return {
    function()
      vim.cmd([[normal! m']])
      if pre_action then
        pre_action[1]()
        if pre_action[3] then
          pre_action[3]()
        end
      end
      M.register(pair)
      if type(pair[1]) == "string" then
        feedkeys(pair[1])
      else
        pair[1]()
      end
    end,
    function()
      vim.cmd([[normal! m']])
      if pre_action then
        pre_action[2]()
        if pre_action[3] then
          pre_action[3]()
        end
      end
      M.register(pair)
      if type(pair[2]) == "string" then
        feedkeys(pair[2])
      else
        pair[2]()
      end
    end,
  }
end
function M.setup()
  local map = vim.keymap.set
  map("n", "n", M.n_repeat, {})
  map("n", "N", M.N_repeat, {})
  -- TODO: this broke
  -- map("n", "<C-n>", function()
  --   M.n_repeat()
  --   vim.schedule(function() feedkeys "+" end)
  -- end, { desc = "Add Cursor at Next" })
  -- map("n", "<C-S-n>", function()
  --   M.N_repeat()
  --   vim.schedule(function() feedkeys "+" end)
  -- end, { desc = "Add Cursor at Prev" })
  local function srchrpt(k, op)
    return function()
      M.register({ nil, nil })
      feedkeys(type(k) == "function" and k() or k, op or "n")
    end
  end

  map("n", "/", srchrpt("/"), { desc = "Search" })
  map("x", "g/", "/", { desc = "Search motion" })
  map("n", "<C-/>", srchrpt("?"), { desc = "Search bwd" })
  -- Swap g* and * ?
  -- TODO: the visual mode versions need repeating
  map("n", "*", srchrpt("*"), { desc = "Search cword" })
  map("n", "<C-*>", srchrpt("#"), { desc = "Search cword" })
  map("n", "g*", srchrpt("g*"), { desc = "Search cword whole" })
  map("n", "<C-g><C-*>", srchrpt("g#"), { desc = "Search cword whole" })
  map("n", "g.", [[/\V<C-r>"<CR>]] .. "cgn<C-a><ESC>", { desc = "Repeat change" }) -- Repeat the recent edit with cgn
end
return M
