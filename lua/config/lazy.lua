local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

utils.augrp("lazy_filetype", function(au)
  au("FileType", {
    pattern = "lazy",
    callback = function()
      vim.keymap.setl("n", "<localleader>n", "/[○●]<cr>", { desc = "Next plugin" })
    end,
  })
end)

require("lazy").setup({
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  change_detection = { notify = false },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = true, -- notify on update
  }, -- automatically check for plugin updates
  dev = {
    path = "~/dev/nvim.plugins/",
    filter = { "IndianBoy42" },
  },
  ui = {

    border = "rounded",
    custom_keys = {
      ["<localleader>l"] = false,
      ["<localleader>t"] = {
        desc = "Open in new Kitty",
        function(plugin)
          require("kitty.terms").new_os_window(
            { open_cwd = plugin.dir },
            -- TODO: don't hardcode fish
            { "fish", "-C", "ls", "-C", "commandline -f repaint" }
          )
        end,
      },
      ["<localleader>g"] = {
        desc = "Open gitui in new Kitty",
        function(plugin)
          require("kitty.terms").new_os_window({ open_cwd = plugin.dir }, "gitui")
        end,
      },
      ["<localleader>m"] = {
        desc = "Open in Smerge",
        function(plugin)
          vim.system({ "smerge", plugin.dir })
        end,
      },
      ["<localleader>h"] = {
        desc = "Open in github browser",
        function(plugin)
          vim.cmd("!gh repo view --web " .. plugin[1])
          -- require("kitty").new_os_window({ open_cwd = plugin.dir }, "gitui")
        end,
      },
    },
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "gzip",
        "zip",
        "zipPlugin",
        "tar",
        "tarPlugin",
        "getscript",
        "getscriptPlugin",
        "vimball",
        "vimballPlugin",
        "2html_plugin",
        "logipat",
        "rrhelper",
        "spellfile_plugin",
        "matchit",
      },
    },
  },
})
