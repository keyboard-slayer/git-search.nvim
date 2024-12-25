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

return ui
