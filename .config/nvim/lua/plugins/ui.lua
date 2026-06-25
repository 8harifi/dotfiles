return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 999,
    lazy = false,
  },

  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      local color = "rose-pine"
      vim.cmd.colorscheme(color)
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
      },
    },
  },

  {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          group_empty = true,
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
            },
          },
        },
        filters = {
          dotfiles = false,
        },
        actions = {
          open_file = {
            quit_on_open = false,
            resize_window = true,
          },
        },
      })
    end,
    keys = {
      { "<C-b>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle File Explorer" },
    },
  },

  {
    "folke/which-key.nvim",
    opts = {},
  },

  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      defaults = {
        file_ignore_patterns = {
          "node_modules",
          "build",
          "dist",
          ".git",
          "venv",
          "__pycache__",
          "%.lock",
          "%.bin",
        },
      },
    },
    keys = {
      { "<leader>p", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
      {
        "<leader>o",
        function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols()
        end,
        desc = "LSP Workspace Symbols",
      },
    },
  },
}
