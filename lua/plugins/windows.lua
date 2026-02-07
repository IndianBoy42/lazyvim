local ignore_filetypes = { "neo-tree", "trouble" }
local ignore_buftypes = { "nofile", "prompt", "popup" }

local augroup = vim.api.nvim_create_augroup("FocusDisable", { clear = true })

vim.api.nvim_create_autocmd("WinEnter", {
  group = augroup,
  callback = function(_)
    if vim.tbl_contains(ignore_buftypes, vim.bo.buftype) then
      vim.w.focus_disable = true
    else
      vim.w.focus_disable = false
    end
  end,
  desc = "Disable focus autoresize for BufType",
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  callback = function(_)
    if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
      vim.b.focus_disable = true
    else
      vim.b.focus_disable = false
    end
  end,
  desc = "Disable focus autoresize for FileType",
})

return {
  { "trouble.nvim", opts = {
    win = {
      position = "right",
    },
  } },
  {
    "nvim-focus/focus.nvim",
    version = "*",
    event = "VeryLazy",
    keys = {
      -- :FocusSplitNicely 	Split a window based on the golden ratio rule.
      -- :FocusSplitCycle 	If there are no splits, create one and move to it, else cycle focused split. :FocusSplitCycle reverse for counterclockwise
      -- :FocusEqualise 	Temporarily equalises the splits so they are all of similar width/height.
      -- :FocusMaximise 	Temporarily maximises the focused window.
      -- :FocusMaxOrEqual 	Toggles Between having the splits equalised or the focused window maximised.
      { "<C-w>s", "<cmd>FocusSplitNicely<cr>", mode = { "n", "t" }, desc = "Split Nicely" },
      { "<C-h>", "<cmd>FocusSplitLeft<cr>", mode = { "n", "t" }, desc = "Move/Split h" },
      { "<C-j>", "<cmd>FocusSplitDown<cr>", mode = { "n", "t" }, desc = "Move/Split j" },
      { "<C-k>", "<cmd>FocusSplitUp<cr>", mode = { "n", "t" }, desc = "Move/Split k" },
      { "<C-l>", "<cmd>FocusSplitRight<cr>", mode = { "n", "t" }, desc = "Move/Split l" },
      { "<C-w>h", "<cmd>FocusSplitLeft<cr>", mode = { "n", "t" }, desc = "Move/Split h" },
      { "<C-w>j", "<cmd>FocusSplitDown<cr>", mode = { "n", "t" }, desc = "Move/Split j" },
      { "<C-w>k", "<cmd>FocusSplitUp<cr>", mode = { "n", "t" }, desc = "Move/Split k" },
      { "<C-w>l", "<cmd>FocusSplitRight<cr>", mode = { "n", "t" }, desc = "Move/Split l" },
      { "<C-w>l", "<cmd>FocusSplitRight<cr>", mode = { "n", "t" }, desc = "Move/Split l" },
      { "<C-w>m", "<cmd>FocusMaximise<cr>", mode = { "n", "t" }, desc = "Move/Split l" },
      { "<C-w>e", "<cmd>FocusEqualize<cr>", mode = { "n", "t" }, desc = "Move/Split l" },
      { "<C-w>f", mode = { "n", "t" }, desc = "Toggle Focus" },
      { "<C-w>F", mode = { "n", "t" }, desc = "Toggle Focus Global" },
    },
    opts = function()
      Snacks.toggle({
        name = "Toggle Focus",
        get = function()
          return vim.w.focus_disable ~= true
        end,
        set = function(state)
          vim.w.focus_disable = not state
        end,
      }):map("<C-w>f")
      Snacks.toggle({
        name = "Toggle Focus Global",
        get = function()
          return vim.g.focus_disable ~= true
        end,
        set = function(state)
          vim.g.focus_disable = not state
        end,
      }):map("<C-w>F")
      return {}
    end,
  },
}
