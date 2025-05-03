local lspconfig = require("lspconfig")

local border = "rounded"

local handlers = {
  ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
  ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
}

local servers = { "pyright", "ts_ls", "gopls", "lua_ls", "bashls", "clangd", "html", "cssls", "jsonls", "yamlls" }
for _, server in ipairs(servers) do
  lspconfig[server].setup {
    handlers = handlers,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
  }
end

vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 4,
  },
  float = {
    border = border,
    source = "always",
  },
})

-- vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
-- vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Find References" })
-- vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show Hover Info" })
-- vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename Symbol" })
-- vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code Actions" })

