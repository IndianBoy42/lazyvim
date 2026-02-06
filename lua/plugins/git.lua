-- TODO: override gitui/lazygit with jjui in .jj repos
return {
  {
    "rafikdraoui/jj-diffconflicts",
    cmd = "JJDiffConflicts",
  },
  {
    "julienvincent/hunk.nvim",
    cmd = { "DiffEditor" },
    opts = {},
  },
}
