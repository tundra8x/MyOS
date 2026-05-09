-- =========================
-- MyOS v1.0 - Mini OS
-- =========================

local w, h = term.getSize()

-- =========================
-- STORAGE
-- =========================
local USERS_FILE = "users.db"

local function loadUsers()
    if not fs.exists(USERS_FILE) then return {} end
    local f = fs.open(USERS_FILE, "r")
    local data = textutils.unserialize(f.readAll())
    f.close()
    return data or {}
end

local function saveUsers(users)
    local f = fs.open(USERS_FILE, "w")
    f.write(textutils.serialize(users))
    f.close()
end

local users = loadUsers()
local currentUser = nil

-- =========================
-- LOGIN SCREEN
-- =========================
local function loginScreen()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,1)

    print("=== MyOS LOGIN ===")
    print("1. Login")
    print("2. Register")
    print()

    write("> ")
    local choice = read()

    if choice == "2" then
        write("Username: ")
        local u = read()

        write("Password: ")
        local p = read("*")

        users[u] = p
        saveUsers(users)

        print("Registered!")
        sleep(1)
    end

    while true do
        term.clear()
        term.setCursorPos(1,1)

        print("=== LOGIN ===")

        write("Username: ")
        local u = read()

        write("Password: ")
        local p = read("*")

        if users[u] and users[u] == p then
            currentUser = u
            return
        else
            print("Wrong login")
            sleep(1)
        end
    end
end

-- =========================
-- DESKTOP
-- =========================
local apps = {
    { name = "CMD" },
    { name = "Files" },
    { name = "Notes" },
    { name = "Shutdown" }
}

local function drawDesktop(selected)
    term.setBackgroundColor(colors.blue)
    term.clear()

    term.setBackgroundColor(colors.gray)
    for x = 1, w do
        term.setCursorPos(x, h)
        write(" ")
    end

    term.setCursorPos(2, h)
    write("MyOS | " .. currentUser)

    for i, app in ipairs(apps) do
        term.setBackgroundColor(colors.blue)

        if i == selected then
            term.setTextColor(colors.yellow)
        else
            term.setTextColor(colors.white)
        end

        term.setCursorPos(3, i + 2)
        write(app.name)
    end
end

-- =========================
-- FILE EXPLORER (GUI)
-- =========================
local function fileExplorer(path)
    path = path or "/"
    local files = fs.list(path)
    local selected = 1

    while true do
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)

        print("FILES: " .. path)
        print("ENTER=open  BACKSPACE=back")

        for i, f in ipairs(files) do
            if i == selected then
                term.setTextColor(colors.yellow)
                write("> " .. f)
            else
                term.setTextColor(colors.white)
                write("  " .. f)
            end
            print()
        end

        local event, key = os.pullEvent()

        if event == "key" then
            if key == keys.down then
                selected = math.min(#files, selected + 1)

            elseif key == keys.up then
                selected = math.max(1, selected - 1)

            elseif key == keys.enter then
                local name = files[selected]
                local full = fs.combine(path, name)

                if fs.isDir(full) then
                    fileExplorer(full)
                    files = fs.list(path)
                else
                    local f = fs.open(full, "r")
                    term.clear()
                    term.setCursorPos(1,1)
                    print(f.readAll())
                    f.close()
                    print("\nENTER...")
                    read()
                end

            elseif key == keys.backspace then
                return
            end
        end
    end
end

-- =========================
-- CMD (WITH HISTORY)
-- =========================
local function cmd()
    local path = "/"
    local history = {}

    while true do
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)

        print("CMD - " .. currentUser)
        print("dir: " .. path)
        print("history:")

        for i = math.max(1, #history - 5), #history do
            print(history[i])
        end

        write("\n> ")
        local input = read()
        table.insert(history, input)

        local args = {}
        for w in string.gmatch(input, "%S+") do
            table.insert(args, w)
        end

        local c = args[1]

        if c == "ls" then
            for _, f in ipairs(fs.list(path)) do print(f) end
            sleep(1)

        elseif c == "cd" then
            if args[2] == ".." then
                path = fs.getDir(path)
                if path == "" then path = "/" end
            elseif args[2] then
                local p = fs.combine(path, args[2])
                if fs.isDir(p) then path = p end
            end

        elseif c == "mkdir" then
            if args[2] then fs.makeDir(fs.combine(path, args[2])) end

        elseif c == "touch" then
            if args[2] then
                local f = fs.open(fs.combine(path, args[2]), "w")
                f.write("")
                f.close()
            end

        elseif c == "rm" then
            if args[2] then fs.delete(fs.combine(path, args[2])) end

        elseif c == "cat" then
            if args[2] then
                local f = fs.open(fs.combine(path, args[2]), "r")
                if f then
                    print(f.readAll())
                    f.close()
                end
                sleep(2)
            end

        elseif c == "exit" then
            return
        end
    end
end

-- =========================
-- NOTES
-- =========================
local function notes()
    term.clear()
    term.setCursorPos(1,1)
    print("Notes:")
    local t = read()

    local f = fs.open("notes.txt", "w")
    f.write(t)
    f.close()
end

-- =========================
-- MAIN OS LOOP
-- =========================
loginScreen()

local selected = 1

while true do
    drawDesktop(selected)

    local event, key = os.pullEvent()

    if event == "key" then
        if key == keys.down then
            selected = math.min(#apps, selected + 1)
        elseif key == keys.up then
            selected = math.max(1, selected - 1)
        elseif key == keys.enter then
            local app = apps[selected].name

            if app == "CMD" then cmd()
            elseif app == "Files" then fileExplorer("/")
            elseif app == "Notes" then notes()
            elseif app == "Shutdown" then os.shutdown()
            end
        end
    end
end
