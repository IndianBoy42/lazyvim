-- Auto commands that differ from or extend LazyVim defaults
-- LazyVim default autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

local aucmd = vim.api.nvim_create_autocmd
local augrp = utils.augrp

-- ============================================================================
-- QUICKFIX WINDOW POSITION FIX
-- ============================================================================
augrp("quickfix_window_fix", function(au)
  -- Open quickfix window vertically on the right side
  au("QuickFixCmdPost", {
    pattern = "[^l]*",
    callback = function()
      vim.cmd("vert cwindow")
      vim.cmd.wincmd("p")
      vim.cmd.wincmd("=")
    end,
    desc = "Open quickfix window vertically on the right",
  })
end)

-- ============================================================================
-- MACRO RECORDING TIMER
-- ============================================================================
-- Warns if you've been recording a macro for a long time (likely forgotten)
augrp("macro_recording_timer", function(au)
  local timer = nil

  au("RecordingEnter", {
    callback = function()
      timer = vim.defer_fn(function()
        timer = nil
        local reg = vim.fn.reg_recording()
        if reg then
          vim.notify(
            ("You've been recording macro @%s for a while - did you forget to stop?"):format(reg),
            vim.log.levels.WARN
          )
        end
      end, 5000) -- 5 second warning
    end,
    desc = "Start timer when recording macro",
  })

  au("RecordingLeave", {
    callback = function()
      if timer then
        timer:stop()
        timer = nil
      end
    end,
    desc = "Stop timer when macro recording ends",
  })
end)

-- ============================================================================
-- FORMAT OPTIONS FIX
-- ============================================================================
-- Remove 'c' and 'o' from formatoptions to prevent auto-comment continuation
augrp("format_options_fix", function(au)
  local function fix_formatoptions()
    vim.opt.formatoptions:remove({ "c", "o" })
  end

  au({ "BufWinEnter", "BufNewFile", "BufRead" }, {
    callback = fix_formatoptions,
    desc = "Remove unwanted format options",
  })
end)

-- ============================================================================
-- CMDHEIGHT FIX
-- ============================================================================
-- Ensure cmdheight stays at 0 (minimal command line)
augrp("cmdheight_fix", function(au)
  au("OptionSet", {
    pattern = "cmdheight",
    callback = function()
      if vim.opt.cmdheight:get() > 0 then
        vim.defer_fn(function()
          vim.opt.cmdheight = 0
        end, 50)
      end
    end,
    desc = "Keep cmdheight at 0",
  })
end)
