return { -- mizlan/iswap.nvim
  {
    "IndianBoy42/iswap.nvim",
    opts = {
      keys = O.hint_labels .. O.hint_labels:upper(),
      autoswap = false,
      move_cursor = true,
      only_current_line = false,
      debug = true,
      flash_style = "simultaneous",
    },
    cmd = {
      "ISwap",
      "ISwapTwo",
      "ISwapLeft",
      "ISwapRight",
      "IMove",
      "IMoveTwo",
      "ISwapList",
      "ISwapListTwo",
    },
    keys = {
      { "mx", "<cmd>ISwap<cr>", desc = "ISwapNodeWith", mode = { "n" } },
      -- { "mx", "<Plug>(ISwap)", desc = "ISwapNodeWith", mode = { "n" } },
      { "X", "<cmd>ISwap<cr>", desc = "ISwapNodeWith", mode = { "x" } },
      { "M", "<cmd>IMove<cr>", desc = "IMoveNodeWith", mode = { "x" } },
      { "mX", "<cmd>ISwapTwo<cr>", desc = "ISwapNode", mode = { "n" } },
      -- { "mm", F 'require("iswap").imove_node({ autoswap = false })', desc = "IMoveNode", mode = { "n" } },
      { "mm", "<cmd>IMove<cr>", desc = "IMove", mode = { "n" } },
    },
  },
  {
    "nvim-mini/mini.align",
    opts = {},
    keys = { { "ga", mode = { "n", "x" }, desc = "Align" } },
  },
  {
    "IndianBoy42/treesj",
    dependencies = { "nvim-treesitter" },
    opts = {
      use_default_keymaps = false,
      max_join_length = 120,
    },
    keys = {
      {
        "<C-s>",
        function()
          require("treesj").toggle()
        end,
        desc = "SplitJoin",
        mode = { "n", "i", "x" },
      },
      {
        "<leader>es",
        function()
          require("treesj").toggle()
        end,
        desc = "SplitJoin",
        mode = { "n", "x" },
      },
      {
        "<leader>ej",
        function()
          require("treesj").nested_toggle("flash")
        end,
        desc = "SplitJoin Nested",
        mode = { "n", "x" },
      },
      -- TODO: make this a hydra for repeatability
      -- { "<leader>eJ", function() require("treesj").split() end, desc = "Split" },
      -- { "<leader>ej", function() require("treesj").join() end, desc = "Join" },
    },
  },
  {
    "gbprod/yanky.nvim",
    opts = {
      textobj = {
        enabled = true,
      },
    },
    keys = {
      {
        "<leader>yd",
        function()
          require("yanky").history.delete(1)
        end,
        mode = "n",
        desc = "Drop last yank from history",
      },
      { "<C-p>", "<Plug>(YankyCycleForward)", mode = { "n", "x" }, desc = "Cycle paste backward" },
      -- TODO: Cycle hydra for no modifiers?
      { "<M-p>", "<Plug>(YankyCycleBackward)", mode = { "n", "x" }, desc = "Cycle paste forward" },
      { "<leader>p", "<Plug>(YankyPutIndentAfterLinewise)", mode = "n", desc = "Put after line" },
      { "<leader>P", "<Plug>(YankyPutIndentBeforeLinewise)", mode = "n", desc = "Put before line" },
      { "yp", "<Plug>(YankyPutIndentAfterCharwise)", mode = "n", desc = "Put after char" },
      { "yP", "<Plug>(YankyPutIndentBeforeCharwise)", mode = "n", desc = "Put before char" },
      {
        "iy",
        function()
          require("yanky.textobj").last_put()
        end,
        mode = { "o", "x" },
        desc = "Last Put",
      },
      { "ay", "Viy", remap = true, mode = { "o", "x" }, desc = "Last VPut" },
    },
  },
  {
    "gbprod/substitute.nvim",
    keys = function()
      -- Replace selection with register
      local substitute = function(fn, opts)
        return function()
          local substitute = require("substitute")
          substitute[fn](opts)
        end
      end
      -- Replace all in range
      local substitute_range = function(fn, opts)
        opts = vim.tbl_extend("keep", { group_substituted_text = true }, opts or {})
        return function()
          local range = require("substitute.range")
          range[fn](opts)
        end
      end
      local exchange = function(fn, opts)
        return function()
          local exchange = require("substitute.exchange")
          exchange[fn](opts)
        end
      end

      return {
        { "r", substitute("operator"), mode = "n", desc = "Replace" },
        { "rr", substitute("line"), mode = "n", desc = "Replace Line" },
        { "R", substitute("eol"), mode = "n", desc = "Replace EOL" },

        { "cx", exchange("operator"), mode = "n", desc = "Exchange" },
        { "cxx", exchange("line"), mode = "n", desc = "Exchange Line" },
        { "x", exchange("visual"), mode = "x", desc = "Exchange" },
        -- { "<leader>X", exchange "cancel", mode = "n", desc = "Cancel Exchange" },

        -- TODO: make it better
        { '<leader>r"', ':%s/<C-R>"//g<Left><Left>', desc = "Last cdy" },
        { "<leader>r+", ":%s/<C-R>+//g<Left><Left>", desc = "Last clipboard" },
        { "<leader>r.", ":%s/<C-R>.//g<Left><Left>", desc = "Last insert" },
        { "<leader>r/", ":%s/<C-R>///g<Left><Left>", desc = "Last search" },

        { '<leader>r"', ':%s/<C-R>"//g<Left><Left>', desc = "Last cdy", mode = "x" },
        { "<leader>r+", ":%s/<C-R>+//g<Left><Left>", desc = "Last clipboard", mode = "x" },
        { "<leader>r.", ":%s/<C-R>.//g<Left><Left>", desc = "Last insert", mode = "x" },
        { "<leader>r/", ":%s/<C-R>///g<Left><Left>", desc = "Last search", mode = "x" },
        { "<leader>rs", ":s///g<Left><Left><Left>", desc = "In Selection", mode = "x" },

        -- TODO: fuck these, just use vim-visual-multi?
        {
          "<leader>rI",
          substitute_range("operator"),
          mode = "n",
          desc = "Replace all (motion1) in (motion2)",
        },
        {
          "<leader>rA",
          substitute_range("operator", { range = "%" }),
          mode = "n",
          desc = "Replace all (motion) in file",
        },
        {
          "<leader>ro",
          substitute_range("word"),
          mode = "n",
          desc = "Replace all iw in (motion)",
        },
        {
          "<leader>rO",
          substitute_range("word", { range = "%" }),
          mode = "n",
          desc = "Replace all iw in file",
        },
        {
          "r*",
          substitute_range("word", { range = "%" }),
          mode = "n",
          desc = "Replace all iw in file",
        },
        {
          "<leader>ro",
          substitute_range("visual", {}),
          mode = "x",
          desc = "Replace all (sel) in (motion)",
        },
        {
          "<leader>rO",
          substitute_range("visual", { range = "%" }),
          mode = "x",
          desc = "Replace all (sel) in file",
        },
      }
    end,
    config = function()
      local opts = {
        on_substitute = require("yanky.integration").substitute(),
        yank_substituted_text = false, -- TODO: a separate keymap for true
      }
      require("substitute").setup(opts)
    end,
  },
  {
    "johmsalas/text-case.nvim",
    opts = {
      default_keymappings_enabled = true,
      prefix = "cu",
    },
    keys = function()
      local k = {
        {
          "cu<space>",
          function()
            require("which-key").show({
              keys = "cu",
              loop = true, -- this will keep the popup open until you hit <esc>
            })
          end,
          desc = "Change case",
          mode = { "n", "x", "o" },
        },
        { "cu", mode = { "n", "x", "o" } },
        -- { "cU", mode = { "n", "x", "o" } },
      }
      -- { "<leader>rc", desc = "Rename case", mode = { "x", "n" } },
      local function head(kc, mode, fn, desc)
        local fn_s = fn
        if mode == "x" then
          kc = "u" .. kc
          fn = function()
            require("textcase").quick_replace(fn_s)
          end
        elseif mode == "o" then
          kc = "cU" .. kc
          fn = function()
            require("textcase").operator(fn_s)
          end
        else
          kc = "cu" .. kc
          fn = function()
            require("textcase").current_word(fn_s)
          end
        end
        return { kc, mode = mode, fn, desc = desc }
      end
      local heads = function(op)
        return {
          head("U", op, "to_upper_case", "UPPERCASE"),
          head("u", op, "to_lower_case", "lowercase"),
          head("_", op, "to_snake_case", "snake_case"),
          head("-", op, "to_dash_case", "dash-case"),
          head("C", op, "to_constant_case", "CONSTANT_CASE"),
          head(".", op, "to_dot_case", "dot.case"),
          head("c", op, "to_camel_case", "camelCase"),
          head("t", op, "to_title_case", "Title Case"),
          head("/", op, "to_path_case", "path/case"),
          head("s", op, "to_phrase_case", "Sentence case"),
          head("m", op, "to_pascal_case", "PascalCase"),
        }
      end
      -- vim.list_extend(k, heads("n"))
      vim.list_extend(k, heads("x"))
      -- vim.list_extend(k, heads("o"))
      return k
    end,
  },
  {
    "monaqa/dial.nvim",
    opts = function(_, opts)
      -- local dial = require "dial"
      local dial_config = require("dial.config")
      local augend = require("dial.augend")

      -- table.insert(dial.config.searchlist.normal, "markup#markdown#header")

      -- local m = require "dial.map"
      -- vim.keymap.set("v", "<C-a>", m.inc_visual() .. "gv", { desc = "inc" })
      -- vim.keymap.set("v", "<C-x>", m.dec_visual() .. "gv", { desc = "dec" })
      -- vim.keymap.set("v", "g<C-a>", m.inc_gvisual() .. "gv", { desc = "inc" })
      -- vim.keymap.set("v", "g<C-x>", m.dec_gvisual() .. "gv", { desc = "dec" })
      vim.list_extend(opts.groups.default, {
        augend.integer.alias.octal,
        augend.integer.alias.binary,
        augend.constant.new({
          elements = { "yes", "no" },
          preserve_case = true,
        }),
        augend.constant.alias.alpha,
        augend.constant.alias.Alpha,
        augend.semver.alias.semver,
        augend.date.alias["%Y/%m/%d"],
        augend.date.alias["%d/%m/%Y"],
        augend.date.alias["%Y-%m-%d"],
        augend.date.alias["%d-%m-%Y"],
      })
      return opts
    end,
  },
  {
    "mini.move",
    main = "mini.move",
    keys = function()
      local keys = { "<M-h>", "<M-j>", "<M-k>", "<M-l>", "<C-M-h>", "<C-M-j>", "<C-M-k>", "<C-M-l>" }
      keys = {
        "<S-Left>",
        "<S-Down>",
        "<S-Up>",
        "<S-Right>",
        "<S-Left>",
        "<S-Down>",
        "<S-Up>",
        "<S-Right>",
      }
      return {
        { keys[1], mode = "x" },
        { keys[2], mode = "x" },
        { keys[3], mode = "x" },
        { keys[4], mode = "x" },
        { keys[5], mode = "n" },
        { keys[6], mode = "n" },
        { keys[7], mode = "n" },
        { keys[8], mode = "n" },
      }
    end,
    opts = {
      mappings = {
        left = "<S-Left>",
        right = "<S-Right>",
        down = "<S-Down>",
        up = "<S-Up>",
        line_left = "<S-Left>",
        line_right = "<S-Right>",
        line_down = "<S-Down>",
        line_up = "<S-Up>",
      },
    },
    -- config = function(_, opts)
    --   require("mini.move").setup(opts)
    --
    --   -- TODO: moving hydra mode
    --   require "hydra" {
    --     name = "Move Item",
    --     hint = false,
    --     config = {},
    --     mode = { "n" },
    --     body = "m",
    --     heads = {
    --       { "h", utils.partial(MiniMove.move_line, "left"), {} },
    --       { "j", utils.partial(MiniMove.move_line, "down"), {} },
    --       { "k", utils.partial(MiniMove.move_line, "up"), {} },
    --       { "l", utils.partial(MiniMove.move_line, "right"), {} },
    --     },
    --   }
    --   require "hydra" {
    --     name = "Move Item",
    --     hint = false,
    --     config = {},
    --     mode = { "x" },
    --     body = "<leader>m",
    --     heads = {
    --       { "h", utils.partial(MiniMove.move_selection, "left"), {} },
    --       { "j", utils.partial(MiniMove.move_selection, "down"), {} },
    --       { "k", utils.partial(MiniMove.move_selection, "up"), {} },
    --       { "l", utils.partial(MiniMove.move_selection, "right"), {} },
    --     },
    --   }
    -- end,
  },
  {
    "mini.operators",
    main = "mini.operators",
    opts = {
      -- Evaluate text and replace with output
      evaluate = { prefix = "<leader>=" },
      sort = { prefix = "gs" },
      exchange = { prefix = "" },
      multiply = { prefix = "" },
      replace = { prefix = "" },
    },
    config = function(_, opts)
      require("mini.operators").setup(opts)
      require("mini.operators").make_mappings("multiply", { textobject = "yd", line = "ydd", selection = "D" })
    end,
    keys = {
      { "gs", mode = { "n", "x" }, desc = "Sort" },
      { "gss", mode = { "n" }, desc = "Sort line" },
      { "<leader>=", mode = { "n", "x" }, desc = "Evaluate" },
      { "<leader>==", mode = { "n" }, desc = "Evaluate line" },
      { "yd", desc = "Duplicate" },
      { "ydd", desc = "Duplicate Line" },
      { "yD", "ydV", remap = true, desc = "Duplicate Linewise" },
      { mode = "x", "D", desc = "Duplicate" },
    },
  },
}
