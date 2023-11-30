local Data = require("harpoon2.data")

local M = {}

M.created_files = {}

---@param name string
function M.before_each(name)
    return function()
        Data.set_data_path(name)
        Data.__dangerously_clear_data()

        require("plenary.reload").reload_module("harpoon2")
        Data = require("harpoon2.data")
        Data.set_data_path(name)
        local harpoon = require("harpoon2")

        M.clean_files()

        harpoon:setup({
            settings = {
                key = function()
                    return "testies"
                end,
            },
        })
    end
end

function M.clean_files()
    for _, bufnr in ipairs(M.created_files) do
        vim.api.nvim_buf_delete(bufnr, { force = true })
    end

    M.created_files = {}
end

---@param name string
---@param contents string[]
function M.create_file(name, contents, row, col)
    local bufnr = vim.fn.bufnr(name, true)
    vim.api.nvim_set_current_buf(bufnr)
    vim.api.nvim_buf_set_text(0, 0, 0, 0, 0, contents)
    if row then
        vim.api.nvim_win_set_cursor(0, { row or 1, col or 0 })
    end

    table.insert(M.created_files, bufnr)
    return bufnr
end

---@param count number
---@param list HarpoonList
function M.fill_list_with_files(count, list)
    local files = {}

    for _ = 1, count do
        local name = os.tmpname()
        table.insert(files, name)
        M.create_file(name, { "test" })
        list:append()
    end

    return files
end

return M