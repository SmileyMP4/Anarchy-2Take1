menu.create_thread(function()

function lua_notify(message, title)
    menu.notify(BleuClair .. tostring(message), JauneClair .. tostring(title), 10, _Jaune)
end

function lua_notify_alert(message, title)
    menu.get_feature_by_hierarchy_key("local.settings.notifications.log_to_file").on = true
    menu.notify(RougeClair .. tostring(message), Rouge .. tostring(title), 10, _Rouge)
end

local lua_version <const> = "1.2.0"

local lua_update_date <const> = "01/12/2023"

local notify_default <const> = "Anarchy v" .. lua_version

local Anarchy_Path <const> = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Scripts", "Anarchy")
local Anarchy_File <const> = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Scripts", "Anarchy.lua")
local Lib_File <const> = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Scripts\\Anarchy", "Lib.lua")
local Settings_File <const> = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Scripts\\Anarchy", "Settings.ini")
local Log_File <const> = utils.get_appdata_path("PopstarDevs\\2Take1Menu", "notification.log")

local response_code, response_body <const> = web.get("https://pastebin.com/raw/T6cr1kT8")
if response_code == 200 then
    local pastebin_version <const> = string.match(response_body, "version%s*=%s*([%d%.]+)")
    local pastebin_update_date <const> = string.match(response_body, "update date%s*=%s*([%d/]+)")
    if lua_version ~= "0" then
        lua_notify("Anarchy v" .. pastebin_version .. " is now available.\nDownload in progress ...", "New Version")
        local file <const> = io.open(Anarchy_File, "w")
        io.output(file)
        io.write("")
        io.close(file)
        local response_code, response_body <const> = web.get("https://pastebin.com/raw/iddDmVqd")
        if response_code == 200 then
            for line in response_body:lines() do
                local file <const> = io.open(Anarchy_File, "a")
                io.output(file)
                io.write(line)
                io.close(file)
            end
        end
        local file <const> = io.open(Lib_File, "w")
        io.output(file)
        io.write("")
        io.close(file)
        local response_code, response_body <const> = web.get("https://pastebin.com/raw/HZvxhGTE")
        if response_code == 200 then
            for line in response_body:lines() do
                local file <const> = io.open(Lib_File, "a")
                io.output(file)
                io.write(line)
                io.close(file)
            end
        end

        dofile(Anarchy_File)
        return
    end
else
    if response_code == 0 then
        if not lib.essentials.is_connected_to_internet() then
            lua_notify_alert("You do not have an internet connection.", "Internet Connection")
            menu.exit()
            return
        else
            lua_notify_alert("It's possible that your antivirus software is blocking requests from specific websites. In such a scenario, disable any settings that could be affecting your internet connection. If the issue persists, reported the problem on discord.", "Antivirus Software")
            menu.exit()
            return
        end
    end
    lua_notify_alert("Reported the problem on discord.\nError code: " .. response_code, "Update Check Failed")
    menu.exit()
    return
end

local lib <const> = require("Anarchy\\Lib")

menu.add_feature("Test", "action", 0, function(f)

end)

lua_notify("Version: " .. Jaune .. lua_version .. BleuClair .. "\nUpdated on: " .. Jaune .. lua_update_date .. BleuClair .. "\nDev: " .. Jaune .. "[3arc] Smiley" .. BleuClair .. "\n\nAnarchy is correctly loaded.", notify_default)

end, nil)
