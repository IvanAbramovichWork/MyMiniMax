-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file contains installation and configuration of plugins outside of MINI.
-- They significantly improve user experience in a way not yet possible with MINI.
-- These are mostly plugins that provide programming language specific behavior.
--
-- Use this file to install and configure other such plugins.

-- Make concise helpers for installing/adding plugins in two stages
local add = vim.pack.add
local now_if_args, later = Config.now_if_args, Config.later

-- Tree-sitter ================================================================

-- Tree-sitter is a tool for fast incremental parsing. It converts text into
-- a hierarchical structure (called tree) that can be used to implement advanced
-- and/or more precise actions: syntax highlighting, textobjects, indent, etc.
--
-- Tree-sitter support is built into Neovim (see `:h treesitter`). However, it
-- requires two extra pieces that don't come with Neovim directly:
-- - Language parsers: programs that convert text into trees. Some are built-in
--   (like for Lua), 'nvim-treesitter' provides many others.
--   NOTE: It requires third party software to build and install parsers.
--   See the link for more info in "Requirements" section of the MiniMax README.
-- - Query files: definitions of how to extract information from trees in
--   a useful manner (see `:h treesitter-query`). 'nvim-treesitter' also provides
--   these, while 'nvim-treesitter-textobjects' provides the ones for Neovim
--   textobjects (see `:h text-objects`, `:h MiniAi.gen_spec.treesitter()`).
--
-- Add these plugins now if file (and not 'mini.starter') is shown after startup.
--
-- Troubleshooting:
-- - Run `:checkhealth vim.treesitter nvim-treesitter` to see potential issues.
-- - In case of errors related to queries for Neovim bundled parsers (like `lua`,
--   `vimdoc`, `markdown`, etc.), manually install them via 'nvim-treesitter'
--   with `:TSInstall <language>`. Be sure to have necessary system dependencies
--   (see MiniMax README section for software requirements).
now_if_args(function()
    -- Define hook to update tree-sitter parsers after plugin is updated
    local ts_update = function() vim.cmd('TSUpdate') end
    Config.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')

    add({
        'https://github.com/nvim-treesitter/nvim-treesitter',
        'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
    })

    -- Define languages which will have parsers installed and auto enabled
    -- After changing this, restart Neovim once to install necessary parsers. Wait
    -- for the installation to finish before opening a file for added language(s).
    local languages = {
        -- These are already pre-installed with Neovim. Used as an example.
        'lua',
        'vimdoc',
        'markdown',
        -- Add here more languages with which you want to use tree-sitter
        -- To see available languages:
        -- - Execute `:=require('nvim-treesitter').get_available()`
        -- - Visit 'SUPPORTED_LANGUAGES.md' file at
        --   https://github.com/nvim-treesitter/nvim-treesitter/blob/main
    }
    local isnt_installed = function(lang)
        return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0
    end
    local to_install = vim.tbl_filter(isnt_installed, languages)
    if #to_install > 0 then require('nvim-treesitter').install(to_install) end

    -- Enable tree-sitter after opening a file for a target language
    local filetypes = {}
    for _, lang in ipairs(languages) do
        for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
            table.insert(filetypes, ft)
        end
    end
    local ts_start = function(ev) vim.treesitter.start(ev.buf) end
    Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
end)

-- Language servers ===========================================================

-- Language Server Protocol (LSP) is a set of conventions that power creation of
-- language specific tools. It requires two parts:
-- - Server - program that performs language specific computations.
-- - Client - program that asks server for computations and shows results.
--
-- Here Neovim itself is a client (see `:h vim.lsp`). Language servers need to
-- be installed separately based on your OS, CLI tools, and preferences.
-- See note about 'mason.nvim' at the bottom of the file.
--
-- Neovim's team collects commonly used configurations for most language servers
-- inside 'neovim/nvim-lspconfig' plugin.
--
-- Add it now if file (and not 'mini.starter') is shown after startup.
now_if_args(function()
    add({ 'https://github.com/neovim/nvim-lspconfig' })

    -- Use `:h vim.lsp.enable()` to automatically enable language server based on
    -- the rules provided by 'nvim-lspconfig'.
    -- Use `:h vim.lsp.config()` or 'after/lsp/' directory to configure servers.
    -- Uncomment and tweak the following `vim.lsp.enable()` call to enable servers.
    vim.lsp.enable({
        'lua_ls',
        'elp',
        'lemminx',
        'hls'
    })
end)

-- Formatting =================================================================

-- Programs dedicated to text formatting (a.k.a. formatters) are very useful.
-- Neovim has built-in tools for text formatting (see `:h gq` and `:h 'formatprg'`).
-- They can be used to configure external programs, but it might become tedious.
--
-- The 'stevearc/conform.nvim' plugin is a good and maintained solution for easier
-- formatting setup.
later(function()
    add({ 'https://github.com/stevearc/conform.nvim' })

  -- See also:
  -- - `:h Conform`
  -- - `:h conform-options`
  -- - `:h conform-formatters`
  require('conform').setup({
    default_format_opts = {
      -- Allow formatting from LSP server if no dedicated formatter is available
      lsp_format = 'fallback',
    },
    -- Map of filetype to formatters
    -- Make sure that necessary CLI tool is available
    formatters_by_ft = { lua = { 'stylua' }, erlang = {'erlfmt'} , haskell = {"fourmolu"}},
  })
end)

-- Snippets ===================================================================

-- Although 'mini.snippets' provides functionality to manage snippet files, it
-- deliberately doesn't come with those.
--
-- The 'rafamadriz/friendly-snippets' is currently the largest collection of
-- snippet files. They are organized in 'snippets/' directory (mostly) per language.
-- 'mini.snippets' is designed to work with it as seamlessly as possible.
-- See `:h MiniSnippets.gen_loader.from_lang()`.
later(function() add({ 'https://github.com/rafamadriz/friendly-snippets' }) end)

now_if_args(function()
    add({ 'https://github.com/kdheepak/lazygit.nvim' })
    add({ 'https://github.com/sindrets/diffview.nvim' })
    add({ 'https://github.com/NeogitOrg/neogit' })
    add({ 'https://github.com/lambdalisue/vim-suda' })
    add({ 'https://github.com/lewis6991/gitsigns.nvim' })
    require('gitsigns').setup {
        on_attach = function(bufnr)
            local gitsigns = require('gitsigns')

            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end

            -- Navigation
            map('n', ']c', function()
                if vim.wo.diff then
                    vim.cmd.normal({ ']c', bang = true })
                else
                    gitsigns.nav_hunk('next')
                end
            end)

            map('n', '[c', function()
                if vim.wo.diff then
                    vim.cmd.normal({ '[c', bang = true })
                else
                    gitsigns.nav_hunk('prev')
                end
            end)
            map('n', '<leader>hs', gitsigns.stage_hunk)
            map('n', '<leader>hr', gitsigns.reset_hunk)

            map('v', '<leader>hs', function()
                gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end)

            map('v', '<leader>hr', function()
                gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
            end)

            map('n', '<leader>hS', gitsigns.stage_buffer)
            map('n', '<leader>hR', gitsigns.reset_buffer)
            map('n', '<leader>hp', gitsigns.preview_hunk)
            map('n', '<leader>hi', gitsigns.preview_hunk_inline)
            map('n', '<leader>hb', function()
                gitsigns.blame_line({ full = true })
            end)
        end
    }
    -- add({ 'https://github.com/mangelozzi/rgflow.nvim' })
    -- require('rgflow').setup(
    --   {
    --     -- Set the default rip grep flags and options for when running a search via
    --     -- RgFlow. Once changed via the UI, the previous search flags are used for
    --     -- each subsequent search (until Neovim restarts).
    --     cmd_flags = "--smart-case --fixed-strings --ignore --max-columns 200",
    --
    --     -- Mappings to trigger RgFlow functions
    --     default_trigger_mappings = true,
    --     -- These mappings are only active when the RgFlow UI (panel) is open
    --     default_ui_mappings = true,
    --     -- QuickFix window only mapping
    --     default_quickfix_mappings = true,
    --   }
    -- )
    add({ "https://github.com/ibhagwan/fzf-lua" })
    require("fzf-lua").setup {
        -- MISC GLOBAL SETUP OPTIONS, SEE BELOW
        -- fzf_bin = ...,
        -- each of these options can also be passed as function that return options table
        -- e.g. winopts = function() return { ... } end
        -- winopts = { ...  },     -- UI Options
        -- keymap = { ...  },      -- Neovim keymaps / fzf binds
        -- actions = { ...  },     -- Fzf "accept" binds
        -- fzf_opts = {},    -- Fzf CLI flags
        -- fzf_colors = { ...  },  -- Fzf `--color` specification
        -- hls = { ...  },         -- Highlights
        -- previewers = { ...  },  -- Previewers options
        -- SPECIFIC COMMAND/PICKER OPTIONS, SEE BELOW
        files = {
            cwd = vim.fn.getcwd(),
            no_ignore = true,
            fd_opts = [[--color=never --type f --type l --exclude .git --exclude .jj --exclude _build --exclude ecss-node --exclude releases]],
            -- rg_opts = [[--color=never --files -g "!.git" -g "!.jj" -g "!_build" -g "!releases"]],
        },
        grep = {
            cwd = vim.fn.getcwd(),
            no_ignore = true,
            -- cmd = "rg -g '!_build' -g '!releases' --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e ",
            rg_opts = "-g '!_build' -g '!releases' --column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
        }
    }
    add({ 'https://github.com/tpope/vim-fugitive' })
    add({ 'https://github.com/nvim-lua/plenary.nvim' })
    add({ 'https://github.com/MunifTanjim/nui.nvim' })
    add({ 'https://github.com/harrisoncramer/gitlab.nvim' })
    local actions = require("diffview.actions")
    require("diffview").setup({
        diff_binaries = false, -- Show diffs for binaries
        enhanced_diff_hl = false, -- See |diffview-config-enhanced_diff_hl|
        git_cmd = { "git" }, -- The git executable followed by default args.
        hg_cmd = { "hg" },  -- The hg executable followed by default args.
        use_icons = true,   -- Requires nvim-web-devicons
        show_help_hints = true, -- Show hints for how to open the help panel
        watch_index = true, -- Update views and index buffers when the git index changes.
        icons = {           -- Only applies when use_icons is true.
            folder_closed = "",
            folder_open = "",
        },
        signs = {
            fold_closed = "",
            fold_open = "",
            done = "✓",
        },
        view = {
            -- Configure the layout and behavior of different types of views.
            -- Available layouts:
            --  'diff1_plain'
            --    |'diff2_horizontal'
            --    |'diff2_vertical'
            --    |'diff3_horizontal'
            --    |'diff3_vertical'
            --    |'diff3_mixed'
            --    |'diff4_mixed'
            -- For more info, see |diffview-config-view.x.layout|.
            default = {
                -- Config for changed files, and staged files in diff views.
                layout = "diff2_horizontal",
                disable_diagnostics = false, -- Temporarily disable diagnostics for diff buffers while in the view.
                winbar_info = false, -- See |diffview-config-view.x.winbar_info|
            },
            merge_tool = {
                -- Config for conflicted files in diff views during a merge or rebase.
                layout = "diff3_horizontal",
                disable_diagnostics = true, -- Temporarily disable diagnostics for diff buffers while in the view.
                winbar_info = true, -- See |diffview-config-view.x.winbar_info|
            },
            file_history = {
                -- Config for changed files in file history views.
                layout = "diff2_horizontal",
                disable_diagnostics = false, -- Temporarily disable diagnostics for diff buffers while in the view.
                winbar_info = false, -- See |diffview-config-view.x.winbar_info|
            },
        },
        file_panel = {
            listing_style = "tree",    -- One of 'list' or 'tree'
            tree_options = {           -- Only applies when listing_style is 'tree'
                flatten_dirs = true,   -- Flatten dirs that only contain one single dir
                folder_statuses = "only_folded", -- One of 'never', 'only_folded' or 'always'.
            },
            win_config = {             -- See |diffview-config-win_config|
                position = "left",
                width = 35,
                win_opts = {},
            },
        },
        file_history_panel = {
            log_options = { -- See |diffview-config-log_options|
                git = {
                    single_file = {
                        diff_merges = "combined",
                    },
                    multi_file = {
                        diff_merges = "first-parent",
                    },
                },
                hg = {
                    single_file = {},
                    multi_file = {},
                },
            },
            win_config = { -- See |diffview-config-win_config|
                position = "bottom",
                height = 16,
                win_opts = {},
            },
        },
        commit_log_panel = {
            win_config = {}, -- See |diffview-config-win_config|
        },
        default_args = { -- Default args prepended to the arg-list for the listed commands
            DiffviewOpen = {},
            DiffviewFileHistory = {},
        },
        hooks = {},           -- See |diffview-config-hooks|
        keymaps = {
            disable_defaults = false, -- Disable the default keymaps
            view = {
                -- The `view` bindings are active in the diff buffers, only when the current
                -- tabpage is a Diffview.
                { "n", "<tab>",      actions.select_next_entry,             { desc = "Open the diff for the next file" } },
                { "n", "<s-tab>",    actions.select_prev_entry,             { desc = "Open the diff for the previous file" } },
                { "n", "[F",         actions.select_first_entry,            { desc = "Open the diff for the first file" } },
                { "n", "]F",         actions.select_last_entry,             { desc = "Open the diff for the last file" } },
                { "n", "gf",         actions.goto_file_edit,                { desc = "Open the file in the previous tabpage" } },
                { "n", "<C-w><C-f>", actions.goto_file_split,               { desc = "Open the file in a new split" } },
                { "n", "<C-w>gf",    actions.goto_file_tab,                 { desc = "Open the file in a new tabpage" } },
                { "n", "<leader>e",  actions.focus_files,                   { desc = "Bring focus to the file panel" } },
                { "n", "<leader>b",  actions.toggle_files,                  { desc = "Toggle the file panel." } },
                { "n", "g<C-x>",     actions.cycle_layout,                  { desc = "Cycle through available layouts." } },
                { "n", "[x",         actions.prev_conflict,                 { desc = "In the merge-tool: jump to the previous conflict" } },
                { "n", "]x",         actions.next_conflict,                 { desc = "In the merge-tool: jump to the next conflict" } },
                { "n", "<leader>co", actions.conflict_choose("ours"),       { desc = "Choose the OURS version of a conflict" } },
                { "n", "<leader>ct", actions.conflict_choose("theirs"),     { desc = "Choose the THEIRS version of a conflict" } },
                { "n", "<leader>cb", actions.conflict_choose("base"),       { desc = "Choose the BASE version of a conflict" } },
                { "n", "<leader>ca", actions.conflict_choose("all"),        { desc = "Choose all the versions of a conflict" } },
                { "n", "dx",         actions.conflict_choose("none"),       { desc = "Delete the conflict region" } },
                { "n", "<leader>cO", actions.conflict_choose_all("ours"),   { desc = "Choose the OURS version of a conflict for the whole file" } },
                { "n", "<leader>cT", actions.conflict_choose_all("theirs"), { desc = "Choose the THEIRS version of a conflict for the whole file" } },
                { "n", "<leader>cB", actions.conflict_choose_all("base"),   { desc = "Choose the BASE version of a conflict for the whole file" } },
                { "n", "<leader>cA", actions.conflict_choose_all("all"),    { desc = "Choose all the versions of a conflict for the whole file" } },
                { "n", "dX",         actions.conflict_choose_all("none"),   { desc = "Delete the conflict region for the whole file" } },
            },
            diff1 = {
                -- Mappings in single window diff layouts
                { "n", "g?", actions.help({ "view", "diff1" }), { desc = "Open the help panel" } },
            },
            diff2 = {
                -- Mappings in 2-way diff layouts
                { "n", "g?", actions.help({ "view", "diff2" }), { desc = "Open the help panel" } },
            },
            diff3 = {
                -- Mappings in 3-way diff layouts
                { { "n", "x" }, "2do", actions.diffget("ours"),           { desc = "Obtain the diff hunk from the OURS version of the file" } },
                { { "n", "x" }, "3do", actions.diffget("theirs"),         { desc = "Obtain the diff hunk from the THEIRS version of the file" } },
                { "n",          "g?",  actions.help({ "view", "diff3" }), { desc = "Open the help panel" } },
            },
            diff4 = {
                -- Mappings in 4-way diff layouts
                { { "n", "x" }, "1do", actions.diffget("base"),           { desc = "Obtain the diff hunk from the BASE version of the file" } },
                { { "n", "x" }, "2do", actions.diffget("ours"),           { desc = "Obtain the diff hunk from the OURS version of the file" } },
                { { "n", "x" }, "3do", actions.diffget("theirs"),         { desc = "Obtain the diff hunk from the THEIRS version of the file" } },
                { "n",          "g?",  actions.help({ "view", "diff4" }), { desc = "Open the help panel" } },
            },
            file_panel = {
                { "n", "j",             actions.next_entry,                    { desc = "Bring the cursor to the next file entry" } },
                { "n", "<down>",        actions.next_entry,                    { desc = "Bring the cursor to the next file entry" } },
                { "n", "k",             actions.prev_entry,                    { desc = "Bring the cursor to the previous file entry" } },
                { "n", "<up>",          actions.prev_entry,                    { desc = "Bring the cursor to the previous file entry" } },
                { "n", "<cr>",          actions.select_entry,                  { desc = "Open the diff for the selected entry" } },
                { "n", "o",             actions.select_entry,                  { desc = "Open the diff for the selected entry" } },
                { "n", "l",             actions.select_entry,                  { desc = "Open the diff for the selected entry" } },
                { "n", "<2-LeftMouse>", actions.select_entry,                  { desc = "Open the diff for the selected entry" } },
                { "n", "-",             actions.toggle_stage_entry,            { desc = "Stage / unstage the selected entry" } },
                { "n", "s",             actions.toggle_stage_entry,            { desc = "Stage / unstage the selected entry" } },
                { "n", "S",             actions.stage_all,                     { desc = "Stage all entries" } },
                { "n", "U",             actions.unstage_all,                   { desc = "Unstage all entries" } },
                { "n", "X",             actions.restore_entry,                 { desc = "Restore entry to the state on the left side" } },
                { "n", "L",             actions.open_commit_log,               { desc = "Open the commit log panel" } },
                { "n", "zo",            actions.open_fold,                     { desc = "Expand fold" } },
                { "n", "h",             actions.close_fold,                    { desc = "Collapse fold" } },
                { "n", "zc",            actions.close_fold,                    { desc = "Collapse fold" } },
                { "n", "za",            actions.toggle_fold,                   { desc = "Toggle fold" } },
                { "n", "zR",            actions.open_all_folds,                { desc = "Expand all folds" } },
                { "n", "zM",            actions.close_all_folds,               { desc = "Collapse all folds" } },
                { "n", "<c-b>",         actions.scroll_view(-0.25),            { desc = "Scroll the view up" } },
                { "n", "<c-f>",         actions.scroll_view(0.25),             { desc = "Scroll the view down" } },
                { "n", "<tab>",         actions.select_next_entry,             { desc = "Open the diff for the next file" } },
                { "n", "<s-tab>",       actions.select_prev_entry,             { desc = "Open the diff for the previous file" } },
                { "n", "[F",            actions.select_first_entry,            { desc = "Open the diff for the first file" } },
                { "n", "]F",            actions.select_last_entry,             { desc = "Open the diff for the last file" } },
                { "n", "gf",            actions.goto_file_edit,                { desc = "Open the file in the previous tabpage" } },
                { "n", "<C-w><C-f>",    actions.goto_file_split,               { desc = "Open the file in a new split" } },
                { "n", "<C-w>gf",       actions.goto_file_tab,                 { desc = "Open the file in a new tabpage" } },
                { "n", "i",             actions.listing_style,                 { desc = "Toggle between 'list' and 'tree' views" } },
                { "n", "f",             actions.toggle_flatten_dirs,           { desc = "Flatten empty subdirectories in tree listing style" } },
                { "n", "R",             actions.refresh_files,                 { desc = "Update stats and entries in the file list" } },
                { "n", "<leader>e",     actions.focus_files,                   { desc = "Bring focus to the file panel" } },
                { "n", "<leader>b",     actions.toggle_files,                  { desc = "Toggle the file panel" } },
                { "n", "g<C-x>",        actions.cycle_layout,                  { desc = "Cycle available layouts" } },
                { "n", "[x",            actions.prev_conflict,                 { desc = "Go to the previous conflict" } },
                { "n", "]x",            actions.next_conflict,                 { desc = "Go to the next conflict" } },
                { "n", "g?",            actions.help("file_panel"),            { desc = "Open the help panel" } },
                { "n", "<leader>cO",    actions.conflict_choose_all("ours"),   { desc = "Choose the OURS version of a conflict for the whole file" } },
                { "n", "<leader>cT",    actions.conflict_choose_all("theirs"), { desc = "Choose the THEIRS version of a conflict for the whole file" } },
                { "n", "<leader>cB",    actions.conflict_choose_all("base"),   { desc = "Choose the BASE version of a conflict for the whole file" } },
                { "n", "<leader>cA",    actions.conflict_choose_all("all"),    { desc = "Choose all the versions of a conflict for the whole file" } },
                { "n", "dX",            actions.conflict_choose_all("none"),   { desc = "Delete the conflict region for the whole file" } },
            },
            file_history_panel = {
                { "n", "g!",            actions.options,                    { desc = "Open the option panel" } },
                { "n", "<C-A-d>",       actions.open_in_diffview,           { desc = "Open the entry under the cursor in a diffview" } },
                { "n", "y",             actions.copy_hash,                  { desc = "Copy the commit hash of the entry under the cursor" } },
                { "n", "L",             actions.open_commit_log,            { desc = "Show commit details" } },
                { "n", "X",             actions.restore_entry,              { desc = "Restore file to the state from the selected entry" } },
                { "n", "zo",            actions.open_fold,                  { desc = "Expand fold" } },
                { "n", "zc",            actions.close_fold,                 { desc = "Collapse fold" } },
                { "n", "h",             actions.close_fold,                 { desc = "Collapse fold" } },
                { "n", "za",            actions.toggle_fold,                { desc = "Toggle fold" } },
                { "n", "zR",            actions.open_all_folds,             { desc = "Expand all folds" } },
                { "n", "zM",            actions.close_all_folds,            { desc = "Collapse all folds" } },
                { "n", "j",             actions.next_entry,                 { desc = "Bring the cursor to the next file entry" } },
                { "n", "<down>",        actions.next_entry,                 { desc = "Bring the cursor to the next file entry" } },
                { "n", "k",             actions.prev_entry,                 { desc = "Bring the cursor to the previous file entry" } },
                { "n", "<up>",          actions.prev_entry,                 { desc = "Bring the cursor to the previous file entry" } },
                { "n", "<cr>",          actions.select_entry,               { desc = "Open the diff for the selected entry" } },
                { "n", "o",             actions.select_entry,               { desc = "Open the diff for the selected entry" } },
                { "n", "l",             actions.select_entry,               { desc = "Open the diff for the selected entry" } },
                { "n", "<2-LeftMouse>", actions.select_entry,               { desc = "Open the diff for the selected entry" } },
                { "n", "<c-b>",         actions.scroll_view(-0.25),         { desc = "Scroll the view up" } },
                { "n", "<c-f>",         actions.scroll_view(0.25),          { desc = "Scroll the view down" } },
                { "n", "<tab>",         actions.select_next_entry,          { desc = "Open the diff for the next file" } },
                { "n", "<s-tab>",       actions.select_prev_entry,          { desc = "Open the diff for the previous file" } },
                { "n", "[F",            actions.select_first_entry,         { desc = "Open the diff for the first file" } },
                { "n", "]F",            actions.select_last_entry,          { desc = "Open the diff for the last file" } },
                { "n", "gf",            actions.goto_file_edit,             { desc = "Open the file in the previous tabpage" } },
                { "n", "<C-w><C-f>",    actions.goto_file_split,            { desc = "Open the file in a new split" } },
                { "n", "<C-w>gf",       actions.goto_file_tab,              { desc = "Open the file in a new tabpage" } },
                { "n", "<leader>e",     actions.focus_files,                { desc = "Bring focus to the file panel" } },
                { "n", "<leader>b",     actions.toggle_files,               { desc = "Toggle the file panel" } },
                { "n", "g<C-x>",        actions.cycle_layout,               { desc = "Cycle available layouts" } },
                { "n", "g?",            actions.help("file_history_panel"), { desc = "Open the help panel" } },
            },
            option_panel = {
                { "n", "<tab>", actions.select_entry,         { desc = "Change the current option" } },
                { "n", "q",     actions.close,                { desc = "Close the panel" } },
                { "n", "g?",    actions.help("option_panel"), { desc = "Open the help panel" } },
            },
            help_panel = {
                { "n", "q",     actions.close, { desc = "Close help menu" } },
                { "n", "<esc>", actions.close, { desc = "Close help menu" } },
            },
        },
    })
    require('gitlab').setup()
    add({ 'https://github.com/coder/claudecode.nvim' })
    require('claudecode').setup({
        terminal_cmd = "/usr/bin/eltex-claude",
        cmd = {
            "ClaudeCode",
            "ClaudeCodeFocus",
            "ClaudeCodeSelectModel",
            "ClaudeCodeAdd",
            "ClaudeCodeSend",
            "ClaudeCodeTreeAdd",
            "ClaudeCodeStatus",
            "ClaudeCodeStart",
            "ClaudeCodeStop",
            "ClaudeCodeOpen",
            "ClaudeCodeClose",
            "ClaudeCodeDiffAccept",
            "ClaudeCodeDiffDeny",
            "ClaudeCodeCloseAllDiffs",
        }
    })
end)


-- Honorable mentions =========================================================

-- 'mason-org/mason.nvim' (a.k.a. "Mason") is a great tool (package manager) for
-- installing external language servers, formatters, and linters. It provides
-- a unified interface for installing, updating, and deleting such programs.
--
-- The caveat is that these programs will be set up to be mostly used inside Neovim.
-- If you need them to work elsewhere, consider using other package managers.
--
-- You can use it like so:
-- now_if_args(function()
--   add({ 'https://github.com/mason-org/mason.nvim' })
--   require('mason').setup()
-- end)

-- Beautiful, usable, well maintained color schemes outside of 'mini.nvim' and
-- have full support of its highlight groups. Use if you don't like 'miniwinter'
-- enabled in 'plugin/30_mini.lua' or other suggested 'mini.hues' based ones.
Config.now(function()
    -- Install only those that you need
    add({
        'https://github.com/catppuccin/nvim'
        -- 'https://github.com/Shatur/neovim-ayu',
        -- 'https://github.com/ellisonleao/gruvbox.nvim',
    })

    -- Enable only one
    -- vim.cmd('color everforest')
    vim.cmd.colorscheme 'catppuccin'
end)
