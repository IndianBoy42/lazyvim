local group = vim.api.nvim_create_augroup("mini_files_autocmds", {})
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesActionRename",
  callback = function(event)
    Snacks.rename.on_rename_file(event.data.from, event.data.to)
  end,
})

local files_set_cwd = function(path)
  -- Works only if cursor is on the valid file system entry
  local cur_entry_path = MiniFiles.get_fs_entry().path
  local cur_directory = vim.fs.dirname(cur_entry_path)
  vim.fn.chdir(cur_directory)
end

local show_dotfiles = true

local filter_show = function(fs_entry)
  return true
end

local filter_hide = function(fs_entry)
  return not vim.startswith(fs_entry.name, ".")
end

local toggle_dotfiles = function()
  show_dotfiles = not show_dotfiles
  local new_filter = show_dotfiles and filter_show or filter_hide
  mf.refresh({ content = { filter = new_filter } })
end

local set_from_picker = function()
  vim.api.nvim_win_call(mf.get_target_window(), function()
    mf.set_target_window(require("ui.win_pick").pick_or_create())
  end)
end
local open_from_picker = function()
  set_from_picker()
  local entry = mf.get_fs_entry()
  if not entry or entry.fs_type ~= "file" then
    return
  end
  mf.go_in()
end
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    local bufnr = args.data.buf_id
    require("hydra")({
      name = "Move",
      hint = false,
      config = {
        buffer = bufnr,
        color = "pink",
      },
      body = "<localleader>",
      heads = {
        { "h", "h", { noremap = true } },
        { "l", "l", { noremap = true } },
        { "H", "h", { noremap = false } },
        { "L", "l", { noremap = false } },
        { "<localleader>", "", { exit = true } },
      },
    })
    vim.keymap.set("n", "<localleader>~", files_set_cwd, { buffer = bufnr })
    vim.keymap.set("n", "<localleader>.", toggle_dotfiles, { buffer = bufnr })
    vim.keymap.set("n", "<localleader>p", set_from_picker, { buffer = bufnr })
    vim.keymap.set("n", "<localleader>L", open_from_picker, { buffer = bufnr })

    require("plugins.files.git")
  end,
})
return {
  "mini.files",
  keys = {
    {
      "<leader>of",
      function()
        if vim.o.buftype == "" then
          MiniFiles.open(vim.api.nvim_buf_get_name(0))
        end
        MiniFiles.reveal_cwd()
      end,
      desc = "File Browser",
    },
    {
      "<leader>oF",
      function()
        MiniFiles.open()
      end,
      desc = "File Browser CWD",
    },
  },
  opts = {
    windows = {
      preview = true,
      -- width_nofocus = 30,
    },
    options = {
      use_as_default_explorer = not vim.g.flatten_is_guest,
    },
    mappings = {
      go_in = "l",
      go_in_plus = "<cr>",
      go_out = "h",
      go_out_plus = "-",
      reset = "<localleader>R",
      close = "<c-c>",
      synchronize = O.quicksave,
    },
  },
}
