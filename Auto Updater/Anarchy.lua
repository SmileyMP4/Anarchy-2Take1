menu.create_thread(function()

local Blanc <const> = "#FFFFFFFF#"
local Noir <const> = "#FF000000#"
local Rouge <const> = "#FF0000FF#"
local RougeClair <const> = "#FFAAAAFF#"
local Vert <const> = "#FF00FF00#"
local Bleu <const> = "#FFFF0000#"
local BleuClair <const> = "#FFFFDDAA#"
local Jaune <const> = "#FF00FFFF#"
local JauneClair <const> = "#FFAAFFFF#"

local _Blanc <const> = 0xFFFFFFFF
local _Noir <const> = 0xFF000000
local _Rouge <const> = 0xFF0000FF
local _RougeClair <const> = 0xFFAAAAFF
local _Vert <const> = 0xFF00FF00
local _Bleu <const> = 0xFFFF0000
local _BleuClair <const> = 0xFFFFDDAA
local _Jaune <const> = 0xFF00FFFF
local _JauneClair <const> = 0xFFAAFFFF

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

local Anarchy_File <const> = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Scripts", "Anarchy.lua")
local Lib_File <const> = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Scripts\\Anarchy", "Lib.lua")

local anarchy_code, anarchy_body <const> = web.get("https://raw.githubusercontent.com/SmileyMP4/Anarchy-2Take1/main/Auto%20Updater/Anarchy.lua")
local lib_code, lib_body <const> = web.get("https://raw.githubusercontent.com/SmileyMP4/Anarchy-2Take1/main/Auto%20Updater/Lib.lua")

if anarchy_code == 200 and lib_code == 200 then
    local github_version <const> = string.match(anarchy_body, 'local%s+lua_version%s+<const>%s*=%s*"([^"]+)"')
    local github_update_date <const> = string.match(anarchy_body, 'local%s+lua_update_date%s+<const>%s*=%s*"([%d/]+)"')
    local github_lib_version <const> = string.match(lib_body, 'lib_version%s*=%s*"([^"]+)"')
    if github_version == github_lib_version and github_version ~= lua_version then
        lua_notify("Anarchy v" .. pastebin_version .. " is now available.\nDownload in progress ...", "New Version")
        local file <const> = io.open(Anarchy_File, "w")
        io.output(file)
        io.write(anarchy_body)
        io.close(file)

        local file <const> = io.open(Lib_File, "w")
        io.output(file)
        io.write(lib_body)
        io.close(file)

        lua_notify("Download finish.", "Finish")

        dofile(Anarchy_File)
        return
    end
else
    if anarchy_code == 0 or lib_code == 0 then
        --[[
        if not lib.essentials.is_connected_to_internet() then
            lua_notify_alert("You do not have an internet connection.", "Internet Connection")
            menu.exit()
            return
        else
            lua_notify_alert("It's possible that your antivirus software is blocking requests from specific websites. In such a scenario, disable any settings that could be affecting your internet connection. If the issue persists, reported the problem on discord.", "Antivirus Software")
            menu.exit()
            return
        end
        ]]
    end
    lua_notify_alert("Reported the problem on discord.\nError code: " .. response_code, "Update Check Failed")
    menu.exit()
    return
end

local lib <const> = require("Anarchy\\Lib")

menu.add_feature("Test" .. lua_version, "action", 0, function(f)

end)

lua_notify("Version: " .. Jaune .. lua_version .. BleuClair .. "\nUpdated on: " .. Jaune .. lua_update_date .. BleuClair .. "\nDev: " .. Jaune .. "[3arc] Smiley" .. BleuClair .. "\n\nAnarchy is correctly loaded.", notify_default)

end, nil)
