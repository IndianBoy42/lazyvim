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
  local ok, win_pick = pcall(require, "plugins.window-picker")
  if ok and win_pick.pick_or_create then
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
function M.pick_win(picker, item, action)
  if not picker.layout.split then
    picker.layout:hide()
  end
  local win = require("plugins.window-picker").pick_or_create(cb, opts)
  if not win then
    if not picker.layout.split then
      picker.layout:unhide()
    end
    return true
  end
  picker.main = win
  if not picker.layout.split then
    vim.defer_fn(function()
      if not picker.closed then
        picker.layout:unhide()
      end
    end, 100)
  end
end

-- Default vertical layout preset for config file pickers
---@type table
local vertical_layout = { preset = "vscode" }

function M.grep_last_reg(reg, desc)
  -- Get the last search pattern from the / register
  local last_search = vim.fn.getreg(reg)

  -- Clean up the search pattern (remove vim regex markers like \<, \>, \C)
  -- These are used for word boundary matching and case sensitivity in vim
  local cleaned_search = last_search:gsub("\\<", ""):gsub("\\>", ""):gsub("\\C", "")

  -- Handle empty search
  if not cleaned_search or cleaned_search == "" then
    vim.notify("No previous search pattern found", vim.log.levels.INFO)
    -- Still open grep picker without initial search
    Snacks.picker.grep_word({})
    return
  end

  Snacks.picker.grep_word({
    search = function(p)
      return cleaned_search
    end,
    title = desc,
  })
end

---Grep using the last search pattern from the / register
---Runs live grep with the last search as initial pattern
function M.grep_last_search()
  -- Get the last search pattern from the / register
  return M.grep_last_reg("/", "Last Search")
end
function M.grep_last_cdy()
  -- Get the last search pattern from the / register
  return M.grep_last_reg('"', "Last Cdy")
end
function M.grep_last_ins()
  -- Get the last search pattern from the / register
  return M.grep_last_reg(".", "Last Insert")
end

---Grep with a user-provided search string (prompt version)
---Opens an input prompt and runs grep with the provided string
function M.grep_prompt()
  vim.ui.input({ prompt = "Grep String ❯ " }, function(input)
    if not input or input == "" then
      return
    end
    Snacks.picker.grep_word({
      search = function()
        return input
      end,
      title = "Grep: " .. input,
    })
  end)
end

local jj_log_sources = {
  title = "jj log",
  supports_live = false,
  reversed = nil,
  cwd = nil,
  args = nil,
  finder = function(opts, ctx)
    local cwd
    cwd = opts and opts.cwd or vim.uv.cwd() or "."
    cwd = svim.fs.normalize(cwd)
    cwd = vim.fs.root(cwd or 0, ".jj")
    if not cwd then
      Snacks.notify.error("Cannot find `.jj` folder. To initialize a repository use `jj git init .`")
      ctx.picker.closed = true
      return {}
    end
    local template = [[
            separate("\0",
              self.change_id().shortest(),
              self.change_id().shortest(8),
              commit_timestamp(self).format("%Y-%m-%d %H:%M"),
              commit_id.shortest(8),
              if(description,
                description.first_line(),
                label(
                  if(empty, "empty"),
                  if(root, "root()", description_placeholder)
                ),
              )
            ) ++ "\n"
          ]]
    local cmd = "jj"
    local args = {
      "log",
      "--color=never",
      "--no-graph",
      "--template=" .. template,
    }
    if opts.reversed then
      table.insert(args, "--reversed")
    end
    vim.list_extend(args, opts.args or {})
    return require("snacks.picker.source.proc").proc({
      opts,
      {
        cmd = cmd,
        args = args,
        cwd = cwd,
        ---@param item snacks.picker.finder.Item
        transform = function(item)
          local data = vim.split(item.text, "\0")
          item.cwd = cwd
          item.change_id_prefix = data[1]
          item.change_id = data[2]
          item.date = data[3]
          item.commit = data[4]
          item.description = data[5]
        end,
      },
    }, ctx)
  end,
  format = function(item)
    local ret = {} ---@type snacks.picker.Highlight[]
    table.insert(ret, { item.change_id_prefix, "SnacksPickerGitCommit" })
    table.insert(ret, { item.change_id:sub(#item.change_id_prefix + 1), "SnacksPickerDimmed" })
    table.insert(ret, { " " })
    table.insert(ret, { item.date, "SnacksPickerGitDate" })
    table.insert(ret, { " " })
    table.insert(ret, { item.commit, "SnacksPickerGitStatusModified" })
    table.insert(ret, { " " })
    local desc = item.description ---@type string
    local desc_hl = "SnacksPickerGitMsg"
    if desc == "root()" then
      desc_hl = "SnacksPickerGitStatusStaged"
    end
    if desc == "(no description set)" then
      desc_hl = "SnacksPickerDimmed"
    end
    -- Highlight description
    -- See https://github.com/folke/snacks.nvim/blob/bc0630e43be5699bb94dadc302c0d21615421d93/lua/snacks/picker/format.lua#L179-L204
    local type, scope, breaking, body = desc:match("^(%S+)%s*(%(.-%))(!?):%s*(.*)$")
    if not type then
      type, breaking, body = desc:match("^(%S+)(!?):%s*(.*)$")
    end
    if type and body then
      local dimmed = vim.tbl_contains({ "chore", "bot", "build", "ci", "style", "test" }, type)
      desc_hl = dimmed and "SnacksPickerDimmed" or "SnacksPickerGitMsg"
      table.insert(ret, {
        type,
        breaking ~= "" and "SnacksPickerGitBreaking" or dimmed and "SnacksPickerBold" or "SnacksPickerGitType",
      })
      if scope and scope ~= "" then
        table.insert(ret, { scope, "SnacksPickerGitScope" })
      end
      if breaking ~= "" then
        table.insert(ret, { "!", "SnacksPickerGitBreaking" })
      end
      table.insert(ret, { ":", "SnacksPickerDelim" })
      table.insert(ret, { " " })
      desc = body
    end
    table.insert(ret, { desc, desc_hl })
    Snacks.picker.highlight.markdown(ret)
    Snacks.picker.highlight.highlight(ret, { ["#%d+"] = "SnacksPickerGitIssue" })
    return ret
  end,
  preview = function(ctx)
    local M = require("snacks.picker.preview")
    local cmd = { "jj", "log", "-r=" .. ctx.item.change_id }
    local preview_opts = vim.tbl_deep_extend("keep", ctx.picker.opts.previewers.jj or {}, {
      delta = false,
    })
    if preview_opts.delta then
      -- TIP: Disable noisy warning
      -- jj config set --user 'merge-tools.delta.diff-expected-exit-codes' '[0, 1]'
      table.insert(cmd, "--tool=delta")
    else
      table.insert(cmd, "--git")
    end
    M.cmd(cmd, ctx)
  end,
  confirm = function(picker, item)
    picker:close()
    local target = item.change_id
    vim.system({ "jj", "edit", target }, { cwd = item.cwd }, function(sys)
      if sys.code == 0 then
        Snacks.notify.info("Edit " .. target, { title = "Snacks Picker" })
      else
        Snacks.notify.error(sys.stderr)
      end
    end)
  end,
  sort = { fields = { "score:desc", "idx" } },
}

local git_grep_hunks = {
  supports_live = false,
  format = function(item, picker)
    local file_format = Snacks.picker.format.file(item, picker)
    vim.api.nvim_set_hl(0, "SnacksPickerGitGrepLineNew", { link = "Added" })
    vim.api.nvim_set_hl(0, "SnacksPickerGitGrepLineOld", { link = "Removed" })
    if item.sign == "+" then
      file_format[#file_format - 1][2] = "SnacksPickerGitGrepLineNew"
    else
      file_format[#file_format - 1][2] = "SnacksPickerGitGrepLineOld"
    end
    return file_format
  end,
  finder = function(_, ctx)
    local hcount = 0
    local header = {
      file = "",
      old = { start = 0, count = 0 },
      new = { start = 0, count = 0 },
    }
    local sign_count = 0
    return require("snacks.picker.source.proc").proc(
      ctx:opts({
        cmd = "git",
        args = { "diff", "--unified=0" },
        transform = function(item) ---@param item snacks.picker.finder.Item
          local line = item.text
          -- [[Header]]
          if line:match("^diff") then
            hcount = 3
          elseif hcount > 0 then
            if hcount == 1 then
              header.file = line:sub(7)
            end
            hcount = hcount - 1
          elseif line:match("^@@") then
            local parts = vim.split(line:match("@@ ([^@]+) @@"), " ")
            local old_start, old_count = parts[1]:match("-(%d+),?(%d*)")
            local new_start, new_count = parts[2]:match("+(%d+),?(%d*)")
            header.old.start, header.old.count = tonumber(old_start), tonumber(old_count) or 1
            header.new.start, header.new.count = tonumber(new_start), tonumber(new_count) or 1
            sign_count = 0
            -- [[Body]]
          elseif not line:match("^[+-]") then
            sign_count = 0
          elseif line:match("^[+-]%s*$") then
            sign_count = sign_count + 1
          else
            item.sign = line:sub(1, 1)
            item.file = header.file
            item.line = line:sub(2)
            if item.sign == "+" then
              item.pos = { header.new.start + sign_count, 0 }
              sign_count = sign_count + 1
            else
              item.pos = { header.new.start, 0 }
              sign_count = 0
            end
            return true
          end
          return false
        end,
      }),
      ctx
    )
  end,
}

return {
  {
    "folke/snacks.nvim",
    opts = {
      image = {},
      picker = {
        jump = { reuse_win = true },
        win = {
          list = {
            keys = {
              ["<M-cr>"] = {
                {
                  action = "confirm",
                  cmd = "Pick",
                },
                mode = { "n", "i" },
              },
            },
          },
        },
        actions = {
          win_pick = {
            action = "confirm",
            cmd = "Pick",
          },
        },
        previewers = {
          jj = {
            delta = true,
          },
        },
        sources = {
          jj_log = jj_log_sources,
          git_grep_hunks = git_grep_hunks,
        },
      },
    },
    keys = {
      {
        "<leader>s<space>",
        function()
          Snacks.picker.resume()
        end,
        desc = "Resume",
      },
      { "<leader>s/", M.grep_last_search, desc = "Search last /" },
      { '<leader>s"', M.grep_last_cdy, desc = "Search last cdy" },
      -- { "<leader>s+", "/<C-R>+<cr>", desc = "Last clipboard" },
      { "<leader>s.", M.grep_last_ins, desc = "Search last insert" },
      {
        "<leader>s?",
        function()
          Snacks.picker.search_history()
        end,
        desc = "Search History",
      },
      {
        "<leader>sA",
        function()
          Snacks.picker.autocmds()
        end,
        desc = "Autocmds",
      },
    },
  },
  {
    "2kabhishek/seeker.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = { "Seeker" },
    keys = {
      { "<leader>fa", ":Seeker files<CR>", desc = "Seek Files" },
      { "<leader>fA", ":Seeker git_files<CR>", desc = "Seek Git Files" },
      { "<leader>sa", ":Seeker grep<CR>", desc = "Seek Grep" },
    },
    opts = {}, -- Required unless you call seeker.setup() manually, add your configs here
  },
}
