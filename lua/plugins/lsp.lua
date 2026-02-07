-- TODO: linked editing range
-- TODO: on_type_formatting
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local map = Snacks.keymap.set
      --[[
-- Set keymap for buffers with any LSP that supports code actions
Snacks.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {
  lsp = { method = "textDocument/codeAction" },
  desc = "Code Action",
})

-- Set keymap for buffers with a specific LSP client
Snacks.keymap.set("n", "<leader>co", function()
  vim.lsp.buf.code_action({
    apply = true,
    context = {
      only = { "source.organizeImports" },
      diagnostics = {},
    },
  })
end, {
  lsp = { name = "vtsls" },
  desc = "Organize Imports",
})

-- Set keymap for buffers with LSP that supports definitions
Snacks.keymap.set("n", "gd", vim.lsp.buf.definition, {
  lsp = { method = "textDocument/definition" },
  desc = "Go to Definition",
})
      ]]
      vim.tbl_deep_extend("force", opts, {
        servers = {
          ["*"] = {
            keys = {
              -- Disable a keymap
              -- TODO: O.goto_prefix
              -- { "<m-n>", false },
              -- { "gd", vim.lsp.buf.definition, desc = "Goto Definition", has = "definition" },
              -- { "gr", vim.lsp.buf.references, desc = "References", nowait = true },
              -- { "gI", vim.lsp.buf.implementation, desc = "Goto Implementation" },
              -- { "gy", vim.lsp.buf.type_definition, desc = "Goto T[y]pe Definition" },
              -- { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
              -- { "K", function() return vim.lsp.buf.hover() end, desc = "Hover" },
              -- { "gK", function() return vim.lsp.buf.signature_help() end, desc = "Signature Help", has = "signatureHelp" },
              -- { "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help", has = "signatureHelp" },
              -- { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "x" }, has = "codeAction" },
              -- { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "x" }, has = "codeLens" },
              -- { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },
              -- { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode ={"n"}, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
              -- { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
              -- { "<leader>cA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
            },
          },
        },
      })
    end,
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    -- event = "VeryLazy",
    event = "DiagnosticChanged",
    opts = {
      options = {
        transparent_bg = true,
        show_source = {
          if_many = true,
          set_arrow_to_diag_color = true,
        },
        softwrap = 30,
        add_messages = {
          display_count = true, -- Show diagnostic count instead of messages when cursor not on line
        },
        multilines = {
          enabled = true,
        },
        show_all_diags_on_cursorline = true,

        -- Experimental options, subject to misbehave in future NeoVim releases
        experimental = {
          -- Make diagnostics not mirror across windows containing the same buffer
          -- See: https://github.com/rachartier/tiny-inline-diagnostic.nvim/issues/127
          use_window_local_extmarks = false,
        },
      },
    },
    config = function(_, opts)
      require("tiny-inline-diagnostic").setup(opts)
      vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics

      -- diagnostic
      local diagnostic_goto = function(next, severity)
        return function()
          vim.diagnostic.jump({
            count = (next and 1 or -1) * vim.v.count1,
            severity = severity and vim.diagnostic.severity[severity] or nil,
            -- NOTE: disable the popup because of tiny-inline-diagnostic
            float = false,
          })
        end
      end
      local map = vim.keymap.set
      map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
      map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
      map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
      map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
      map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
      map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
    end,
  },
  { -- "IndianBoy42/actions-preview.nvim",
    "aznhe21/actions-preview.nvim",
    opts = function()
      return {
        highlight_command = {
          require("actions-preview.highlight").delta(),
          -- require("actions-preview.highlight").diff_so_fancy(),
          -- require("actions-preview.highlight").diff_highlight(),
        },
      }
    end,
    keys = {
      {
        "co",
        function()
          require("actions-preview").code_actions()
        end,
        desc = "Actions Previewed",
      },
      {
        "K",
        function()
          require("actions-preview").code_actions()
        end,
        mode = "x",
        desc = "Actions Previewed",
      },
    },
  },
  -- TODO: https://github.com/jan-xyz/lsp-preview.nvim/tree/main
  -- TODO: https://github.com/DNLHC/glance.nvim
}
