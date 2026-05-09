-- =========================
-- MyOS v0.3 (ComputerCraft OS)
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
    { name = "CMD", x = 3, y = 6 },
    { name = "Shutdown", x = 15, y = 6 }
}

-- =========================
-- DESKTOP DRAW
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
    write("MyOS v0.3")

    -- Apps
    for i, app in ipairs(apps) do
        term.setBackgroundColor(bg)

        if i == selected then
            term.setTextColor(colors.yellow)
        else
            term.setTextColor(text)
        end

        term.setCursorPos(app.x, app.y)
        write("[" .. app.name .. "]")
    end
end

-- =========================
-- NOTES
-- =========================
local function openNotes()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,1)

    print("=== NOTES ===")
    print("Type text to save:")
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
        print("Select number")

        local files = fs.list(path)

        for i, file in ipairs(files) do
            print(i .. " - " .. file)
        end

        write("> ")
        local input = read()
        local choice = tonumber(input)

        if choice == 0 then return end

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
-- CMD PROMPT
-- =========================
local function cmdPrompt()
    local path = "/"

    while true do
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)

        term.setTextColor(colors.green)
        print("MyOS CMD v0.3")
        print("Type 'help' for commands")
        print("Dir: " .. path)
        print("---------------------")

        term.setTextColor(colors.white)
        write(path .. "> ")

        local input = read()
        local args = {}

        for word in string.gmatch(input, "%S+") do
            table.insert(args, word)
        end

        local cmd = args[1]

        if cmd == "help" then
            print("Commands:")
            print("ls, cd, mkdir, touch, rm, cat, exit")
            sleep(2)

        elseif cmd == "ls" then
            local files = fs.list(path)
            for _, f in ipairs(files) do
                print(f)
            end
            sleep(1)

        elseif cmd == "cd" then
            local target = args[2]

            if target == ".." then
                path = fs.getDir(path)
                if path == "" then path = "/" end
            elseif target then
                local newPath = fs.combine(path, target)
                if fs.isDir(newPath) then
                    path = newPath
                else
                    print("Not a directory")
                    sleep(1)
                end
            end

        elseif cmd == "mkdir" then
            if args[2] then
                fs.makeDir(fs.combine(path, args[2]))
            end

        elseif cmd == "touch" then
            if args[2] then
                local f = fs.open(fs.combine(path, args[2]), "w")
                f.write("")
                f.close()
            end

        elseif cmd == "rm" then
            if args[2] then
                fs.delete(fs.combine(path, args[2]))
            end

        elseif cmd == "cat" then
            if args[2] then
                local f = fs.open(fs.combine(path, args[2]), "r")
                if f then
                    print(f.readAll())
                    f.close()
                end
                sleep(2)
            end

        elseif cmd == "exit" then
            return

        else
            print("Unknown command")
            sleep(1)
        end
    end
end

-- =========================
-- APP HANDLER
-- =========================
local function openApp(name)
    if name == "Notes" then
        openNotes()

    elseif name == "Snake" then
        openSnake()

    elseif name == "Files" then
        fileExplorer("/")

    elseif name == "CMD" then
        cmdPrompt()

    elseif name == "Shutdown" then
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)
        os.shutdown()
    end
end

-- =========================
-- MAIN LOOP
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
