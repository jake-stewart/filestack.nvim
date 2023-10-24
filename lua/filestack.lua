table.unpack = table.unpack or unpack

local cursor = 0
local filestack = {}

local CTRL_I = vim.api.nvim_replace_termcodes('<C-I>', true, false, true)
local CTRL_O = vim.api.nvim_replace_termcodes('<C-O>', true, false, true)

local function filestackPush()
    local path = vim.fn.expand("%:p")
    if path == "" then
        return
    end

    if #filestack > 1 and filestack[cursor] == path then
        return
    end

    filestack = vim.list_slice(filestack, math.max(0, cursor - 16), cursor)
    table.insert(filestack, path)
    cursor = #filestack
end

local function jump(direction, count)
    local jumplist, jumpcursor = table.unpack(vim.fn.getjumplist())
    jumpcursor = jumpcursor + 1
    local bufnr = vim.fn.bufnr()
    local steps = 0
    for _ = 1, count do
        jumpcursor = jumpcursor + direction
        if jumpcursor > #jumplist
                or jumpcursor <= 0 or bufnr ~= jumplist[jumpcursor]["bufnr"] then
            break
        end
        steps = steps + 1
    end
    if steps == 0 then
        return
    end
    vim.cmd("norm! " .. steps .. (direction == 1 and CTRL_I or CTRL_O))
end

local function navigate(direction)
    if cursor + direction > #filestack or cursor + direction <= 0 then
        if #filestack == 0 and direction == -1 then
            vim.cmd.norm({CTRL_O, bang = true})
        end
        return
    end
    cursor = cursor + direction
    vim.cmd.edit(filestack[cursor])
end

local function setupAutocmd()
    local AU_GROUP = "FileStack"
    vim.api.nvim_create_augroup(AU_GROUP, { clear = true })
    vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "*",
        group = AU_GROUP,
        callback = filestackPush,
    })
end

return {
    setup = function()
        setupAutocmd()
        vim.keymap.set({"n", "v"}, "<c-i>", function() jump(1, 1) end)
        vim.keymap.set({"n", "v"}, "<c-o>", function() jump(-1, 1) end)
        vim.keymap.set({"n", "v"}, "<m-i>", function() navigate(1) end)
        vim.keymap.set({"n", "v"}, "<m-o>", function() navigate(-1) end)
    end,
}
