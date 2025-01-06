local utils = require("git-search.utils")
local pickers = require("git-search.pickers")
local ui = require("git-search.ui")

local Config = {
    eu = false,
    show_langage = false,
    show_dates = false,
    max_commits = 100,
}

local M = {}

M.setup = function(opts)
    Config.eu = opts.eu or false
    Config.show_langage = opts.show_langage or false
    Config.show_dates = opts.show_dates or false
    Config.max_commits = opts.max_commits or 100

    vim.api.nvim_create_user_command(
        "GitLookupAuthor",
        M.lookupByAuthorName,
        {}
    )

    vim.api.nvim_create_user_command("GitLookupRecent", M.lookupRecents, {})
end

M.lookupByAuthorName = function(opts)
    opts = opts or {}
    opts.cwd = vim.fn.expand(opts.cwd or vim.fs.dirname(vim.fn.expand("%")))

    if vim.fn.isdirectory(opts.cwd) == 0 then
        error(opts.cwd .. " Is not a valid directory")
    end

    local authors = utils.git({
        cwd = opts.cwd,
        flags = { "log", "--pretty='%an'" },
        uniq = true,
    })

    pickers
        .authorName({ authors = authors, cwd = opts.cwd, config = Config })
        :find()
end

M.lookupRecents = function(opts)
    opts = opts or {}
    opts.cwd = vim.fn.expand(opts.cwd or vim.fs.dirname(vim.fn.expand("%")))

    if vim.fn.isdirectory(opts.cwd) == 0 then
        error(opts.cwd .. " Is not a valid directory")
    end

    local flags = {
        "log",
        string.format("-n%d", Config.max_commits),
        '--pretty="%cd %h %s"',
        "--name-only",
    }

    utils.addOptionalFlags(flags, Config)

    local output = utils.git({
        cwd = opts.cwd,
        flags = flags,
    })

    local commits = utils.computeCommits(output, Config.show_langage)

    local win = ui.createWindow()
    ui.applyHighlight({ bufnr = win.buf })

    ui.addBindings({
        buf = win.buf,
        win = win.win,
        cwd = opts.cwd,
    })

    vim.api.nvim_buf_set_lines(
        win.buf,
        0,
        -1,
        false,
        utils.getCommitDisplay(commits)
    )

    vim.bo[win.buf].modifiable = false
    vim.cmd("stopinsert")
end

return M
