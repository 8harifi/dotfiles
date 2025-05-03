vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.g.mapleader = " "
vim.cmd("set number")

-- Set up LazyVim in Neovim
vim.opt.runtimepath:append("~/.local/share/nvim/site/pack/packer/start/lazy.nvim")

local plugins = {
    "lepture/vim-jinja",

    -- Autotag for HTML, JSX, etc.
    "windwp/nvim-ts-autotag",

    -- Autopairs for brackets/quotes
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = function()
        require("nvim-autopairs").setup({})
      end,
    },


    "rafamadriz/friendly-snippets",

    -- comment lines
    {'echasnovski/mini.nvim', version = '*'},

    -- File explorer
    "kyazdani42/nvim-tree.lua",

    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      ---@type snacks.Config
      opts = {
        bigfile = { enabled = true },
        dashboard = { enabled = true },
        -- explorer = { enabled = true },
        indent = { enabled = true },
        input = { enabled = true },
        notifier = {
          enabled = true,
          timeout = 3000,
        },
        picker = { enabled = true },
        quickfile = { enabled = true },
        scope = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        styles = {
          notification = {
            -- wo = { wrap = true } -- Wrap notifications
          }
        }
      },
      keys = {
        -- Top Pickers & Explorer
        { "m<space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
        { "m,", function() Snacks.picker.buffers() end, desc = "Buffers" },
        { "m/", function() Snacks.picker.grep() end, desc = "Grep" },
        { "m:", function() Snacks.picker.command_history() end, desc = "Command History" },
        -- { "me", function() Snacks.explorer() end, desc = "File Explorer" },
        -- find
        { "mfc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
        { "mff", function() Snacks.picker.files({ exclude = { "./venv/*", "./node_modules/*", "./__pycache__/*", "./.git/*", "./.cache/*" } }) end, desc = "Find Files" },
        { "mfg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
        { "mfp", function() Snacks.picker.projects() end, desc = "Projects" },
        { "mfr", function() Snacks.picker.recent() end, desc = "Recent" },
        -- git
        { "mgb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
        { "mgl", function() Snacks.picker.git_log() end, desc = "Git Log" },
        { "mgL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
        { "mgs", function() Snacks.picker.git_status() end, desc = "Git Status" },
        { "mgS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
        { "mgd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
        { "mgf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
        -- Grep
        { "msb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
        { "msB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
        { "msg", function() Snacks.picker.grep() end, desc = "Grep" },
        { "msw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
        -- search
        { 'ms"', function() Snacks.picker.registers() end, desc = "Registers" },
        { 'ms/', function() Snacks.picker.search_history() end, desc = "Search History" },
        { "msa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
        { "msb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
        { "msc", function() Snacks.picker.command_history() end, desc = "Command History" },
        { "msC", function() Snacks.picker.commands() end, desc = "Commands" },
        { "msd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
        { "msD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
        { "msh", function() Snacks.picker.help() end, desc = "Help Pages" },
        { "msH", function() Snacks.picker.highlights() end, desc = "Highlights" },
        { "msi", function() Snacks.picker.icons() end, desc = "Icons" },
        { "msj", function() Snacks.picker.jumps() end, desc = "Jumps" },
        { "msk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
        { "msm", function() Snacks.picker.marks() end, desc = "Marks" },
        { "msu", function() Snacks.picker.undo() end, desc = "Undo History" },
        -- LSP
        { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
        { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
        { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
        { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
        { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
        { "msS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
        -- Other
        { "mn",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
        { "mcR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
        { "mun", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
        { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
        { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
      },
      init = function()
        vim.api.nvim_create_autocmd("User", {
          pattern = "VeryLazy",
          callback = function()
            -- Setup some globals for debugging (lazy-loaded)
            _G.dd = function(...)
              Snacks.debug.inspect(...)
            end
            _G.bt = function()
              Snacks.debug.backtrace()
            end
            vim.print = _G.dd -- Override print to use snacks for `:=` command

            -- Create some toggle mappings
            Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
            Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
            Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
            Snacks.toggle.diagnostics():map("<leader>ud")
            Snacks.toggle.line_number():map("<leader>ul")
            Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
            Snacks.toggle.treesitter():map("<leader>uT")
            Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
            Snacks.toggle.inlay_hints():map("<leader>uh")
            Snacks.toggle.indent():map("<leader>ug")
            Snacks.toggle.dim():map("<leader>uD")
          end,
        })
      end,
    },

    {
    "nvim-telescope/telescope.nvim", tag = "0.1.8",
      dependencies = { "nvim-lua/plenary.nvim" }
    },
    {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate"},
    -- lsp
    "neovim/nvim-lspconfig",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip",
    -- Autocompletion plugin
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",          -- LSP source for nvim-cmp
    "hrsh7th/cmp-buffer",            -- Buffer source for nvim-cmp
    "hrsh7th/cmp-path",              -- Path source for nvim-cmp
    "saadparwaiz1/cmp_luasnip",      -- Snippet source for nvim-cmp
    "L3MON4D3/LuaSnip",              -- Snippet engine

    -- color schemes
    { "catppuccin/nvim", name = "catppuccin", priority = 999 },
    { "rose-pine/neovim", name = "rose-pine" },

    -- Formatter
    "jose-elias-alvarez/null-ls.nvim",
    -- Git
    "tpope/vim-fugitive",
    "lewis6991/gitsigns.nvim",
    -- Themes
    "nvim-lualine/lualine.nvim",
    -- Utilities
    "tpope/vim-commentary",
    "tpope/vim-surround",
    "folke/which-key.nvim",

    -- harpoon
    'nvim-lua/plenary.nvim',
    'ThePrimeagen/harpoon',

    -- vim-go
    {
        "fatih/vim-go",
        lazy = false,  -- Load it immediately
        config = function()
            vim.g.go_highlight_enabled = 1  -- Ensure syntax highlighting is enabled
        end,
    },

    {
      "terryma/vim-expand-region",
      config = function()
        vim.g.expand_region_text_objects = {
          ["iw"] = 1, -- Inner word
          ["i'"] = 1, -- Inside single quotes
          ['i"'] = 1, -- Inside double quotes
          ["i]"] = 1, -- Inside square brackets
          ["i}"] = 1, -- Inside curly braces
          ["ip"] = 1, -- Inside paragraph
          ["ib"] = 1, -- Inside parentheses
          ["iB"] = 1, -- Inside block (big brackets)
        }
        vim.api.nvim_set_keymap("v", "<C-q>", "<Plug>(expand_region_expand)", { noremap = true, silent = true })
        vim.api.nvim_set_keymap("v", "<C-S-q>", "<Plug>(expand_region_shrink)", { noremap = true, silent = true })
      end
    },


    {
      "ray-x/lsp_signature.nvim",
      config = function()
        require "lsp_signature".setup({
          bind = true,
          floating_window = true, -- Show the signature in a floating window
          hint_enable = false, -- Disable inline hints (optional)
          hint_prefix = "", -- Remove prefix
          hi_parameter = "Search", -- Highlight current parameter
          handler_opts = { border = "rounded" }, -- Rounded border for floating window
        })
      end
    },


    {
        "iamcco/markdown-preview.nvim",
        build = function() vim.fn["mkdp#util#install"]() end,
        ft = { "markdown" }, -- Load only for markdown files
        cmd = { "MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop" }, -- Lazy load on command use
    },
}

local opts = {}

require("lazy").setup(plugins, opts)

-- Set up treesitter
local configs = require("nvim-treesitter.configs")
configs.setup({
    ensure_installed = {"python", "javascript", "lua", "vim", "go"},
    sync_install = false,
    highlight = { disable = { "go" } },
    indent = { enable = true }
})

configs.setup({
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.html" },
  callback = function()
    -- Check for Django template markers in the file
    local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, 20, false), "\n")
    if content:match("{%%.-%%}") or content:match("{{.-}}") then
      vim.bo.filetype = "htmldjango"
    end
  end,
})


require("luasnip.loaders.from_vscode").lazy_load()


-- Nvim-tree setup
require'nvim-tree'.setup{}

null_ls = require('null-ls')
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.black, -- Python
  }
})

-- Set up Git related shits
require('gitsigns').setup()

-- Which-key setup
require("which-key").setup {}

-- Other Custom keybinds
vim.keymap.set("n", "<C-b>", ":NvimTreeToggle<CR>", { silent = true })

