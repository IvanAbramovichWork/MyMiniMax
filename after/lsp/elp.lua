function find_ecss10_root(path)
    local dir = vim.fs.dirname(path)

    while dir do
        local name = vim.fs.basename(dir)

        if name == "ecss10" or name:match("^ecss10[_%.].+") then
            return dir
        end

        local parent = vim.fs.dirname(dir)
        if parent == dir then
            break
        end

        dir = parent
    end
end

return {

    cmd = { 'elp', 'server' },
    filetypes = { 'erlang' },
    -- root_dir = '~/ecss10/',

    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)

        local clients = vim.lsp.get_clients({ bufnr = bufnr })
        if #clients > 0 then
            return
        end

        -- ecss10, ecss10_2, ecss10.2, ecss10_test, ...
        local root = find_ecss10_root(fname)

        if root then
            on_dir(root)
            return
        end

        -- Normal project detection
        local util = require("lspconfig.util")
        root = util.root_pattern(".git", "rebar.config", "mix.exs")(fname)

        if root then
            on_dir(root)
        end
    end,
    root_markers = {},
}
