local git = require("git-search.utils").git
local pickers = require("git-search.pickers")

local Config = {
    eu = false,
    show_langage = false,
    show_dates = false,
}

local M = {}

M.setup = function(opts)
    Config.eu = opts.eu or false
    Config.show_langage = opts.show_langage or false
    Config.show_dates = opts.show_dates or false

    vim.api.nvim_create_user_command(
        "GitLookupAuthor",
        M.lookupByAuthorName,
        {}
    )
end

M.lookupByAuthorName = function(opts)
    opts = opts or {}

    opts.cwd = vim.fn.expand(opts.cwd or vim.fs.dirname(vim.fn.expand("%")))

    if vim.fn.isdirectory(opts.cwd) == 0 then
        error(opts.cwd .. " Is not a valid directory")
    end

    local authors = git({
        cwd = opts.cwd,
        flags = { "log", "--pretty='%an'" },
        uniq = true,
    })

    pickers
        .authorName({ authors = authors, cwd = opts.cwd, config = Config })
        :find()
end

return M
