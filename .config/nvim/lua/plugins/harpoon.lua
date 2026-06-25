return {
  {
    "ThePrimeagen/harpoon",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local mark = require("harpoon.mark")
      local ui = require("harpoon.ui")

      vim.keymap.set("n", "<leader>a", mark.add_file, { desc = "Harpoon Add File" })
      vim.keymap.set("n", "<leader>e", ui.toggle_quick_menu, { desc = "Harpoon Menu" })

      for i, key in ipairs({ "h", "t", "n", "s", "5", "6", "7", "8", "9", "0" }) do
        vim.keymap.set("n", "<leader>" .. key, function()
          ui.nav_file(i)
        end, { desc = "Harpoon File " .. i })
      end
    end,
  },
}
