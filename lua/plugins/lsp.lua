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
              { "<m-n>", false },
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
    opts = {},
    config = function(_, opts)
      require("tiny-inline-diagnostic").setup()
      vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
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
