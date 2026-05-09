-- =========================
-- MyOS v1.1 - Mini OS
-- =========================

local w, h = term.getSize()

-- =========================
-- USERS
-- =========================
local USERS_FILE = "users.db"
local CMD_HISTORY_FILE = "cmd_history.txt"

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
-- LOGIN
-- =========================
local function loginScreen()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1,1)

    print("=== MyOS LOGIN ===")
    print("1. Login")
    print("2. Register")

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
-- APPS
-- =========================
local apps = {
    { name = "CMD" },
    { name = "Files" },
    { name = "Browser" },
    { name = "Notes" },
    { name = "Shutdown" }
}

-- =========================
-- DESKTOP
-- =========================
local function drawDesktop(selected)
    term.setBackgroundColor(colors.blue)
    term.clear()

    term.setBackgroundColor(colors.gray)
    for x = 1, w do
        term.setCursorPos(x, h)
        write(" ")
    end

    term.setCursorPos(2, h)
    term.setTextColor(colors.black)
    write("MyOS v1.1 | " .. currentUser)

    for i, app in ipairs(apps) do
        term.setCursorPos(3, i + 2)

        if i == selected then
            term.setTextColor(colors.yellow)
        else
            term.setTextColor(colors.white)
        end

        write(app.name)
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
-- FILE EXPLORER
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
        print("ENTER=open | BACKSPACE=back")

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
-- BROWSER
-- =========================
local websites = {
    home = {
        title = "MyOS Web",
        body = {
            "Welcome to MyOS Internet",
            "",
            "Pages:",
            "home / about / help"
        }
    },

    about = {
        title = "About",
        body = {
            "This is a simulated web system",
            "Running inside ComputerCraft",
            "No real internet required"
        }
    },

    help = {
        title = "Help",
        body = {
            "Type page name to navigate",
            "home, about, help",
            "exit to quit"
        }
    }
}

local function browser()
    local page = "home"

    while true do
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)

        local site = websites[page]

        if not site then
            print("404")
            page = "home"
            sleep(1)
        else
            term.setTextColor(colors.cyan)
            print(site.title)
            print("/" .. page)
            print("------------")

            term.setTextColor(colors.white)
            for _, line in ipairs(site.body) do
                print(line)
            end
        end

        write("\n> ")
        local input = read()

        if input == "exit" then return end
        if websites[input] then page = input end
    end
end

-- =========================
-- CMD (FIXED + HISTORY)
-- =========================
local function cmd()
    local path = "/"
    local history = {}

    if fs.exists(CMD_HISTORY_FILE) then
        local f = fs.open(CMD_HISTORY_FILE, "r")
        history = textutils.unserialize(f.readAll()) or {}
        f.close()
    end

    local function save()
        local f = fs.open(CMD_HISTORY_FILE, "w")
        f.write(textutils.serialize(history))
        f.close()
    end

    while true do
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)

        print("CMD - " .. currentUser)
        print("dir: " .. path)

        for i = math.max(1, #history - 5), #history do
            print(history[i])
        end

        write("\n> ")
        local input = read()

        table.insert(history, input)
        save()

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
-- OPEN APP
-- =========================
local function openApp(name)
    if name == "CMD" then
        cmd()
    elseif name == "Files" then
        fileExplorer("/")
    elseif name == "Browser" then
        browser()
    elseif name == "Notes" then
        notes()
    elseif name == "Shutdown" then
        term.setBackgroundColor(colors.black)
        term.clear()
        os.shutdown()
    end
end

-- =========================
-- MAIN LOOP
-- =========================
loginScreen()

local selected = 1

while true do
    drawDesktop(selected)

    local event, key = os.pullEvent("key")

    if key == keys.down then
        selected = math.min(#apps, selected + 1)
    elseif key == keys.up then
        selected = math.max(1, selected - 1)
    elseif key == keys.enter then
        openApp(apps[selected].name)
    end
end
