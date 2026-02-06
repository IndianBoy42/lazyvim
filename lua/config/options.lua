-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
--
-- Custom options that differ from LazyVim/Neovim defaults

local opt = vim.opt
local g = vim.g

--- GREP CONFIGURATION ---
-- Use ripgrep for grep (explicit definition)
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

--- INDENTATION ---
-- Use 4 spaces for indentation (LazyVim defaults to 2)
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.expandtab = true

--- SEARCH ---
-- Case sensitivity settings (same as LazyVim defaults, explicit here)
opt.ignorecase = true
opt.smartcase = true

--- LINE NUMBERS ---
-- Disable line numbers (LazyVim defaults to enabled)
opt.number = false
opt.relativenumber = false

--- SIGN COLUMN ---
-- Use number column for signs instead of dedicated column (saves space)
-- LazyVim default: "yes", this config: "number"
opt.signcolumn = "number"

--- WINDOW SPLITTING ---
-- Create splits below and to the right (LazyVim defaults, explicit here)
opt.splitbelow = true
opt.splitright = true

--- COLORS & UI ---
-- Enable true color support (LazyVim default, explicit here)
opt.termguicolors = true
-- GUI font for Neovide and other GUI clients
opt.guifont = "Iosevka Term SS05 Md Ex:h10"

--- COMPLETION ---
-- Completion menu options (different from LazyVim: menu,menuone,noselect)
opt.completeopt = "menuone,noselect"
-- Popup menu height (same as LazyVim default)
opt.pumheight = 10

--- TIMING ---
-- Time to wait for a mapped sequence to complete (ms)
-- LazyVim default: 300, this config: 500
opt.timeoutlen = 500
-- Cursor hold update time
opt.updatetime = 500

--- FOLDING ---
-- Don't fold on startup (LazyVim uses foldlevel=99)
opt.foldlevelstart = 99
-- Use indent-based folding (LazyVim default, explicit here)
opt.foldmethod = "indent"

--- TEXT WRAPPING ---
-- Disable line wrap (LazyVim default, explicit here)
opt.wrap = false

--- FILETYPE ASSOCIATIONS ---
-- Add custom filetype associations
vim.filetype.add({
  extension = {
    jl = "julia",
    typ = "typst",
  },
})

--- CLIPBOARD: OSC52 INTEGRATION ---
-- Enable OSC52 clipboard integration for SSH/headless environments
-- This allows copying to the system clipboard over SSH
if vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
  local osc52 = require("vim.ui.clipboard.osc52")
  g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = osc52.paste("+"),
      ["*"] = osc52.paste("*"),
    },
  }
end

--- LEADER KEYS ---
-- Set before any keymaps are defined (LazyVim uses space and backslash)
-- These are already set by LazyVim but explicitly defined here for clarity
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
