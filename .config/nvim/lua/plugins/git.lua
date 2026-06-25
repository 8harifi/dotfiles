return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },

  {
    "tpope/vim-fugitive",
    config = function()
      vim.keymap.set("n", "<leader>gs", function()
        vim.cmd("Git status")
      end, { desc = "Git Status" })
      vim.keymap.set("n", "<leader>gp", function()
        vim.cmd("Git push")
      end, { desc = "Git Push" })
      vim.keymap.set("n", "<leader>gc", function()
        vim.cmd("Git commit")
      end, { desc = "Git Commit" })
    end,
  },
}
