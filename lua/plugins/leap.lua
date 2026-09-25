local nav = require("utils.nav")
local function _leap_bi()
  local winnr = vim.api.nvim_get_current_win()
  local pre_leap_pos = vim.api.nvim_win_get_cursor(winnr)
  require("leap").leap({
    target_windows = { winnr },
    inclusive_op = true,
  })
  local post_leap_pos = vim.api.nvim_win_get_cursor(winnr)

  -- If jumping behind original position
  local behind = (pre_leap_pos[1] > post_leap_pos[1])
    or ((pre_leap_pos[1] == post_leap_pos[1]) and (pre_leap_pos[2] > post_leap_pos[2]))
  return behind
end
local function leap_bi_o(inc)
  return function()
    local behind = _leap_bi()

    if inc == true or inc == 2 then
      if behind then
      else
        vim.cmd("normal! l")
      end
    elseif inc == false or inc == 0 then
      if behind then
        vim.cmd("normal! ll")
      else
        vim.cmd("normal! h")
      end
    elseif inc == 1 then
      if behind then
        vim.cmd("normal! l")
      else
      end
    end
  end
end
local function leap_bi_n()
  require("leap").leap({ target_windows = { vim.api.nvim_get_current_win() }, inclusive_op = true })
end
local function leap_bi_x(inc)
  return function()
    local behind = _leap_bi()

    if inc == true or inc == 2 then
      if not behind then
        vim.cmd("normal! l")
      end
    elseif inc == false or inc == 0 then
      if behind then
        vim.cmd("normal! 2l")
      else
        vim.cmd("normal! h")
      end
    elseif inc == 1 then
      if behind then
        vim.cmd("normal! l")
      end
    end
  end
end

-- Return an argument table for `leap()`, tailored for f/t-motions.
local function as_ft(key_specific_args)
  local common_args = {
    inputlen = 1,
    inclusive = true,
    -- To limit search scope to the current line:
    -- pattern = function (pat) return '\\%.l'..pat end,
    opts = {
      labels = "", -- force autojump
      safe_labels = vim.fn.mode(1):match("[no]") and "" or nil, -- [1]
    },
  }
  return vim.tbl_deep_extend("keep", common_args, key_specific_args)
end

local leap_ft = function(k)
  return function()
    local clever = require("leap.user").with_traversal_keys -- [2]

    local clever_f = clever("f", "F")
    local clever_t = clever("t", "T")

    local opts = {
      f = { opts = clever_f },
      F = { backward = true, opts = clever_f },
      t = { offset = -1, opts = clever_t },
      T = { backward = true, offset = 1, opts = clever_t },
    }
    require("leap").leap(as_ft(opts[k]))
  end
end

return {
  {
    url = "https://codeberg.org/andyg/leap.nvim.git",
    keys = {
      { "f", leap_ft("f"), mode = { "n", "x", "o" } },
      { "F", leap_ft("f"), mode = { "n", "x", "o" } },
      { "t", leap_ft("t"), mode = { "n", "x", "o" } },
      { "T", leap_ft("T"), mode = { "n", "x", "o" } },
      { "}" }, -- Repeat mappings
      { "{" },
      { "s", "<Plug>(leap)", mode = "n", desc = "Leap" },
      { "q", "<Plug>(leap)", mode = { "x", "o" }, desc = "Leap" },
      {
        O.goto_prefix .. O.goto_prefix,
        "<Plug>(leap-anywhere)",
        mode = { "n", "x", "o" },
        desc = "Leap anywhere",
      },
      {
        "S",
        "<Plug>(leap-anywhere)",
        mode = { "n", "x", "o" },
        desc = "Leap anywhere",
      },
      { ";", leap_bi_o(1), mode = "o", desc = "Leap SemiInc" },
      { ".", leap_bi_o(2), mode = "o", desc = "Leap Incl." },
      {
        "t", -- semi-inclusive
        function()
          vim.cmd.normal({ "v", bang = true })
          require("leap").leap({ inclusive_op = true })
        end,
        mode = "n",
        desc = "Leap v t",
      },
      {
        "T", -- semi-inclusive
        function()
          vim.cmd.normal({ "v", bang = true })
          require("leap").leap({ backward = true, offset = 1, inclusive_op = true })
        end,
        mode = "n",
        desc = "Leap v T",
      },
      {
        O.select_dynamic,
        "<Plug>(leap-treesitter)",
        mode = { "o", "x" },
        desc = "Cursor Node",
      },
      {
        O.goto_prefix .. "r",
        "<Plug>(leap-remote)",
        desc = "Leap Remote",
        mode = { "n", "x" },
      },
      {
        "r",
        "<Plug>(leap-remote)",
        desc = "Leap Remote",
        mode = "o",
      },
      { -- FIXME: treesitter doesn't trigger (leap thinks we're done too soon)
        O.select_remote_dynamic,
        function()
          require("leap.remote").action({
            input = "<Plug>(leap-treesitter)",
          })
        end,
        desc = "Leap Remote",
        mode = { "o", "x" },
      },
      {
        O.goto_prefix .. ".",
        function()
          require("leap.remote").action({ input = "." })
        end,
        desc = ".-repeat remote",
        mode = { "n" },
      },
      {
        O.goto_prefix .. "s",
        function()
          require("leap.remote").action({ input = "v" })
        end,
        desc = ".-repeat remote",
        mode = { "n" },
      },
      {
        "<leader>gx",
        function()
          require("leap.remote").action({ input = "gx" })
        end,
        desc = "gx remote",
        mode = "n",
      },
      {
        "ar",
        function()
          -- TODO: add which-key here?
          local ok, char = pcall(vim.fn.getcharstr)
          if not ok or char == vim.keycode("<esc>") then
            return
          end
          require("leap.remote").action({ input = "a" .. char })
        end,
        mode = { "o", "x" },
        desc = "Leap Remote (around)",
      },
      {
        "ir",
        function()
          local ok, char = pcall(vim.fn.getcharstr)
          if not ok or char == vim.keycode("<esc>") then
            return
          end
          require("leap.remote").action({ input = "i" .. char })
        end,
        mode = { "o", "x" },
        desc = "Leap Remote (inside)",
      },
      {
        O.goto_prefix .. "/",
        function()
          require("leap.remote").action({ jumper = "/" })
        end,
        desc = "Remote op at /",
        mode = { "n", "o" },
      },
      {
        O.goto_prefix .. "?",
        function()
          require("leap.remote").action({ jumper = "?" })
        end,
        desc = "Remote op at ?",
        mode = { "n", "o" },
      },
      {
        "rp",
        mode = "n",
        desc = "Remote Paste",
        nav.remote_paste(),
        -- function() require("leap.remote").action { input = "p" } end,
      },
      {
        "rP",
        mode = "n",
        desc = "Remote Paste line",
        nav.remote_paste(nil, "<Plug>(YankyPutIndentAfterLinewise)"),
      },
      -- [cdy]<>rp<>
      -- [cdy]<>R<>
      -- [cdy]r<>[pP]
      -- [cdy]r<>r<>
      -- TODO: y<motion><something><leap><motion>
      {
        "rx",
        mode = { "n", "x" },
        desc = "Exchange <motion1> with <motion2>",
        function()
          require("leap.remote").action({
            input = "cx",
            and_then = ".",
          })
        end,
      },
      {
        "rX",
        mode = { "n", "x" },
        desc = "Exchange V<motion1> with V<motion2>",
        function()
          require("leap.remote").action({
            input = "cxV",
            and_then = ".",
          })
        end,
      },
      {
        "ry",
        mode = { "n" },
        desc = "Remote yank and paste here",
        function()
          require("leap.remote").action({
            input = "y",
            and_then = "P",
          })
        end,
      },
      {
        "rd",
        mode = { "x", "n" },
        desc = "Remote delete and paste here",
        function()
          require("leap.remote").action({
            input = "d",
            and_then = "P",
          })
        end,
      },
      {
        "rc",
        mode = { "x", "n" },
        desc = "Remote change and paste here",
        function()
          require("leap.remote").action({
            input = "c",
            and_then = "P",
          })
        end,
      },
      -- TODO: implement these with leap.remote (without repeat motion?)
      { -- FIXME: swap the order of this
        "rY",
        mode = { "x", "n" },
        desc = "Replace with <remote-motion>",
        function()
          nav.swap_with({ exchange = { not_there = true } })
        end,
      },
      { -- FIXME: swap the order of this
        "rD",
        mode = { "x", "n" },
        desc = "Replace with d<remote-motion>",
        function()
          nav.swap_with({ exchange = { not_there = true } })
        end,
      },
      { -- FIXME: swap the order of this
        "rC",
        mode = { "x", "n" },
        desc = "Replace with c<remote-motion>",
        function()
          nav.swap_with({ exchange = { not_there = true } })
        end,
      },
      { O.goto_prefix .. "f", "<Plug>(leap-forward-to)", mode = "x", desc = "Leap f" },
      { O.goto_prefix .. "t", "<Plug>(leap-forward-till)", mode = "x", desc = "Leap t" },
      { O.goto_prefix .. "F", "<Plug>(leap-backward-to)", mode = "x", desc = "Leap F" },
      { O.goto_prefix .. "T", "<Plug>(leap-backward-till)", mode = "x", desc = "Leap T" },
      -- { O.goto_prefix.."f", leap_bi_x(2), mode = "x", desc = "Leap Inc" },
      -- { O.goto_prefix.."t", leap_bi_x(0), mode = "x", desc = "Leap Exc" },
      { O.goto_prefix .. "f", leap_bi_o(2), mode = "o", desc = "Leap Inc" },
      { O.goto_prefix .. "t", leap_bi_o(0), mode = "o", desc = "Leap Exc" },

      {
        "<Plug>(leap-remote)",
        function()
          require("leap.remote").action()
        end,
        desc = "Leap Remote",
        mode = { "n", "o", "x" },
      },
      {
        "<Plug>(leap-treesitter)",
        function()
          require("leap.treesitter").select()
          -- local sk = vim.deepcopy(require("leap").opts.special_keys)
          -- -- The items in `special_keys` can be both strings or tables - the
          -- -- shortest workaround might be the below one:
          -- sk.next_target = vim.fn.flatten(vim.list_extend({ O.select_dynamic }, { sk.next_target }))
          -- sk.prev_target = vim.fn.flatten(vim.list_extend({ O.select_dynamic:upper() }, { sk.prev_target }))
          -- require("leap.treesitter").select { opts = { special_keys = sk } }
        end,
        mode = { "n", "o", "x" },
        desc = "Cursor Node",
      },
      {
        "<Plug>(leap-treesitter-line)",
        'V<cmd>lua require("leap.treesitter").select()<cr>',
        mode = { "n", "o", "x" },
        desc = "Cursor V Node",
      },
    },
    -- TODO: unlazy me
    config = function()
      local leap = require("leap")
      -- Highly recommended: define a preview filter to reduce visual noise
      -- and the blinking effect after the first keypress
      -- (see `:h leap.opts.preview`).
      -- For example, skip preview if the first character of the match is
      -- whitespace or is in the middle of an alphabetic word:
      require("leap").opts.preview = function(ch0, ch1, ch2)
        return not (ch1:match("%s") or (ch0:match("%a") and ch1:match("%a") and ch2:match("%a")))
      end
      leap.opts.equivalence_classes = {
        " \t\r\n",
        "(){}[]b",
        "()p",
        "{}[]B",
        "\"'`q",
        "<>t",
        -- ")]}>",
        -- "([{<",
        -- "\"'`",
      }
      -- stylua: ignore
      leap.opts.safe_labels = {
        "s", "f", "n", "u", "t",
        "h", "j", "k", "l",
        "b", "e", "w",
        ",", "-",
            }
      -- TODO: make this n/N for repeating motions
      require("leap.user").set_repeat_keys("}", "{", {})

      local grp = vim.api.nvim_create_augroup("UserLeapRemote", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = grp,
        once = true,
        pattern = "RemoteOperationDone",
        callback = function(event)
          local args = event.data.args
          if not args.and_then then
            return
          end
          if type(args.and_then) == "string" then
            -- vim.schedule(function()
            --   utils.feedkeys(args.and_then, "m")
            -- end)
            vim.cmd("normal! " .. args.and_then)
          else
            args:and_then()
          end
        end,
      })
    end,
  },
}
