return {
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "lewis6991/async.nvim",
    },
    keys = {
      {
        mode = { "n", "x" },
        "<leader>;",
        function()
          require("refactoring").select_refactor()
        end,
        desc = "Refactor Menu",
      },
      {
        mode = { "n", "x" },
        "<leader>ev",
        function()
          return require("refactoring").extract_var()
        end,
        desc = "Extract Variable",
        expr = true,
      },
    },
  },
}
