return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = { "windwp/nvim-ts-autotag" },
    opts = {
      autotag = { enable = true },
      ensure_installed = {
        "python",
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "lua",
        "vim",
        "vimdoc",
        "go",
        "bash",
        "json",
        "yaml",
        "markdown",
        "markdown_inline",
      },
      sync_install = false,
      highlight = {
        enable = true,
        disable = { "go" },
      },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          node_incremental = "<C-q>",
          node_decremental = "<C-S-q>",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
