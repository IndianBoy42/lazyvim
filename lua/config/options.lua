-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
--
-- Custom options that differ from LazyVim/Neovim defaults

local opt = vim.opt
local g = vim.g
local cmd = vim.cmd

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

--- LINE NUMBERS ---
-- Disable line numbers (LazyVim defaults to enabled)
opt.number = false
opt.relativenumber = false

--- SIGN COLUMN ---
-- Use number column for signs instead of dedicated column (saves space)
-- LazyVim default: "yes", this config: "number"
opt.signcolumn = "number"

--- COLORS & UI ---
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

opt.autowriteall = true

opt.scrolloff = 10
opt.sidescrolloff = 10

-- LSP Server to use for Rust.
-- Set to "bacon-ls" to use bacon-ls instead of rust-analyzer.
-- only for diagnostics. The rest of LSP support will still be
-- provided by rust-analyzer.
vim.g.lazyvim_rust_diagnostics = "bacon-ls"

cmd("set sessionoptions+=globals")
cmd("set sessionoptions-=help")

--- FILETYPE ASSOCIATIONS ---
-- Add custom filetype associations
vim.filetype.add({
  extension = {
    ["sublime-keymap"] = "json",
    ["sublime-commands"] = "json",
    ["sublime-settings"] = "json",
    kbd = "kmonad",
    -- fish = "fish",
    just = "just",
    tpp = "cpp",
    lbm = "lisp",
    mbt = "moonbit",
    mbti = "moonbit",
    mdd = "mermaid",
  },
  filename = {
    Justfile = "just",
    justfile = "just",
  },
})

opt.splitkeep = "cursor"

--- LEADER KEYS ---
-- Set before any keymaps are defined (LazyVim uses space and backslash)
g.mapleader = " "
g.maplocalleader = vim.keycode("<bs>")

g.snacks_animate = false
