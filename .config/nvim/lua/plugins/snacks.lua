return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      picker = { enabled = true },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
      styles = {
        notification = {},
      },
    },
    keys = {
      { "m<space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
      { "m,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "m/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "m:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "me", function() Snacks.explorer() end, desc = "File Explorer" },
      { "mfc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      {
        "mff",
        function()
          Snacks.picker.files({
            exclude = { "./venv/*", "./node_modules/*", "./__pycache__/*", "./.git/*", "./.cache/*" },
          })
        end,
        desc = "Find Files",
      },
      { "mfg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
      { "mfp", function() Snacks.picker.projects() end, desc = "Projects" },
      { "mfr", function() Snacks.picker.recent() end, desc = "Recent" },
      { "mgb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
      { "mgl", function() Snacks.picker.git_log() end, desc = "Git Log" },
      { "mgL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
      { "mgs", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "mgS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
      { "mgd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
      { "mgf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
      { "msb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "msB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
      { "msg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "msw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
      { 'ms"', function() Snacks.picker.registers() end, desc = "Registers" },
      { "ms/", function() Snacks.picker.search_history() end, desc = "Search History" },
      { "msa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
      { "msc", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "msC", function() Snacks.picker.commands() end, desc = "Commands" },
      { "msd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "msD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
      { "msh", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "msH", function() Snacks.picker.highlights() end, desc = "Highlights" },
      { "msi", function() Snacks.picker.icons() end, desc = "Icons" },
      { "msj", function() Snacks.picker.jumps() end, desc = "Jumps" },
      { "msk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "msm", function() Snacks.picker.marks() end, desc = "Marks" },
      { "msu", function() Snacks.picker.undo() end, desc = "Undo History" },
      { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
      { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
      { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
      { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
      { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
      { "msS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
      { "mn", function() Snacks.notifier.show_history() end, desc = "Notification History" },
      { "mcR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
      { "mun", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
      { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd

          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle.option("conceallevel", {
            off = 0,
            on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
          }):map("<leader>uc")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
          Snacks.toggle.inlay_hints():map("<leader>uh")
          Snacks.toggle.indent():map("<leader>ug")
          Snacks.toggle.dim():map("<leader>uD")
        end,
      })
    end,
  },
}
