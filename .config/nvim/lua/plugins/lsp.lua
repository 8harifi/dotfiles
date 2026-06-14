return {
  {
    "williamboman/mason.nvim",
    config = true,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright",
          "ts_ls",
          "gopls",
          "lua_ls",
          "bashls",
          "clangd",
          "html",
          "cssls",
          "jsonls",
          "yamlls",
        },
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-lspconfig.nvim" },
    config = function()
      local lspconfig = require("lspconfig")

      local handlers = {
        ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
          border = "rounded",
        }),
      }

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local servers = {
        "pyright",
        "ts_ls",
        "gopls",
        "lua_ls",
        "bashls",
        "clangd",
        "html",
        "cssls",
        "jsonls",
        "yamlls",
      }

      for _, server in ipairs(servers) do
        lspconfig[server].setup({
          handlers = handlers,
          capabilities = capabilities,
        })
      end
    end,
  },
}
