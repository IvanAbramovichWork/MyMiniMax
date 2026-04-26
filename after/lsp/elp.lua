return {
  cmd = { 'elp', 'server' },
  filetypes = { 'erlang' },
  -- root_dir = '~/ecss10/',

  root_dir = function(bufnr, on_dir)
    local util = require("lspconfig.util")
    local fname = vim.api.nvim_buf_get_name(bufnr)

    -- Check if LSP already attached to this buffer
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if #clients > 0 then
      return -- skip (don't call on_dir → no new LSP)
    end

    -- 1. Your custom rule
    if fname:find("ecss10") then
      on_dir(vim.fn.expand("~/ecss10"))
      return
    end

    -- 2. Fallback to normal root pattern behavior
    local root = util.root_pattern(".git", "rebar.config", "mix.exs")(fname)

    if root then
      on_dir(root)
    end
  end,
  root_markers = {},
}
