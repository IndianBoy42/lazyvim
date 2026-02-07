vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("undim_diagnostic_unnecessary", { clear = true }),
  callback = function(e)
    local client = assert(vim.lsp.get_client_by_id(e.data.client_id))
    local ns =
      vim.api.nvim_create_namespace(string.format("nvim.nvim.lsp.%s.%d.diagnostic.underline", client.name, client.id))
    local undim_diagnostic = function(diagnostic) ---@param diagnostic vim.Diagnostic
      local from = { diagnostic.lnum, diagnostic.col }
      local to = { diagnostic.end_lnum, diagnostic.end_col }
      local extmarks = vim.api.nvim_buf_get_extmarks(e.buf, ns, from, to, {})
      for _, extm in ipairs(extmarks) do
        vim.api.nvim_buf_del_extmark(e.buf, ns, extm[1])
      end
    end
    local clear_hl = function()
      vim.api.nvim_buf_clear_namespace(e.buf, ns, 0, -1)
    end
    local apply_hl = function()
      local lnum, col = vim.fn.line(".") - 1, vim.fn.col(".") - 1
      local line_diagnostics = {} ---@type vim.Diagnostic[]
      local select_from = vim.diagnostic.get(e.buf, { severity = vim.diagnostic.severity.HINT })
      for _, diagnostic in ipairs(select_from) do
        if diagnostic._tags and diagnostic._tags.unnecessary then
          vim.api.nvim_buf_set_extmark(e.buf, ns, diagnostic.lnum, diagnostic.col, {
            hl_group = "DiagnosticUnnecessary",
            end_line = diagnostic.end_lnum,
            end_col = diagnostic.end_col,
            strict = false,
          })
          if lnum >= diagnostic.lnum and lnum <= diagnostic.end_lnum then
            table.insert(line_diagnostics, diagnostic)
          end
        end
      end
      for _, diagnostic in ipairs(line_diagnostics) do
        if diagnostic.lnum == diagnostic.end_lnum then
          if col < diagnostic.end_col then
            undim_diagnostic(diagnostic)
          end
        else
          undim_diagnostic(diagnostic)
        end
      end
    end
    local refresh_hl = function()
      clear_hl()
      apply_hl()
    end
    local aug = vim.api.nvim_create_augroup("undim_diagnostic", { clear = false })
    vim.api.nvim_create_autocmd("ModeChanged", {
      buffer = e.buf,
      group = aug,
      callback = function()
        local mode = vim.fn.mode()
        if mode == "n" then
          refresh_hl()
        elseif mode == "c" then
        else
          clear_hl()
        end
      end,
    })
    vim.api.nvim_create_autocmd("DiagnosticChanged", {
      buffer = e.buf,
      group = aug,
      callback = function()
        if vim.fn.mode() == "n" then
          refresh_hl()
        end
      end,
    })
    vim.api.nvim_create_autocmd("CursorHold", {
      buffer = e.buf,
      group = aug,
      callback = function()
        refresh_hl()
      end,
    })
  end,
})
