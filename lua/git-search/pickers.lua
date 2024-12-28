local ui = require("git-search.ui")
local utils = require("git-search.utils")

local hasTelescope = pcall(require, "telescope")

if not hasTelescope then
    error("Telescope is not installed")
end

local t_pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")

local pickers = {}

function pickers.authorName(opts)
    opts.cwd = vim.fn.expand(opts.cwd or vim.fs.dirname(vim.fn.expand("%")))

    return t_pickers.new(opts, {
        prompt_title = "Find commits by author",
        finder = finders.new_table({ results = opts.authors }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(_, map)
            local function on_select()
                local selection = action_state.get_selected_entry()
                local flags = {
                    "log",
                    '--author="' .. selection[1] .. '"',
                    "--name-only",
                }

                if opts.config.show_dates then
                    table.insert(flags, '--pretty="%cd %h %s"')
                    if opts.config.eu then
                        table.insert(flags, "--date=format:'%d-%m-%Y'")
                    else
                        table.insert(flags, "--date=format:'%Y-%m-%d'")
                    end
                else
                    table.insert(flags, '--pretty="%h %s"')
                end

                print(table.concat(flags, " "))
                local output = utils.git({
                    cwd = opts.cwd,
                    flags = flags,
                })

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

                utils.computeDisplays(commits, opts.config.show_langage)

                local win = ui.createWindow()
                ui.applyHighlight({ bufnr = win.buf })

                vim.keymap.set("n", "q", function()
                    vim.api.nvim_win_close(win.win, true)
                end, { buffer = win.buf })

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
                        author = selection[1],
                    })
                end, { buffer = win.buf })

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

            map("i", "<CR>", on_select)
            map("n", "<CR>", on_select)

            return true
        end,
    })
end

return pickers
