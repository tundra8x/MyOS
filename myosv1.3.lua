-- =========================
-- MyOS v1.3 (Keyboard Window OS)
-- =========================

local w, h = term.getSize()

-- =========================
-- STATE
-- =========================
local windows = {}
local active = 1
local cursor = {x = 1, y = 1}

-- =========================
-- INTERNET (FAKE)
-- =========================
local web = {
    home = {
        "MyOS Internet",
        "",
        "pages:",
        "home / help / about"
    },
    help = {
        "Help Page",
        "Use keyboard to navigate",
        "TAB switch window"
    },
    about = {
        "MyOS v1.3",
        "Keyboard OS prototype"
    }
}

-- =========================
-- WINDOW SYSTEM
-- =========================
local function newWindow(title, draw, input)
    return {
        title = title,
        content = {},
        input = input,
        draw = draw,
        minimized = false
    }
end

local function createWindow(win)
    table.insert(windows, win)
    active = #windows
end

local function closeWindow(i)
    table.remove(windows, i)
    if active > #windows then active = #windows end
end

local function switchWindow()
    if #windows == 0 then return end
    active = active + 1
    if active > #windows then active = 1 end
end

-- =========================
-- TASKBAR
-- =========================
local function drawTaskbar()
    term.setBackgroundColor(colors.gray)

    for x = 1, w do
        term.setCursorPos(x, h)
        write(" ")
    end

    term.setCursorPos(2, h)
    term.setTextColor(colors.black)
    write("MyOS v1.3")

    local x = 15
    for i, win in ipairs(windows) do
        term.setCursorPos(x, h)

        if i == active then
            term.setTextColor(colors.yellow)
        else
            term.setTextColor(colors.black)
        end

        write(win.title)
        x = x + #win.title + 2
    end
end

-- =========================
-- WINDOW RENDER
-- =========================
local function drawWindows()
    for i, win in ipairs(windows) do
        if not win.minimized then

            local ox, oy = 2, 2

            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)

            -- border box
            for y = 1, 10 do
                term.setCursorPos(ox, oy + y)
                write(string.rep(" ", 40))
            end

            -- title
            term.setCursorPos(ox, oy)
            write("[" .. win.title .. "]  (X close  M minimize)")

            -- content
            if win.draw then
                win.draw(ox, oy + 2, win.content, i == active)
            end

            -- cursor (only active window)
            if i == active then
                term.setCursorPos(ox + cursor.x, oy + cursor.y)
                term.setBackgroundColor(colors.white)
                write(" ")
            end
        end
    end
end

-- =========================
-- APPS
-- =========================

-- NOTES
local function notesApp()
    local text = ""

    return newWindow("Notes",
        function(x, y)
            term.setCursorPos(x + 1, y)
            print("Type text:")
            term.setCursorPos(x + 1, y + 1)
            write(text)
        end,
        function(key)
            if key == keys.backspace then
                text = text:sub(1, -2)
            end
        end
    )
end

-- BROWSER
local function browserApp()
    local page = "home"

    return newWindow("Browser",
        function(x, y)
            term.setCursorPos(x + 1, y)
            local p = web[page] or {"404"}

            for i, line in ipairs(p) do
                term.setCursorPos(x + 1, y + i - 1)
                print(line)
            end
        end,
        function(key)
            if key == keys.one then page = "home"
            elseif key == keys.two then page = "help"
            elseif key == keys.three then page = "about"
            end
        end
    )
end

-- CMD
local function cmdApp()
    local path = "/"
    local output = {}

    return newWindow("CMD",
        function(x, y)
            term.setCursorPos(x + 1, y)
            print(path .. ">")

            for i = math.max(1, #output - 5), #output do
                term.setCursorPos(x + 1, y + (i))
                print(output[i])
            end
        end,
        function(key)
            if key == keys.enter then
                write(path .. "> ")
                local input = read()

                table.insert(output, input)

                local args = {}
                for w in string.gmatch(input, "%S+") do
                    table.insert(args, w)
                end

                local c = args[1]

                if c == "ls" then
                    for _, f in ipairs(fs.list(path)) do
                        table.insert(output, f)
                    end

                elseif c == "cd" and args[2] then
                    if args[2] == ".." then
                        path = fs.getDir(path)
                        if path == "" then path = "/" end
                    else
                        local p = fs.combine(path, args[2])
                        if fs.isDir(p) then path = p end
                    end
                end
            end
        end
    )
end

-- =========================
-- START MENU
-- =========================
local function startMenu()
    print("1 Notes")
    print("2 Browser")
    print("3 CMD")

    local c = read()

    if c == "1" then createWindow(notesApp())
    elseif c == "2" then createWindow(browserApp())
    elseif c == "3" then createWindow(cmdApp())
    end
end

-- =========================
-- MAIN LOOP
-- =========================
term.setBackgroundColor(colors.black)
term.clear()

while true do
    term.setBackgroundColor(colors.blue)
    term.clear()

    drawTaskbar()
    drawWindows()

    local event, key = os.pullEvent()

    if event == "key" then

        if key == keys.tab then
            switchWindow()

        elseif key == keys.x then
            closeWindow(active)

        elseif key == keys.m then
            if windows[active] then
                windows[active].minimized = not windows[active].minimized
            end

        elseif key == keys.s then
            startMenu()

        elseif windows[active] and windows[active].input then
            windows[active].input(key)
        end

        -- cursor movement
        if key == keys.up then cursor.y = cursor.y - 1 end
        if key == keys.down then cursor.y = cursor.y + 1 end
        if key == keys.left then cursor.x = cursor.x - 1 end
        if key == keys.right then cursor.x = cursor.x + 1 end
    end
end
