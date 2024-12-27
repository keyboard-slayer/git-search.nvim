local ui = require("git-search.ui")
local git = require("git-search.utils").git

local hasTelescope = pcall(require, "telescope")

if not hasTelescope then
    error("Telescope is not installed")
end

local t_pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")

local pickers = {}

function pickers.authorName(opts)
    opts.cwd = vim.fn.expand(opts.cwd or vim.fs.dirname(vim.fn.expand("%")))

    return t_pickers.new(opts, {
        prompt_title = "Find commits by author",
        finder = finders.new_table({ results = opts.authors }),
        sorter = conf.generic_sorter(opts),
        previewer = previewers.new_buffer_previewer({
            title = "Commits Details",
            define_preview = function(self, entry)
                local flags = {
                    "log",
                    '--pretty="%h %s"',
                    '--author="' .. entry.display .. '"',
                }
                local output = git({
                    cwd = opts.cwd,
                    flags = flags,
                })

                vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, true, output)
            end,
        }),
        attach_mappings = function(_, map)
            local function on_select()
                local selection = action_state.get_selected_entry()
                local flags = {
                    "log",
                    '--pretty="%cd %h %s"',
                    '--author="' .. selection[1] .. '"',
                }

                if opts.config.eu then
                    table.insert(flags, "--date=format:'%d-%m-%Y'")
                else
                    table.insert(flags, "--date=format:'%Y-%m-%d'")
                end

                local output = git({
                    cwd = opts.cwd,
                    flags = flags,
                })

                local win = ui.createWindow()

                vim.keymap.set("n", "q", function()
                    vim.api.nvim_win_close(win.win, true)
                end, { buffer = win.buf })

                vim.api.nvim_buf_set_lines(win.buf, 0, -1, false, output)
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
