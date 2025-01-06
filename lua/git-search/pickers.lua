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
                    string.format("-n%d", opts.config.max_commits),
                    '--author="' .. selection[1] .. '"',
                    "--name-only",
                }

                utils.addOptionalFlags(flags, opts.config)

                local output = utils.git({
                    cwd = opts.cwd,
                    flags = flags,
                })

                local commits =
                    utils.computeCommits(output, opts.config.show_langage)

                local win = ui.createWindow()

                ui.applyHighlight({ bufnr = win.buf })

                ui.addBindings({
                    buf = win.buf,
                    win = win.win,
                    author = selection[1],
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

            map("i", "<CR>", on_select)
            map("n", "<CR>", on_select)

            return true
        end,
    })
end

return pickers
