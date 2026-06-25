return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  {
    "echasnovski/mini.nvim",
    version = "*",
    config = function()
      require("mini.comment").setup({
        options = {
          ignore_blank_line = false,
          start_of_line = false,
          pad_comment_parts = true,
        },
        mappings = {
          comment = "<leader>c",
          comment_line = "<leader>c",
          comment_visual = "<leader>c",
          textobject = "<leader>c",
        },
      })
    end,
  },

  {
    "terryma/vim-expand-region",
    config = function()
      vim.g.expand_region_text_objects = {
        ["iw"] = 1,
        ["i'"] = 1,
        ['i"'] = 1,
        ["i]"] = 1,
        ["i}"] = 1,
        ["ip"] = 1,
        ["ib"] = 1,
        ["iB"] = 1,
      }
      vim.keymap.set("v", "<C-q>", "<Plug>(expand_region_expand)", { silent = true })
      vim.keymap.set("v", "<C-S-q>", "<Plug>(expand_region_shrink)", { silent = true })
    end,
  },

  "tpope/vim-commentary",
  "tpope/vim-surround",
}
