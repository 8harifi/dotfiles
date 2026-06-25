vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.number = true

vim.g.mapleader = " "

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.runtimepath:append(vim.fn.stdpath("config") .. "/lazy/lazy.nvim")

require("lazy").setup({
  { import = "plugins" },
}, {
  defaults = {
    lazy = false,
  },
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.html" },
  callback = function()
    local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, 20, false), "\n")
    if content:match("{%%.-%%}") or content:match("{{.-}}") then
      vim.bo.filetype = "htmldjango"
    end
  end,
})
