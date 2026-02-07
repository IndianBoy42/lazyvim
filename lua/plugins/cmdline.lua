return {
  {
    "nacro90/numb.nvim",
    event = "CmdLineEnter",
    opts = {
      show_numbers = true, -- Enable 'number' for the window while peeking
      show_cursorline = true, -- Enable 'cursorline' for the window while peeking
    },
  },
  {
    "smjonas/live-command.nvim",
    main = "live-command",
    event = "CmdlineEnter",
    opts = {
      commands = {
        Norm = { cmd = "norm" },
        G = { cmd = "g" },
        D = { cmd = "d" },
      },
    },
    config = function(_, opts)
      require("live-command").setup(opts)
      -- Transforms ":5Reg a" into ":norm 5@a"
      local function get_command_string(cmd)
        local get_range_string = require("live-command").get_range_string
        local args = (cmd.count == -1 and "" or cmd.count) .. "@" .. cmd.args
        return get_range_string(cmd) .. "norm " .. args
      end

      vim.api.nvim_create_user_command("Reg", function(cmd)
        vim.cmd(get_command_string(cmd))
      end, {
        nargs = "?",
        range = true,
        preview = function(cmd, preview_ns, preview_buf)
          local cmd_to_preview = get_command_string(cmd)
          return require("live-command").preview_callback(cmd_to_preview, preview_ns, preview_buf)
        end,
      })
    end,
  },
  {
    "notomo/cmdbuf.nvim",
    config = function(_, opts)
      local cmdbuf = require("cmdbuf")
      local map = vim.keymap.set
      local split_open = function(h, opts)
        return function()
          cmdbuf.split_open(h or vim.o.cmdwinheight, opts)
        end
      end
      map("n", "q:", split_open(nil), { desc = "Cmdwin" })
      map("n", "q/", split_open(nil, { type = "vim/search/forward" }), { desc = "Cmdwin Search Forward" })
      map("n", "q?", split_open(nil, { type = "vim/search/backward" }), { desc = "Cmdwin Search Backward" })
      map("n", "ql", split_open(nil, { type = "lua/cmd" }), { desc = "Cmdwin Lua" })
      map("c", "<M-e>", function()
        require("cmdbuf").split_open(vim.o.cmdwinheight, { line = vim.fn.getcmdline(), column = vim.fn.getcmdpos() })
        vim.api.nvim_feedkeys(vim.keycode("<C-c>"), "n", true)
      end, { desc = "Open in cmdwin" })

      -- Custom buffer mappings
      vim.api.nvim_create_autocmd({ "User" }, {
        group = vim.api.nvim_create_augroup("cmdbuf_setting", {}),
        pattern = { "CmdbufNew" },
        callback = function(args)
          vim.bo.bufhidden = "wipe" -- if you don't need previous opened buffer state
          map("n", "q", [[<Cmd>quit<CR>]], { nowait = true, buffer = true })
          map("n", "dd", [[<Cmd>lua require('cmdbuf').delete()<CR>]], { buffer = true })

          -- you can filter buffer lines
          local lines = vim.tbl_filter(function(line)
            return line ~= "q"
          end, vim.api.nvim_buf_get_lines(args.buf, 0, -1, false))
          vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, lines)
        end,
      })

      -- open lua command-line window
      -- q/, q? alternative
    end,
    keys = { "q:", "q/", "q?", "ql", { "<C-f>", mode = "c" } },
  },
  {
    "winston0410/range-highlight.nvim",
    event = "CmdlineEnter",
    dependencies = { "winston0410/cmd-parser.nvim" },
    opts = {},
  },
}
