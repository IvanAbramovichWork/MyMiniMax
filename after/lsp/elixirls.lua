return {
    -- nixpkgs elixir-ls exposes bin/elixir-ls (wrapper around scripts/language_server.sh)
    cmd = { 'elixir-ls' },
    filetypes = { 'elixir', 'eelixir', 'heex' },
    root_markers = { 'mix.exs', 'mix.lock', '.formatter.exs', '.git' },
}
