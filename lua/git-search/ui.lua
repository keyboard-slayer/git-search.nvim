local ui = {}

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
        error("No window number was specified")
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
        "\\v\\([^)]*(,\\s*[^)]*)*\\)",
        100,
        -1,
        { buffer = opts.bufnr }
    )
end

return ui
