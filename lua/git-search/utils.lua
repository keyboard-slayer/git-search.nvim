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

function utils.computeDisplays(dict, langs)
    langs = langs or false

    for _, d in pairs(dict) do
        if langs then
            local r_ext = {}
            local lst_ext = {}

            for _, f in pairs(d.files) do
                local ext = f:match("^.+(%..+)$")

                if ext == nil then
                    goto continue
                end

                -- NOTE: Could be useful
                local name = vim.filetype.match({ filename = "test" .. ext })
                -- local name = ext

                if name == nil then
                    goto continue
                end

                if r_ext[name] == nil then
                    r_ext[name] = 1
                    table.insert(lst_ext, name)
                end

                ::continue::
            end

            if #lst_ext > 0 then
                d["display"] = d["name"]
                    .. " ( "
                    .. table.concat(lst_ext, ", ")
                    .. " )"
            else
                d["display"] = d["name"]
            end
        else
            d["display"] = d["name"]
        end
    end
end

function utils.getCommitDisplay(dict)
    local ret = {}
    for _, d in pairs(dict) do
        table.insert(ret, d.display)
    end

    return ret
end

return utils
