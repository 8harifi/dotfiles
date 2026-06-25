return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {},
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
      "hrsh7th/cmp-nvim-lsp",
      "ray-x/lsp_signature.nvim",
    },
    opts = {
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
    },
    config = function(_, opts)
      require("mason").setup()

      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local capabilities = cmp_nvim_lsp.default_capabilities()

      local on_attach = function(client, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
        end

        map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
        map("n", "<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
        map("n", "]d", function()
          vim.diagnostic.jump({ count = 1 })
        end, "Next Diagnostic")
        map("n", "[d", function()
          vim.diagnostic.jump({ count = -1 })
        end, "Previous Diagnostic")

        require("lsp_signature").on_attach({
          bind = true,
          floating_window = true,
          hint_enable = false,
          handler_opts = { border = "rounded" },
        }, bufnr)
      end

      require("mason-lspconfig").setup(vim.tbl_extend("force", opts, {
        handlers = {
          function(server)
            require("lspconfig")[server].setup({
              capabilities = capabilities,
              on_attach = on_attach,
              handlers = {
                ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
                  border = "rounded",
                }),
              },
            })
          end,
        },
      }))
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
  },

  {
    "ray-x/lsp_signature.nvim",
    opts = {
      bind = true,
      floating_window = true,
      hint_enable = false,
      handler_opts = { border = "rounded" },
    },
  },
}
