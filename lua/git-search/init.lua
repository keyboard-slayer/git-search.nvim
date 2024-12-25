local git = require("git-search.utils").git
local pickers = require("git-search.pickers")

local Config = {
    eu = false,
}

local M = {}

M.setup = function(opts)
    Config.eu = opts.eu or false
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

vim.api.nvim_create_user_command("GitLookupAuthor", M.lookupByAuthorName, {})

return M
