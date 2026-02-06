return {
  {
    "nvim-focus/focus.nvim",
    version = "*",
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
