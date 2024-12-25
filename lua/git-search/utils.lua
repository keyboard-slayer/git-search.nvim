local utils = {}

function utils.git(opts)
    opts.cwd = vim.fn.expand(opts.cwd or vim.fs.dirname(vim.fn.expand("%")))
    opts.uniq = opts.uniq or false

    local cmd = 'git -C "' .. opts.cwd .. '" ' .. table.concat(opts.flags, " ")

    if opts.uniq then
        cmd = cmd .. " | sort -u"
    end

    local handle = io.popen(cmd)

    if not handle then
        error("Failed to execute git command")
    end

    local output = handle:read("*a")
    handle:close()

    if not output or output == "" then
        vim.notify(
            "No output from the command or the repository might be empty."
        )
    end

    output = output:gsub("\n$", "")
    local ret = {}

    for line in output:gmatch("[^\n]+") do
        table.insert(ret, line)
    end

    return ret
end

return utils
