local configs = require("nvim-treesitter.configs")
configs.setup({
	autotag = { enable = true },
    ensure_installed = {"python", "javascript", "lua", "vim", "go"},
    sync_install = false,
    highlight = { disable = { "go" } },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        node_incremental = "<C-q>",
        node_decremental = "<C-S-q>",
      },
    },
})
