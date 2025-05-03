config = {
    -- Options which control module behavior
    options = {
        custom_commentstring = nil,
        ignore_blank_line = false,
        start_of_line = false,
        pad_comment_parts = true,
    },

    -- Module mappings. Use `''` (empty string) to disable one.
    mappings = {
        comment = '<leader>c',
        comment_line = '<leader>c',
        comment_visual = '<leader>c',
        textobject = '<leader>c',
    },

    -- Hook functions to be executed at certain stage of commenting
    hooks = {
        pre = function() end,
        post = function() end,
    },
}

require("mini.comment").setup(config)

