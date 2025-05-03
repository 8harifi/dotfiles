require('telescope').setup{
  defaults = {
    file_ignore_patterns = {
      "node_modules", 
      "build", 
      "dist", 
      ".git", 
      "venv", 
      "__pycache__", 
      "%.lock", 
      "%.bin"
    }
  }
}

local builtin = require("telescope.builtin")

vim.keymap.set('n', '<leader>p', builtin.find_files, {})
vim.keymap.set('n', '<leader>o', function()
  builtin.lsp_dynamic_workspace_symbols()
end, {})
