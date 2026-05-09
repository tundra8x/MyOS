-- =========================
-- MyOS v0.2 (ComputerCraft OS)
-- =========================

local w, h = term.getSize()

-- Colors
local bg = colors.blue
local taskbar = colors.gray
local text = colors.white

-- Apps
local apps = {
    { name = "Notes", x = 3, y = 3 },
    { name = "Snake", x = 15, y = 3 },
    { name = "Files", x = 27, y = 3 },
    { name = "Shutdown", x = 3, y = 6 }
}

-- =========================
-- DRAW DESKTOP
-- =========================
local function drawDesktop(selected)
    term.setBackgroundColor(bg)
    term.clear()

    -- Taskbar
    term.setBackgroundColor(taskbar)
    for x = 1, w do
        term.setCursorPos(x, h)
        write(" ")
    end

    term.setCursorPos(2, h)
    term.setTextColor(colors.black)
    write("MyOS v0.2")

    -- Apps
    for i, app in ipairs(apps) do
        term.setTextColor(text)
        term.setBackgroundColor(bg)

        if selected == i then
            term.setTextColor(colors.yellow)
        end

        term.setCursorPos(app.x, app.y)
        write("[" .. app.name .. "]")
    end
end

-- =========================
-- NOTES APP
-- =========================
local function openNotes()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,1)

    print("=== NOTES ===")
    print("Type something to save:")
    print()

    local input = read()

    local file = fs.open("notes.txt", "w")
    file.write(input)
    file.close()

    print("\nSaved!")
    sleep(1.5)
end

-- =========================
-- SNAKE LAUNCHER
-- =========================
local function openSnake()
    term.clear()
    shell.run("snake")
end

-- =========================
-- FILE EXPLORER
-- =========================
local function fileExplorer(path)
    path = path or "/"

    while true do
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)

        print("=== FILES: " .. path .. " ===")
        print("0 = back")
        print("Enter number to open")
        print()

        local files = fs.list(path)

        for i, file in ipairs(files) do
            print(i .. " - " .. file)
        end

        write("\n> ")
        local input = read()
        local choice = tonumber(input)

        if choice == 0 then
            return
        end

        local selected = files[choice]

        if selected then
            local fullPath = fs.combine(path, selected)

            if fs.isDir(fullPath) then
                fileExplorer(fullPath)
            else
                local f = fs.open(fullPath, "r")

                term.clear()
                term.setCursorPos(1,1)

                print("=== " .. selected .. " ===")
                print(f.readAll())
                f.close()

                print("\nPress Enter...")
                read()
            end
        end
    end
end

-- =========================
-- OPEN APP HANDLER
-- =========================
local function openApp(appName)
    if appName == "Notes" then
        openNotes()
    elseif appName == "Snake" then
        openSnake()
    elseif appName == "Files" then
        fileExplorer("/")
    elseif appName == "Shutdown" then
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)
        os.shutdown()
    end
end

-- =========================
-- MAIN LOOP (KEYBOARD UI)
-- =========================
local selected = 1

while true do
    drawDesktop(selected)

    local event, key = os.pullEvent("key")

    if key == keys.d then
        selected = selected + 1
        if selected > #apps then selected = 1 end
    end

    if key == keys.a then
        selected = selected - 1
        if selected < 1 then selected = #apps end
    end

    if key == keys.enter then
        openApp(apps[selected].name)
    end
end
