local ok, obsidian = pcall(require, "obsidian")
if not ok then
  return
end

obsidian.setup({
  workspaces = {
    {
      name = "notes",
      path = "~/notes", -- change to your vault
    },
  },

  notes_subdir = "notes",

  completion = {
    nvim_cmp = true,
  },

  ui = {
    enable = true,
  },
})
