-- =========================
-- MyOS v1.2 - Windowed OS
-- =========================

local w, h = term.getSize()

-- =========================
-- STATE
-- =========================
local windows = {}
local taskbarHeight = 1
local selectedWindow = nil

-- =========================
-- INTERNET (FAKE NETWORK)
-- =========================
local internet = {
    home = {
        title = "MyOS Net",
        body = {
            "Welcome to MyOS Internet",
            "",
            "sites:",
            "- home",
            "- help",
            "- about"
        }
    },
    help = {
        title = "Help Page",
        body = {
            "Type site name",
            "home / help / about"
        }
    },
    about = {
        title = "About Net",
        body = {
            "Simulated network system",
            "No real internet required"
        }
    }
}

-- =========================
-- WINDOW SYSTEM
-- =========================
local function createWindow(title, drawFunc)
    return {
        x = 3,
        y = 3,
        w = 30,
        h = 10,
        title = title,
        minimized = false,
        content = drawFunc,
        id = math.random(10000)
    }
end

local function closeWindow(win)
    for i, w in ipairs(windows) do
        if w.id == win.id then
            table.remove(windows, i)
            break
        end
    end
end

local function minimizeWindow(win)
    win.minimized = true
end

local function restoreWindow(win)
    win.minimized = false
end

-- =========================
-- TASK MANAGER
-- =========================
local function taskManager()
    local win = createWindow("Task Manager", function(self)
        term.setCursorPos(self.x + 2, self.y + 2)
        print("Running Windows:")

        local y = self.y + 3
        for _, w in ipairs(windows) do
            term.setCursorPos(self.x + 2, y)
            print(w.title .. (w.minimized and " [min]" or ""))
            y = y + 1
        end
    end)

    table.insert(windows, win)
end

-- =========================
-- BROWSER
-- =========================
local function browser()
    local page = "home"

    local win = createWindow("Browser", function(self)
        term.setCursorPos(self.x + 2, self.y + 2)

        local site = internet[page]

        if site then
            print(site.title)
            print("------")

            for _, line in ipairs(site.body) do
                print(line)
            end
        else
            print("404")
        end
    end)

    win.onInput = function(input)
        if internet[input] then
            page = input
        end
    end

    table.insert(windows, win)
end

-- =========================
-- NOTES WINDOW
-- =========================
local function notes()
    local text = ""

    local win = createWindow("Notes", function(self)
        term.setCursorPos(self.x + 2, self.y + 2)
        print("Type text:")
        print(text)
    end)

    win.onInput = function(input)
        text = input
        local f = fs.open("notes.txt", "w")
        f.write(text)
        f.close()
    end

    table.insert(windows, win)
end

-- =========================
-- DRAW WINDOW
-- =========================
local function drawWindow(win)
    if win.minimized then return end

    -- border
    term.setBackgroundColor(colors.gray)
    for i = 0, win.h do
        term.setCursorPos(win.x, win.y + i)
        write(string.rep(" ", win.w))
    end

    -- title bar
    term.setBackgroundColor(colors.black)
    term.setCursorPos(win.x, win.y)
    write(" X " .. win.title)

    -- close button click zone handled later
    term.setBackgroundColor(colors.gray)

    -- content
    if win.content then
        term.setBackgroundColor(colors.gray)
        win.content(win)
    end
end

-- =========================
-- TASKBAR
-- =========================
local function drawTaskbar()
    term.setBackgroundColor(colors.black)
    term.setCursorPos(1, h)
    write(string.rep(" ", w))

    term.setCursorPos(2, h)
    write("[Start] ")

    local x = 10
    for _, win in ipairs(windows) do
        term.setCursorPos(x, h)
        write(win.title)
        x = x + #win.title + 2
    end
end

-- =========================
-- START MENU
-- =========================
local function startMenu()
    term.setBackgroundColor(colors.black)
    term.setCursorPos(1,1)

    print("Start Menu")
    print("1 Browser")
    print("2 Notes")
    print("3 Task Manager")

    write("> ")
    local c = read()

    if c == "1" then browser()
    elseif c == "2" then notes()
    elseif c == "3" then taskManager()
    end
end

-- =========================
-- MAIN LOOP
-- =========================
while true do
    term.setBackgroundColor(colors.blue)
    term.clear()

    drawTaskbar()

    for _, win in ipairs(windows) do
        drawWindow(win)
    end

    local event, button, x, y = os.pullEvent()

    -- START BUTTON
    if event == "mouse_click" then

        if y == h and x < 10 then
            startMenu()
        end

        -- window click detection
        for _, win in ipairs(windows) do
            if not win.minimized then

                -- close button
                if y == win.y and x == win.x then
                    closeWindow(win)
                    break
                end
            end
        end
    end
end
