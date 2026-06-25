return {
  {
    "fatih/vim-go",
    config = function()
      vim.g.go_highlight_enabled = 1
    end,
  },

  "lepture/vim-jinja",

  {
    "epwalsh/obsidian.nvim",
    version = "*",
    ft = "markdown",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      workspaces = {
        {
          name = "notes",
          path = "~/notes",
        },
      },
      notes_subdir = "notes",
      completion = {
        nvim_cmp = true,
      },
      ui = {
        enable = true,
      },
    },
  },

  {
    "iamcco/markdown-preview.nvim",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    ft = { "markdown" },
    cmd = { "MarkdownPreview", "MarkdownPreviewToggle", "MarkdownPreviewStop" },
  },
}
