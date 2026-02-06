return {
  {
    "camilledejoye/nvim-lsp-selection-range",
    opts = function()
      local lsr_client = require("lsp-selection-range.client")
      return {
        get_client = lsr_client.select_by_filetype(lsr_client.select),
      }
    end,
    init = function()
      utils.lsp_attach(function(client, bufnr)
        local map = function(mode, lhs, rhs, opts)
          if bufnr then
            opts.buffer = bufnr
          end
          vim.keymap.set(mode, lhs, rhs, opts)
        end
        if O.select and client.server_capabilities.selectionRangeProvider then
          local lsp_sel_rng = require("lsp-selection-range")
          map("n", O.select, "v" .. O.select, { remap = true, desc = "LSP Selection Range" })
          map("n", O.select, "v" .. O.select_outer, { remap = true, desc = "LSP Selection Range" })
          map("x", O.select, lsp_sel_rng.expand, { desc = "LSP Selection Range" })
          map("x", O.select_outer, O.select .. O.select, { remap = true, desc = "LSP Selection Range" }) -- TODO: use folding range
        end
      end)
    end,
  },
}
