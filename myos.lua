-- MyOS v0.1
-- Simple ComputerCraft Operating System

local w, h = term.getSize()

-- Colors
local bg = colors.blue
local taskbar = colors.gray
local text = colors.white

-- Apps
local apps = {
    {
        name = "Notes",
        x = 3,
        y = 3
    },
    {
        name = "Snake",
        x = 15,
        y = 3
    },
    {
        name = "Shutdown",
        x = 27,
        y = 3
    }
}

-- Draw desktop
local function drawDesktop()
    term.setBackgroundColor(bg)
    term.clear()

    -- Draw taskbar
    term.setBackgroundColor(taskbar)

    for x = 1, w do
        term.setCursorPos(x, h)
        write(" ")
    end

    term.setCursorPos(2, h)
    term.setTextColor(colors.black)
    write("MyOS v0.1")

    -- Draw app icons
    term.setBackgroundColor(bg)
    term.setTextColor(text)

    for _, app in ipairs(apps) do
        term.setCursorPos(app.x, app.y)
        write("[" .. app.name .. "]")
    end
end

-- Notes app
local function openNotes()
    term.setBackgroundColor(colors.black)
    term.clear()

    term.setCursorPos(1,1)
    print("=== NOTES ===")
    print("Type something:")
    print("")

    local textInput = read()

    local file = fs.open("notes.txt", "w")
    file.write(textInput)
    file.close()

    print("")
    print("Saved!")
    sleep(1.5)
end

-- Snake launcher
local function openSnake()
    term.clear()
    shell.run("snake")
end

-- Main desktop loop
while true do
    drawDesktop()

    local event, button, x, y = os.pullEvent()

    if event == "mouse_click" then

        -- Notes
        if y == 3 and x >= 3 and x <= 9 then
            openNotes()
        end

        -- Snake
        if y == 3 and x >= 15 and x <= 21 then
            openSnake()
        end

        -- Shutdown
        if y == 3 and x >= 27 and x <= 37 then
            term.setBackgroundColor(colors.black)
            term.clear()
            term.setCursorPos(1,1)

            os.shutdown()
        end
    end
end
