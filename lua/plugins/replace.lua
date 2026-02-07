return {
  {
    "MagicDuck/grug-far.nvim",
    opts = {
      -- transient = true,
      keymaps = {
        close = "<C-c>",
        replace = { n = O.quicksave },
        -- TODO: need a hydra for the next/prev
        -- qflist = { n = '<localleader>q' },
        -- syncLocations = { n = '<localleader>s' }, // sync all
        -- applyNext = { n = '<localleader>j' },
        -- applyPrev = { n = '<localleader>k' },
        -- syncNext = { n = '<localleader>n' },
        -- syncPrev = { n = '<localleader>p' },
        -- syncFile = { n = '<localleader>v' },
        syncLine = { n = "L" },
        -- historyOpen = { n = '<localleader>t' },
        -- historyAdd = { n = '<localleader>a' },
        -- refresh = { n = '<localleader>f' },
        -- openLocation = { n = '<localleader>o' },
        -- TODO: jump to match without opening
        -- openNextLocation = { n = '<down>' },
        -- openPrevLocation = { n = '<up>' },
        -- gotoLocation = { n = '<enter>' },
        -- pickHistoryEntry = { n = '<enter>' },
        -- abort = { n = '<localleader>b' },
        -- help = { n = 'g?' },
        -- toggleShowCommand = { n = '<localleader>w' },
        -- swapEngine = { n = '<localleader>e' },
        -- previewLocation = { n = '<localleader>i' },
        -- swapReplacementInterpreter = { n = '<localleader>x' },
        -- nextInput = { n = '<tab>' },
        -- prevInput = { n = '<s-tab>' },
      },
    },
    keys = {
      { "<leader>rp", "<cmd>GrugFar<cr>", desc = "GrugFar Project", mode = { "x", "n" } },
      {
        "<leader>rf",
        function()
          require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
        end,
      },
      {
        "<leader>r*",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
        end,
        desc = "Last search",
      },
      {
        "<leader>r/",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.getreg("/") } })
        end,
        desc = "Last search",
      },
      {
        "<leader>r+",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.getreg("+") } })
        end,
        desc = "Last yank",
      },
      {
        "<leader>r.",
        function()
          require("grug-far").open({ prefills = { search = vim.fn.getreg(".") } })
        end,
        desc = "Last insert",
      },
      {
        "<Plug>(GrugFarFile)",
        function()
          require("grug-far").open({ prefills = { flags = vim.fn.expand("%") } })
        end,
        desc = "GrugFar File",
      },
    },
    setup = function(opts)
      require("grug-far").setup(opts)
      local function nN()
        mappings.register_nN_repeat({
          "<Plug>(GrugNextMatch)",
          "<Plug>(GrugPrevMatch)",
        })
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("grug-far-keybindings", { clear = true }),
        pattern = { "grug-far" },
        callback = function()
          local inst = require("grug-far").get_instance(0)
          if not inst then
            return
          end

          nN()

          -- Jump and close
          vim.keymap.set("n", "<C-enter>", function()
            inst:open_location()
            inst:close()
          end, { buffer = true })
          vim.keymap.set("n", "<Plug>(GrugNextMatch)", function()
            inst:goto_next_match()
          end, { buffer = true })
          vim.keymap.set("n", "<Plug>(GrugPrevMatch)", function()
            inst:goto_prev_match()
          end, { buffer = true })
          vim.keymap.set("n", "<Plug>(GrugApplyNextMatch)", function()
            inst:goto_next_match()
            inst:apply_next_change({})
          end, { buffer = true })
          vim.keymap.set("n", "<Plug>(GrugApplyPrevMatch)", function()
            inst:goto_prev_match()
            inst:apply_next_change({})
          end, { buffer = true })
          vim.keymap.set("n", "<localleader>/", function()
            inst:goto_next_match()
            nN()
          end, { buffer = true })
        end,
      })
    end,
  },
  {
    "stevearc/quicker.nvim",
    -- TODO: winleavepre
    event = "FileType qf",
    opts = {
      keys = {
        {
          "<Right>",
          function()
            require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
          end,
          desc = "Expand quickfix context",
        },
        {
          "<Left>",
          function()
            require("quicker").collapse()
          end,
          desc = "Collapse quickfix context",
        },
        {
          "<localleader><localleader>",
          function()
            require("quicker").refresh()
          end,
          desc = "Refresh",
        },
      },
      on_qf = function(bufnr)
        -- vim.api.nvim_create_autocmd("WinLeave", {
        --   buffer = 0,
        --   callback = function() vim.cmd.write() end,
        -- })
      end,
    },
  },
}
