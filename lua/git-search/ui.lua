local ui = {}

local utils = require("git-search.utils")

function ui.createWindow()
    local width = vim.o.columns
    local height = vim.o.lines

    local winopts = {
        relative = "editor",
        width = width,
        height = height,
        col = 0,
        row = 0,
        style = "minimal",
        border = "none",
    }

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, winopts)

    return { buf = buf, win = win }
end

vim.api.nvim_set_hl(0, "CommitHash", {
    fg = "#808080",
})

vim.api.nvim_set_hl(0, "Langs", {
    fg = "#e46e78",
})

function ui.applyHighlight(opts)
    if opts.bufnr == nil then
        error("No buffer number was specified")
    end

    vim.fn.matchadd(
        "CommitHash",
        "\\x\\{7,64}",
        100,
        -1,
        { buffer = opts.bufnr }
    )
    vim.fn.matchadd(
        "Langs",
        "\\v\\( [^)]*(,\\s*[^)]* )*\\)",
        100,
        -1,
        { buffer = opts.bufnr }
    )
end

function ui.displayCommit(opts)
    opts.cwd = vim.fn.expand(opts.cwd or vim.fs.dirname(vim.fn.expand("%")))

    local output = utils.git({
        cwd = opts.cwd,
        flags = {
            "show",
            opts.id,
        },
    })

    local win = ui.createWindow()

    vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(win.win, true)
    end, { buffer = win.buf })

    vim.api.nvim_set_hl(0, "Author", {
        fg = "#ff0000",
    })

    if opts.author ~= nil then
        vim.fn.matchadd("Author", opts.author, 100, -1, { buffer = win.buf })
    end

    vim.api.nvim_buf_set_lines(win.buf, 0, -1, false, output)
    vim.api.nvim_set_option_value("filetype", "diff", { buf = win.buf })
end

function ui.addBindings(opts)
    opts.cwd = vim.fn.expand(opts.cwd or vim.fs.dirname(vim.fn.expand("%")))

    vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(opts.win, true)
    end, { buffer = opts.buf })

    vim.keymap.set("n", "<CR>", function()
        local line = vim.api.nvim_get_current_line()
        local s, e = vim.regex("\\x\\{7,64}"):match_str(line)

        if s == nil then
            error("No commit ?")
        end

        local commit = line:sub(s + 1, e)

        ui.displayCommit({
            cwd = opts.cwd,
            id = commit,
            author = opts.author,
        })
    end, { buffer = opts.buf })
end

return ui
