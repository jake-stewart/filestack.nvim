table.unpack = table.unpack or unpack

local cursor = 0
local filestack = {}

local CTRL_I = vim.api.nvim_replace_termcodes('<C-I>', true, true, true)
local CTRL_O = vim.api.nvim_replace_termcodes('<C-O>', true, true, true)

-- local function debug()
--     local buffer = ""
--     for i, s in ipairs(filestack) do
--         if (i == cursor) then
--             buffer = buffer .. " ["  ..s .. "] "
--         else
--             buffer = buffer .. " " .. s .. " "
--         end
--     end
--     vim.print(buffer)
-- end

local function filestackPush()
    local success, mc = pcall(require, "multicursor-nvim")
    if success then
        mc.clearCursors()
    end

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
    local success, mc = pcall(require, "multicursor-nvim")
    if success and mc.hasCursors() then
        if direction == 1 then
            mc.jumpForward()
        else
            mc.jumpBackward()
        end
        return
    end
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
    vim.api.nvim_feedkeys(steps .. (direction == 1 and CTRL_I or CTRL_O), "nx", false)
end

local function navigate(direction)
    if cursor + direction > #filestack or cursor + direction <= 0 then
        if #filestack == 0 and direction == -1 then
            vim.api.nvim_feedkeys(CTRL_O, "nx", true)
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
    setup = function(opts)
        local defaults = {
            keymaps = {
                jump = { backward = "<c-o>", forward = "<c-i>" },
                navigate = { backward = "<m-o>", forward = "<m-i>" },
            }
        }
        local config = vim.tbl_extend("force", defaults, opts or {})
        setupAutocmd()
        vim.keymap.set({"n", "v"}, config.keymaps.jump.forward, function()
            jump(1, vim.v.count == 0 and 1 or vim.v.count)
        end)
        vim.keymap.set({"n", "v"}, config.keymaps.jump.backward, function()
            jump(-1, vim.v.count == 0 and 1 or vim.v.count)
        end)
        vim.keymap.set({"n", "v"}, config.keymaps.navigate.forward, function()
            navigate(1)
        end)
        vim.keymap.set({"n", "v"}, config.keymaps.navigate.backward, function()
            navigate(-1)
        end)
    end,
}
