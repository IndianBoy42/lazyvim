local M = {}

-- Import snacks
local Snacks = require("snacks")

-- Helper function to get config path
local function get_config_path()
  return vim.fn.stdpath("config")
end

-- Helper function to check if window picker is available and use it for window selection
---@return function|nil Window selection action or nil if not available
local function get_window_select_action()
  local ok, win_pick = pcall(require, "ui.win_pick")
  if ok and win_pick.pick_or_create then
    return function(picker, item)
      local win_id = win_pick.pick_or_create()
      if win_id then
        vim.api.nvim_set_current_win(win_id)
        Snacks.picker.actions.jump(picker, item)
      end
    end
  end
  -- Fallback: try direct window-picker
  ok, win_pick = pcall(require, "window-picker")
  if ok then
    return function(picker, item)
      local win_id = win_pick.pick_or_create()
      if win_id then
        vim.api.nvim_set_current_win(win_id)
        Snacks.picker.actions.jump(picker, item)
      end
    end
  end
  return nil
end

-- Default vertical layout preset for config file pickers
---@type table
local vertical_layout = { preset = "vscode" }

---Opens a file picker for dotfiles (~/dots directory)
---Uses vertical layout with hidden and ignored files shown
function M.edit_dotfiles()
  local cwd = vim.fn.expand("~/dots")
  -- Check if directory exists
  if vim.fn.isdirectory(cwd) == 0 then
    vim.notify("Dotfiles directory not found: " .. cwd, vim.log.levels.WARN)
    return
  end

  Snacks.picker.files({
    cwd = cwd,
    hidden = true,
    ignored = true,
    title = "Dotfiles",
    layout = vertical_layout,
    format = "file",
    preview = "file",
    actions = {
      default = get_window_select_action() or Snacks.picker.actions.jump,
    },
  })
end

---Opens a file picker for fish config files (~/.config/fish/)
---Uses vertical layout with hidden and ignored files shown
function M.edit_fish()
  local cwd = vim.fn.expand("~/.config/fish/")
  -- Check if directory exists
  if vim.fn.isdirectory(cwd) == 0 then
    vim.notify("Fish config directory not found: " .. cwd, vim.log.levels.WARN)
    return
  end

  Snacks.picker.files({
    cwd = cwd,
    hidden = true,
    ignored = true,
    title = "Fish Config",
    layout = vertical_layout,
    format = "file",
    preview = "file",
    actions = {
      default = get_window_select_action() or Snacks.picker.actions.jump,
    },
  })
end

---Opens a file picker for neovim config files
---Uses vertical layout with hidden and ignored files shown
function M.edit_neovim()
  local cwd = get_config_path()
  -- Check if directory exists
  if vim.fn.isdirectory(cwd) == 0 then
    vim.notify("Neovim config directory not found: " .. cwd, vim.log.levels.WARN)
    return
  end

  Snacks.picker.files({
    cwd = cwd,
    hidden = true,
    ignored = true,
    title = "Neovim Config",
    layout = vertical_layout,
    format = "file",
    preview = "file",
    actions = {
      default = get_window_select_action() or Snacks.picker.actions.jump,
    },
  })
end

---Find all files including hidden and ignored ones
---Uses fd/rg with --no-ignore and --hidden flags
function M.find_all_files()
  Snacks.picker.files({
    hidden = true,
    ignored = true,
    title = "All Files",
    format = "file",
    preview = "file",
    actions = {
      default = get_window_select_action() or Snacks.picker.actions.jump,
    },
  })
end

---Grep using the last search pattern from the / register
---Runs live grep with the last search as initial pattern
function M.grep_last_search()
  -- Get the last search pattern from the / register
  local last_search = vim.fn.getreg("/")

  -- Clean up the search pattern (remove vim regex markers like \<, \>, \C)
  -- These are used for word boundary matching and case sensitivity in vim
  local cleaned_search = last_search:gsub("\\<", ""):gsub("\\>", ""):gsub("\\C", "")

  -- Handle empty search
  if not cleaned_search or cleaned_search == "" then
    vim.notify("No previous search pattern found", vim.log.levels.INFO)
    -- Still open grep picker without initial search
    Snacks.picker.grep({
      title = "Grep",
    })
    return
  end

  Snacks.picker.grep({
    search = cleaned_search,
    title = "Grep Last Search",
    format = "file",
    preview = "file",
  })
end

---Smart open combining recent files and current directory files
---Uses Snacks.picker.smart() with custom configuration
function M.smart_open()
  Snacks.picker.smart({
    title = "Smart Open",
    format = "file",
    preview = "file",
    actions = {
      default = get_window_select_action() or Snacks.picker.actions.jump,
    },
  })
end

---Grep with a user-provided search string (prompt version)
---Opens an input prompt and runs grep with the provided string
function M.grep_prompt()
  vim.ui.input({ prompt = "Grep String ❯ " }, function(input)
    if not input or input == "" then
      return
    end
    Snacks.picker.grep({
      search = input,
      title = "Grep: " .. input,
      format = "file",
      preview = "file",
    })
  end)
end

return M
