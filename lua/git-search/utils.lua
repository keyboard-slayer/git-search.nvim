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

function utils.computeCommits(output, langs)
    langs = langs or false

    local commits = {}
    local currentObj = {}

    for _, line in pairs(output) do
        if string.find(line, string.rep("%x", 7)) ~= nil then
            if currentObj.name ~= nil then
                table.insert(commits, currentObj)
            end

            currentObj = { name = line, files = {}, display = "" }
        else
            table.insert(currentObj.files, line)
        end
    end

    table.insert(commits, currentObj)

    for _, d in pairs(commits) do
        if langs then
            local r_ext = {}
            local lst_ext = {}

            for _, f in pairs(d.files) do
                local ext = f:match("^.+(%..+)$")

                if ext == nil then
                    goto continue
                end

                local name = vim.filetype.match({ filename = "test" .. ext })

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

    return commits
end

function utils.getCommitDisplay(dict)
    local ret = {}
    for _, d in pairs(dict) do
        table.insert(ret, d.display)
    end

    return ret
end

function utils.addOptionalFlags(flags, config)
    if config.show_dates then
        table.insert(flags, '--pretty="%cd %h %s"')
        if config.eu then
            table.insert(flags, "--date=format:'%d-%m-%Y'")
        else
            table.insert(flags, "--date=format:'%Y-%m-%d'")
        end
    else
        table.insert(flags, '--pretty="%h %s"')
    end
end

return utils
