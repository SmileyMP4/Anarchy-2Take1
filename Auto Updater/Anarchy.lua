menu.create_thread(function()

local lua_version <const> = "1.2.0"

local lua_update_date <const> = "18/12/2023"

local notify_default <const> = "Anarchy v" .. lua_version

local github_anarchy <const> = "https://raw.githubusercontent.com/SmileyMP4/Anarchy-2Take1/main/Auto%20Updater/Anarchy.lua"

local github_lib <const> = "https://raw.githubusercontent.com/SmileyMP4/Anarchy-2Take1/main/Auto%20Updater/Lib.lua"

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

local Anarchy_Path <const> = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Scripts", "Anarchy")
local Anarchy_File <const> = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Scripts", "Anarchy.lua")
local Lib_File <const> = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Scripts\\Anarchy", "Lib.lua")
local Settings_File <const> = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Scripts\\Anarchy", "Settings.ini")
local Log_File <const> = utils.get_appdata_path("PopstarDevs\\2Take1Menu", "notification.log")

function lua_notify(message, title)
    menu.notify(BleuClair .. tostring(message), JauneClair .. tostring(title), 10, _Jaune)
end

function lua_notify_alert(message, title)
    menu.get_feature_by_hierarchy_key("local.settings.notifications.log_to_file").on = true
    menu.notify(RougeClair .. tostring(message), Rouge .. tostring(title), 10, _Rouge)
end

if anarchy then
    lua_notify_alert("Anarchy is already loaded.", "Already Load")
    menu.exit()
    return
end

function update_lua(anarchy_body, lib_body)
    local file <const> = io.open(Anarchy_File, "w")
    io.output(file)
    io.write(anarchy_body)
    io.close(file)
    local file <const> = io.open(Lib_File, "w")
    io.output(file)
    io.write(lib_body)
    io.close(file)
end

local message = ""
if not menu.is_trusted_mode_enabled(1 << 0) then
    message = message .. "\n - Stats"
end
if not menu.is_trusted_mode_enabled(1 << 1) then
    message = message .. "\n - Globals / Locals"
end
if not menu.is_trusted_mode_enabled(1 << 2) then
    message = message .. "\n - Natives"
end
if not menu.is_trusted_mode_enabled(1 << 3) then
    message = message .. "\n - Http"
end
if not menu.is_trusted_mode_enabled(1 << 4) then
    message = message .. "\n - Memory"
end
if message ~= "" then
    lua_notify_alert("Enabled trusted mode for: " .. Jaune .. message, "Require Trusted Mode")
    menu.exit()
    return
end

local anarchy_code, anarchy_body = web.get(github_anarchy)
local lib_code, lib_body = web.get(github_lib)

lib_body = lib_body:gsub("\n", "")
lib_body = lib_body:gsub("\n\n", "\n")
lib_body = lib_body:gsub("\n$", "")
		
local Update_Available = false
if anarchy_code == 200 and lib_code == 200 then
    local github_anarchy_version <const> = string.match(anarchy_body, 'local%s+lua_version%s+<const>%s*=%s*"([^"]+)"')
    local github_update_date <const> = string.match(anarchy_body, 'local%s+lua_update_date%s+<const>%s*=%s*"([%d/]+)"')
    local github_lib_version <const> = string.match(lib_body, 'lib_version%s*=%s*"([^"]+)"')
    if github_anarchy_version == github_lib_version and github_anarchy_version ~= lua_version then
        lua_notify("Anarchy v" .. github_anarchy_version .. " is now available.\nTo update, click on the Update Lua button.", "Update Available")
        Update_Available = true
    end
else
    if web.get("https://google.com") == 0 then
        lua_notify_alert("You do not have an internet connection.", "Web Request Failed")
        menu.exit()
        return
    end
    if anarchy_code == 0 or lib_code == 0 then
        lua_notify_alert("It's possible that your antivirus software is blocking requests from specific websites.\nIn such a scenario, disable any settings that could be affecting your internet connection.\nIf the issue persists, reported the problem on discord.", "Web Request Failed")
        menu.exit()
        return
    end
    lua_notify_alert("Reported the problem on discord.\nError code: " .. response_code, "Web Request Failed")
    menu.exit()
    return
end

if not utils.dir_exists(Anarchy_Path) then
    utils.make_dir(Anarchy_Path)
end

if not utils.file_exists(Lib_File) then
    lua_notify_alert("Lib file are missing.\nThe lua will be completely re-downloaded to solve this problem.", "File Missing")
    update_lua(anarchy_body, lib_body)
    lua_notify("Installation is complete, lua will restart automatically.", "Installation Finish")
    dofile(Anarchy_File)
    return
end

local lib <const> = require("Anarchy\\Lib")

if lua_version ~= lib_version and not skip_update_file then
    lua_notify_alert("Lib file must be updated.\nThe lua will be completely re-downloaded to solve this problem.", "Require Updated File")
    update_lua(anarchy_body, lib_body)
    lua_notify("Installation is complete, lua will restart automatically.", "Installation Finish")
    skip_update_file = true
    dofile(Anarchy_File)
    return
end

local gta_version <const> = tonumber(lib.natives.GET_ONLINE_VERSION())
if gta_version ~= 1.68 then
    lua_notify_alert("Anarchy is " .. Jaune .. "incompatible " .. RougeClair .. "with the version of gta " .. Jaune .. "v" .. gta_version..RougeClair .. ".\nScript event and global may not work.", "Incompatible GTA Version")
end

anarchy = true

local Threads <const> = {}
local Player_Parents <const> = {}
local Player_Feature <const> = {}
local Local_Parents <const> = {}
local Local_Feature <const> = {}
local Event_Hooks <const> = {}
local Listeners <const> = {}
local Toggle_Feats <const> = {1, 7, 11, 35, 131}
local Value_Feats <const> = {7, 11, 35, 131, 518, 522, 546, 642, 1030, 1034, 1058, 1154}

local int_min <const> = -2147483646
local int_max <const> = 2147483646

local ProtectionFlags <const> = {
    ["Bypassed Message Filter"] = player.add_modder_flag("Bypassed Message Filter"),
    ["Modded Carjacking"] = player.add_modder_flag("Modded Carjacking"),
    ["Lag Player"] = player.add_modder_flag("Lag Player"),
    ["Modded Entity"] = player.add_modder_flag("Modded Entity"),
    ["Taylor Swift Crash"] = player.add_modder_flag("Taylor Swift Crash"),
}

local ModderFlags <const> = {
    ["Modded Name"] = player.add_modder_flag("Modded Name"),
    ["Modded Stats"] = player.add_modder_flag("Modded Stats"),
    ["Modded Script Event"] = player.add_modder_flag("Modded Script Event"),
    ["Modded Network Event"] = player.add_modder_flag("Modded Network Event"),
    ["Network Event Spam"] = player.add_modder_flag("Network Event Spam"),
    ["Modded Vehicle Modification"] = player.add_modder_flag("Modded Vehicle Modification"),
    ["Modded Health"] = player.add_modder_flag("Modded Health"),
    ["Modded Armor"] = player.add_modder_flag("Modded Armor"),
    ["Modded Explosion"] = player.add_modder_flag("Modded Explosion"),
    ["Modded Movement"] = player.add_modder_flag("Modded Movement"),
    ["Player Invincible"] = player.add_modder_flag("Player Invincible"),
    ["Vehicle Invincible"] = player.add_modder_flag("Vehicle Invincible"),
    ["Flags"] = player.add_modder_flag("Flags"),
    ["Modded Off The Radar"] = player.add_modder_flag("Modded Off The Radar"),
    ["Modded Script Execution"] = player.add_modder_flag("Modded Script Execution"),
    ["Admin"] = player.add_modder_flag("Admin"),
    ["Modded Orbital Cannon"] = player.add_modder_flag("Modded Orbital Cannon"),
    ["Modded Weapon"] = player.add_modder_flag("Modded Weapon"),
    ["Modded Spectate"] = player.add_modder_flag("Modded Spectate"),
    --["Unreleased Vehicle"] = player.add_modder_flag("Unreleased Vehicle"),
    ["Silent Aimbot"] = player.add_modder_flag("Silent Aimbot"),
    ["Fast Join"] = player.add_modder_flag("Fast Join"),
}

function can_player_be_modder(pid, flags)
    if player.is_player_valid(pid)
    and pid ~= player.player_id()
    and player.can_player_be_modder(pid)
    and (not Local_Feature["Detection Whitelist Friend"].on or not player.is_player_friend(pid))
    and not player.is_player_modder(pid, player.add_modder_flag(flags))
    and not detection_broken
    then
        return true
    end
    return false
end

function can_player_be_modder_2(pid, flags)
    if player.is_player_valid(pid)
    and pid ~= player.player_id()
    and player.can_player_be_modder(pid)
    and (not Local_Feature["Detection Whitelist Friend"].on or not player.is_player_friend(pid))
    and not player.is_player_modder(pid, flags)
    and not detection_broken
    then
        return true
    end
    return false
end

--10s
menu.create_thread(function()
    while true do
        system.wait(10000)
        anarchy_code, anarchy_body = web.get(github_anarchy)
        lib_code, lib_body = web.get(github_lib)

        if anarchy_code == 200 and lib_code == 200 then
            local github_anarchy_version <const> = string.match(anarchy_body, 'local%s+lua_version%s+<const>%s*=%s*"([^"]+)"')
            local github_update_date <const> = string.match(anarchy_body, 'local%s+lua_update_date%s+<const>%s*=%s*"([%d/]+)"')
            local github_lib_version <const> = string.match(lib_body, 'lib_version%s*=%s*"([^"]+)"')
            if github_anarchy_version == github_lib_version and github_anarchy_version ~= lua_version and not Update_Available then
                lua_notify("Anarchy v" .. github_anarchy_version .. " is now available.\nTo update, click on the Update Lua button.", "Update Available")
                Local_Feature["Update Lua"] = menu.add_integrated_feature_after(Jaune .. "Update Lua", "action", menu.get_feature_by_hierarchy_key("local._ff00ffff_anarchy.settings"), function(f)
                    update_lua(anarchy_body, lib_body)
                    lua_notify("The update is complete, you can now restart the lua.", f.name)
                    menu.exit()
                end)
                Update_Available = true
            end
        else
            if web.get("https://google.com") == 0 then
                lua_notify_alert("You do not have an internet connection.", "Web Request Failed")
                menu.exit()
                return
            end
            if anarchy_code == 0 or lib_code == 0 then
                lua_notify_alert("It's possible that your antivirus software is blocking requests from specific websites.\nIn such a scenario, disable any settings that could be affecting your internet connection.\nIf the issue persists, reported the problem on discord.", "Web Request Failed")
                menu.exit()
                return
            end
            lua_notify_alert("Reported the problem on discord.\nError code: " .. response_code, "Web Request Failed")
            menu.exit()
            return
        end
    end
end)

local detection_broken
--1s
menu.create_thread(function()
    while true do
        if not detection_broken then
            for pid in lib.player.list(false) do
                player.set_player_as_modder(pid, player.add_modder_flag("Ignore This"))
                if not player.is_player_modder(pid, player.add_modder_flag("Ignore This")) and player.can_player_be_modder(pid) then
                    lua_notify_alert("The detection of lua does not work anymore, to solve this problem you have to uninject 2take1 by pressing the F12 key and reinject it. To prevent this from happening again, you should not inject lua that uses detection.", "Plz 2Take1 Fix This")
                    detection_broken = true
                end
                player.unset_player_as_modder(pid, player.add_modder_flag("Ignore This"))
            end
        end
        local NETWORK_IS_SIGNED_IN
        if not lib.essentials.is_connected_to_sc() and not NETWORK_IS_SIGNED_IN then
            lua_notify_alert("You are disconnected from the social club.", "Social Club")
            NETWORK_IS_SIGNED_IN = true
        end
        local is_connected_to_internet
        if not lib.essentials.is_connected_to_internet() and not is_connected_to_internet then
            lua_notify_alert("You do not have an internet connection.", "Internet Connection")
            is_connected_to_internet = true
        end
        if lib.essentials.is_connected_to_sc() and NETWORK_IS_SIGNED_IN then
            lua_notify("You are now connected to the social club.", "Social Club")
            NETWORK_IS_SIGNED_IN = false
        end
        if lib.essentials.is_connected_to_internet() and is_connected_to_internet then
            lua_notify("Your internet connection is back.", "Internet Connection")
            is_connected_to_internet = false
        end
        system.wait(1000)
    end
end)

local Money_Rp_Wait_Multi = {}
local All_RP_Ent_Multi = {}

local Card_Wait_Multi = {}
local All_Card_Ent_Multi = {}

--100ms
menu.create_thread(function()
    while true do
        for i, RP_Ent in ipairs(All_RP_Ent_Multi) do
            Money_Rp_Wait_Multi[RP_Ent] = Money_Rp_Wait_Multi[RP_Ent] + 1
        end
        for i, Card_Ent in ipairs(All_Card_Ent_Multi) do
            Card_Wait_Multi[Card_Ent] = Card_Wait_Multi[Card_Ent] + 1
        end
        system.wait(100)
    end
end)

local LagPlayer = {}
local multi_pid = {}
local Delete_Ped_Paparazzi_Crash

--0ms
menu.create_thread(function()
    while true do
        for i in ipairs(LagPlayer) do
            lib.natives.SET_ENTITY_ROTATION(LagPlayer[i], v3(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
        end

        if multi_pid ~= nil then
            Local_Feature["Multi Selection Separation"].name = "- - - - - - - - - Players (" .. player.player_count() .. ") - - - - - - - - -"
            for pid = 0, 31 do
                if player.is_player_valid(pid) then
                    multi_pid[pid].name = lib.player.get_player_name(pid) .. " (" .. pid .. ")"
                    multi_pid[pid].hidden = false
                else
                    multi_pid[pid].name = pid
                    multi_pid[pid].hidden = true
                end
            end
        end

        if Local_Feature["Block Transaction Error"].on then
            lib.globals.block_transaction_error()
        end

        if Delete_Ped_Paparazzi_Crash then
            for i, ent in pairs(ped.get_all_peds()) do
                if entity.get_entity_model_hash(ent) ~= gameplay.get_hash_key("CS_Stretch") and entity.get_entity_model_hash(ent) ~= gameplay.get_hash_key("MP_F_DeadHooker") then
                    lib.entity.delete_entity(ent)
                end
            end
        end

        for i, RP_Ent in ipairs(All_RP_Ent_Multi) do
            if Money_Rp_Wait_Multi[RP_Ent] > 20 and entity.get_entity_speed(RP_Ent) < 0.1 then
                Money_Rp_Wait_Multi[RP_Ent] = 0
                lib.entity.delete_entity(RP_Ent)
                lib.essentials.table_remove(All_RP_Ent_Multi, RP_Ent)
            end
        end

        for i, Card_Ent in ipairs(All_Card_Ent_Multi) do
            if Card_Wait_Multi[Card_Ent] > 20 and entity.get_entity_speed(Card_Ent) < 0.1 then
                Card_Wait_Multi[Card_Ent] = 0
                lib.entity.delete_entity(Card_Ent)
                lib.essentials.table_remove(All_Card_Ent_Multi, Card_Ent)
            end
        end

        Local_Feature["Griefing or Disruptive Gameplay"]:set_str_data({stats.stat_get_int(gameplay.get_hash_key("MPPLY_GRIEFING"), -1)})
        Local_Feature["Cheating or Modding"]:set_str_data({stats.stat_get_int(gameplay.get_hash_key("MPPLY_EXPLOITS"), -1)})
        Local_Feature["Glitching or Abusing Game Features"]:set_str_data({stats.stat_get_int(gameplay.get_hash_key("MPPLY_GAME_EXPLOITS"), -1)})
        Local_Feature["Text Chat: Annoying Me"]:set_str_data({stats.stat_get_int(gameplay.get_hash_key("MPPLY_TC_ANNOYINGME"), -1)})
        Local_Feature["Text Chat: Using Hate Speech"]:set_str_data({stats.stat_get_int(gameplay.get_hash_key("MPPLY_TC_HATE"), -1)})
        Local_Feature["Voice Chat: Annoying Me"]:set_str_data({stats.stat_get_int(gameplay.get_hash_key("MPPLY_VC_ANNOYINGME"), -1)})
        Local_Feature["Voice Chat: Using Hate Speech"]:set_str_data({stats.stat_get_int(gameplay.get_hash_key("MPPLY_VC_HATE"), -1)})
        Local_Feature["Offensive Language"]:set_str_data({stats.stat_get_int(gameplay.get_hash_key("MPPLY_OFFENSIVE_LANGUAGE"), -1)})
        Local_Feature["Offensive Tagplate"]:set_str_data({stats.stat_get_int(gameplay.get_hash_key("MPPLY_OFFENSIVE_TAGPLATE"), -1)})
        Local_Feature["Offensive Content"]:set_str_data({stats.stat_get_int(gameplay.get_hash_key("MPPLY_OFFENSIVE_UGC"), -1)})
        Local_Feature["Bad Crew Name"]:set_str_data({stats.stat_get_int(gameplay.get_hash_key("MPPLY_BAD_CREW_NAME"), -1)})
        Local_Feature["Bad Crew Motto"]:set_str_data({stats.stat_get_int(gameplay.get_hash_key("MPPLY_BAD_CREW_MOTTO"), -1)})
        Local_Feature["Bad Crew Status"]:set_str_data({stats.stat_get_int(gameplay.get_hash_key("MPPLY_BAD_CREW_STATUS"), -1)})
        Local_Feature["Bad Crew Emblem"]:set_str_data({stats.stat_get_int(gameplay.get_hash_key("MPPLY_BAD_CREW_EMBLEM"), -1)})
        Local_Feature["Friendly"]:set_str_data({stats.stat_get_int(gameplay.get_hash_key("MPPLY_FRIENDLY"), -1)})
        Local_Feature["Helpful"]:set_str_data({stats.stat_get_int(gameplay.get_hash_key("MPPLY_HELPFUL"), -1)})

        local seats_table
        if player.is_player_in_any_vehicle(player.player_id()) then
            seats_table = {}
            local number_of_seats = vehicle.get_vehicle_model_number_of_seats(entity.get_entity_model_hash(player.player_vehicle()))
            if number_of_seats == 1 then
                seats_table = {"no other seat"}
            else
                for seat = 1, number_of_seats do
                    if seat == 1 then
                        seats_table[#seats_table + 1] = "Driver"
                    else
                        seats_table[#seats_table + 1] = seat
                    end
                end
            end
        else
            seats_table = {"not in vehicle"}
        end
        Local_Feature["Set Vehicle Seat"]:set_str_data(seats_table)

        system.wait()
    end
end)

local ScriptEventSpamCount <const> = {}
local NetworkEventSpamCount <const> = {}
local Last_Player_Position <const> = {}
local Invalid_Movement_Ctr <const> = {}
local Invalid_Vehicle_Speed_Ctr <const> = {}
local Player_Invincible_Ctr <const> = {}
local Vehicle_Invincible_Ctr <const> = {}
local IsOTRForExtended <const> = {}
local IsOTRForExtendedCEO <const> = {}
local Silent_Aim <const> = {}
local Player_Typing <const> = {}
local Player_Talking <const> = {}

event.add_event_listener("player_leave", function(player_leave)
    ScriptEventSpamCount[player_leave.player] = 0
    NetworkEventSpamCount[player_leave.player] = 0
    Last_Player_Position[player_leave.player] = nil
    Invalid_Movement_Ctr[player_leave.player] = 0
    Invalid_Vehicle_Speed_Ctr[player_leave.player] = 0
    Player_Invincible_Ctr[player_leave.player] = 0
    Vehicle_Invincible_Ctr[player_leave.player] = 0
    IsOTRForExtended[player_leave.player] = 0
    IsOTRForExtendedCEO[player_leave.player] = 0
    Silent_Aim[player_leave.player] = false
    Player_Typing[player_leave.player] = false
    Player_Talking[player_leave.player] = false
end)

event.add_event_listener("player_join", function(player_join)
end)

Player_Parents["Player Parents"] = menu.add_player_feature("Anarchy", "parent", 0)

--p_airdancer_01_s

local Player_Information <const> = {
    "Name",
    "SCID",
    "IP",
    "Ping",
    "VPN",
    "Country",
    "Region",
    "City",
    "ISP",
    "Host Token",
    "Game Language",
    "Rank",
    "Kills",
    "Deaths",
    "K/D",
    "Wallet Money",
    "Bank Money",
    "Position",
    "Passive / Ghosted",
    "Muted",
    "Voice Chat",
    "Typing",
    "Bounty",
    "Off The Radar",
    "Interior",
    "Organization",
    "Wanted Level",
    "Weapon Range",
    "Weapon Lockon Range",
}

local info_pid = -1
Player_Parents["Information"] = menu.add_player_feature("Information", "parent", Player_Parents["Player Parents"].id, function(f, pid)
    if pid == player.player_id() then
        lua_notify_alert("Some information may be missing if you do it yourself.", f.name)
    end
    if info_pid ~= pid then
        info_pid = pid
        for _, name in pairs(Player_Information) do
            Player_Feature["Player " .. name]:set_str_data({"wait"})
        end
        local ip <const> = lib.player.get_player_ip(pid, 1)
        if ip == "relay" then
            Player_Feature["Player IP"]:set_str_data({ip})
            Player_Feature["Player VPN"]:set_str_data({"nil"})
            Player_Feature["Player Country"]:set_str_data({"nil"})
            Player_Feature["Player Region"]:set_str_data({"nil"})
            Player_Feature["Player City"]:set_str_data({"nil"})
            Player_Feature["Player ISP"]:set_str_data({"nil"})
        else
            local response_code, get_ip <const> = web.get("http://ip-api.com/json/" .. ip .. "?fields=status,country,regionName,city,isp,query,proxy")
            Player_Feature["Player IP"]:set_str_data({ip})
            if ip:match("proxy\":(.-),") == "true" then
                Player_Feature["Player VPN"]:set_str_data({"Yes"})
            else
                Player_Feature["Player VPN"]:set_str_data({"No"})
            end
            Player_Feature["Player Country"]:set_str_data({get_ip:match("country\":\"(.-)\"")})
            Player_Feature["Player Region"]:set_str_data({get_ip:match("regionName\":\"(.-)\"")})
            Player_Feature["Player City"]:set_str_data({get_ip:match("city\":\"(.-)\"")})
            Player_Feature["Player ISP"]:set_str_data({get_ip:match("isp\":\"(.-)\"")})
        end
        if Threads["Information"] ~= nil then
            menu.delete_thread(Threads["Information"])
        end
        Threads["Information"] = menu.create_thread(function()
            while true do
                if pid == player.player_id() then
                    Player_Feature["Player Kills"]:set_str_data({"nil"})
                    Player_Feature["Player Deaths"]:set_str_data({"nil"})
                    Player_Feature["Player K/D"]:set_str_data({"nil"})
                    Player_Feature["Player Ping"]:set_str_data({"nil"})
                else
                    Player_Feature["Player Kills"]:set_str_data({lib.globals.get_player_kills(pid)})
                    Player_Feature["Player Deaths"]:set_str_data({lib.globals.get_player_deaths(pid)})
                    Player_Feature["Player K/D"]:set_str_data({lib.globals.get_player_kd(pid)})
                    Player_Feature["Player Ping"]:set_str_data({string.format("%.0f", lib.natives.NETWORK_GET_AVERAGE_PING(pid))})
                end
                Player_Feature["Player Name"]:set_str_data({lib.player.get_player_name(pid)})
                Player_Feature["Player SCID"]:set_str_data({player.get_player_scid(pid)})
                Player_Feature["Player Host Token"]:set_str_data({string.upper(string.format("%x", player.get_player_host_token(pid)))})
                Player_Feature["Player Game Language"]:set_str_data({lib.globals.get_player_game_language(pid)})
                Player_Feature["Player Rank"]:set_str_data({lib.globals.get_player_rank(pid)})
                Player_Feature["Player Wallet Money"]:set_str_data({lib.essentials.add_commas_to_number(lib.globals.get_player_wallet(pid))})
                Player_Feature["Player Bank Money"]:set_str_data({lib.essentials.add_commas_to_number(lib.globals.get_player_bank(pid))})
                Player_Feature["Player Position"]:set_str_data({string.format("%.1f", player.get_player_coords(pid).x) .. ", " .. string.format("%.1f", player.get_player_coords(pid).y) .. ", " .. string.format("%.1f", player.get_player_coords(pid).z)})
                if lib.globals.is_player_passive(pid) or lib.natives.IS_ENTITY_A_GHOST(player.get_player_ped(pid)) then
                    Player_Feature["Player Passive / Ghosted"]:set_str_data({"Yes"})
                else
                    Player_Feature["Player Passive / Ghosted"]:set_str_data({"No"})
                end
                if lib.natives.NETWORK_AM_I_MUTED_BY_PLAYER(pid) or lib.natives.NETWORK_IS_PLAYER_MUTED_BY_ME(pid) then
                    Player_Feature["Player Muted"]:set_str_data({"Yes"})
                else
                    Player_Feature["Player Muted"]:set_str_data({"No"})
                end
                if lib.natives.NETWORK_GAMER_HAS_HEADSET(lib.essentials.buffer_13(pid)) then
                    Player_Feature["Player Voice Chat"]:set_str_data({"Yes"})
                else
                    Player_Feature["Player Voice Chat"]:set_str_data({"No"})
                end
                if lib.globals.is_player_typing(pid) then
                    Player_Feature["Player Typing"]:set_str_data({"Yes"})
                else
                    Player_Feature["Player Typing"]:set_str_data({"No"})
                end
                if lib.globals.is_player_bounty(pid) then
                    Player_Feature["Player Bounty"]:set_str_data({"Yes"})
                else
                    Player_Feature["Player Bounty"]:set_str_data({"No"})
                end
                if lib.globals.is_player_otr(pid) then
                    Player_Feature["Player Off The Radar"]:set_str_data({"Yes"})
                else
                    Player_Feature["Player Off The Radar"]:set_str_data({"No"})
                end
                if lib.globals.get_interior_player_is_in(pid) ~= 0 then
                    Player_Feature["Player Interior"]:set_str_data({"Yes"})
                else
                    Player_Feature["Player Interior"]:set_str_data({"No"})
                end
                if lib.globals.is_player_organization(pid) then
                    Player_Feature["Player Organization"]:set_str_data({"Yes"})
                else
                    Player_Feature["Player Organization"]:set_str_data({"No"})
                end
                if lib.globals.is_player_organization(pid) then
                    Player_Feature["Player Organization"]:set_str_data({"Yes"})
                else
                    Player_Feature["Player Organization"]:set_str_data({"No"})
                end
                Player_Feature["Player Weapon Range"]:set_str_data({player.get_player_wanted_level(pid)})
                Player_Feature["Player Weapon Range"]:set_str_data({lib.natives.GET_LOCKON_DISTANCE_OF_CURRENT_PED_WEAPON(player.get_player_ped(pid))})
                Player_Feature["Player Weapon Lockon Range"]:set_str_data({lib.natives.GET_MAX_RANGE_OF_CURRENT_PED_WEAPON(player.get_player_ped(pid))})
                system.wait()
            end
        end)
    end
end)

for _, name in pairs(Player_Information) do
    Player_Feature["Player " .. name] = menu.add_player_feature(name, "action_value_str", Player_Parents["Information"].id, function(f, pid)
        utils.to_clipboard(f.str_data[1])
        lua_notify("Copy to clipboard succeeded.", f.name)
    end)
    Player_Feature["Player " .. name]:set_str_data({""})
end

Player_Parents["Teleport"] = menu.add_player_feature("Teleport", "parent", Player_Parents["Player Parents"].id)

Player_Feature["Teleport Player To"] = menu.add_player_feature("Teleport Player To", "action_value_str", Player_Parents["Teleport"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    lib.player.check_player_vehicle_and_spec_if_necessary(pid, function()
        local plyrvehicle <const> = player.get_player_vehicle(pid)
        if f.value == 0 then
            if ped.is_ped_in_any_vehicle(player.get_player_ped(pid)) then
                if lib.essentials.request_control(plyrvehicle, 2500) then
                    entity.set_entity_coords_no_offset(plyrvehicle, lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.player_ped(), 0.0, lib.entity.get_hash_offset_dimension(entity.get_entity_model_hash(plyrvehicle)), 0.0))
                    lib.natives.SET_ENTITY_ROTATION(plyrvehicle, v3(0, 0, player.get_player_heading(player.player_id())))
                    system.wait()
                    vehicle.set_vehicle_on_ground_properly(plyrvehicle)
                    system.wait(1000)
                    if lib.essentials.request_control(player.get_player_vehicle(pid), 10000) then
                        entity.delete_entity(player.get_player_vehicle(pid))
                        lib.essentials.table_remove(anarchy_spawned_entity, Entity)
                    end
                end
            else
                local pos <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.player_ped(), 0.0, 5.0, 0.0)
                player.teleport_player_on_foot(pid, pos)
            end
        elseif f.value == 1 then
            if lib.natives.IS_WAYPOINT_ACTIVE() then
                local waypoint <const> = ui.get_waypoint_coord()
                if ped.is_ped_in_any_vehicle(player.get_player_ped(pid)) then
                    if lib.essentials.request_control(plyrvehicle, 2500) then
                        entity.set_entity_coords_no_offset(plyrvehicle, v3(waypoint.x, waypoint.y, lib.essentials.get_ground_z(waypoint)))
                        lib.natives.SET_ENTITY_ROTATION(plyrvehicle, v3(0, 0, entity.get_entity_heading(plyrvehicle)))
                        system.wait()
                        vehicle.set_vehicle_on_ground_properly(plyrvehicle)
                        system.wait(1000)
                        if lib.essentials.request_control(player.get_player_vehicle(pid), 10000) then
                            entity.delete_entity(player.get_player_vehicle(pid))
                            lib.essentials.table_remove(anarchy_spawned_entity, Entity)
                        end
                    end
                else
                    player.teleport_player_on_foot(pid, v3(waypoint.x, waypoint.y, lib.essentials.get_ground_z(waypoint) - 0.3), entity.get_entity_heading(plyrvehicle))
                end
            else
                lua_notify_alert("There is no waypoint.", f.name)
            end
        elseif f.value == 2 then
            local pos, ground_z
            repeat
                pos = v2(math.random(-4000, 4500), math.random(-4000, 8000))
                ground_z, status = lib.essentials.get_ground_z(pos)
            until status and ground_z ~= 0
            if ped.is_ped_in_any_vehicle(player.get_player_ped(pid)) then
                if lib.essentials.request_control(plyrvehicle, 2500) then
                    entity.set_entity_coords_no_offset(plyrvehicle, v3(pos.x, pos.y, ground_z))
                    lib.natives.SET_ENTITY_ROTATION(plyrvehicle, v3(0, 0, entity.get_entity_heading(plyrvehicle)))
                    system.wait()
                    vehicle.set_vehicle_on_ground_properly(plyrvehicle)
                    system.wait(1000)
                    if lib.essentials.request_control(player.get_player_vehicle(pid), 10000) then
                        entity.delete_entity(player.get_player_vehicle(pid))
                        lib.essentials.table_remove(anarchy_spawned_entity, Entity)
                    end
                end
            else
                player.teleport_player_on_foot(pid, v3(pos.x, pos.y, ground_z - 0.3), entity.get_entity_heading(plyrvehicle))
            end
        end
    end)
end)
Player_Feature["Teleport Player To"]:set_str_data({"Me", "Waypoint", "Random Pos"})

Player_Feature["Teleport Vehicle To"] = menu.add_player_feature("Teleport Vehicle To", "action_value_str", Player_Parents["Teleport"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    lib.player.check_player_vehicle_and_spec_if_necessary(pid, function()
        local plyrvehicle <const> = player.get_player_vehicle(pid)
        if not lib.natives.DOES_ENTITY_EXIST(plyrvehicle) then
            lua_notify_alert(lib.player.get_player_name(pid) .. " has no assigned vehicle.", f.name)
            return
        end
        if f.value == 0 then
            if lib.essentials.request_control(plyrvehicle, 2500) then
                entity.set_entity_coords_no_offset(plyrvehicle, lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.player_ped(), 0.0, lib.entity.get_hash_offset_dimension(entity.get_entity_model_hash(plyrvehicle)), 0.0))
                lib.natives.SET_ENTITY_ROTATION(plyrvehicle, v3(0, 0, player.get_player_heading(player.player_id())))
                system.wait()
                vehicle.set_vehicle_on_ground_properly(plyrvehicle)
            end
        elseif f.value == 1 then
            if lib.natives.IS_WAYPOINT_ACTIVE() then
                local waypoint <const> = ui.get_waypoint_coord()
                if lib.essentials.request_control(plyrvehicle, 2500) then
                    entity.set_entity_coords_no_offset(plyrvehicle, v3(waypoint.x, waypoint.y, lib.essentials.get_ground_z(waypoint)))
                    lib.natives.SET_ENTITY_ROTATION(plyrvehicle, v3(0, 0, entity.get_entity_heading(plyrvehicle)))
                    system.wait()
                    vehicle.set_vehicle_on_ground_properly(plyrvehicle)
                end
            else
                lua_notify_alert("There is no waypoint.", f.name)
            end
        elseif f.value == 2 then
            local pos, ground_z
            repeat
                pos = v2(math.random(-4000, 4500), math.random(-4000, 8000))
                ground_z, status = lib.essentials.get_ground_z(pos)
            until status and ground_z ~= 0
            if lib.essentials.request_control(plyrvehicle, 2500) then
                entity.set_entity_coords_no_offset(plyrvehicle, v3(pos.x, pos.y, ground_z))
                lib.natives.SET_ENTITY_ROTATION(plyrvehicle, v3(0, 0, entity.get_entity_heading(plyrvehicle)))
                system.wait()
                vehicle.set_vehicle_on_ground_properly(plyrvehicle)
            end
        end
    end)
end)
Player_Feature["Teleport Vehicle To"]:set_str_data({"Me", "Waypoint", "Random Pos"})

Player_Feature["Teleport To Random Apartment"] = menu.add_player_feature("Teleport To Random Apartment", "action", Player_Parents["Teleport"].id, function(f, pid)
    lib.scriptevent.teleport_to_random_apartment(pid)
end)

Player_Feature["Teleport To Random Interior"] = menu.add_player_feature("Teleport To Random Interior", "action", Player_Parents["Teleport"].id, function(f, pid)
    lib.scriptevent.teleport_to_random_interior(pid)
end)

Player_Feature["Teleport To Random Warehouse"] = menu.add_player_feature("Teleport To Random Warehouse", "action", Player_Parents["Teleport"].id, function(f, pid)
    lib.scriptevent.teleport_to_random_warehouse(pid)
end)

Player_Parents["Funny"] = menu.add_player_feature("Funny", "parent", Player_Parents["Player Parents"].id)

Player_Feature["Off The Radar"] = menu.add_player_feature("Off The Radar", "toggle", Player_Parents["Funny"].id, function(f, pid)
    while f.on do
        if not lib.globals.is_player_otr(pid) then
            lib.scriptevent.give_otr(pid)
        end
        system.wait()
    end
    if not f.on then
        lib.scriptevent.remove_otr(pid)
    end
end)

Player_Feature["Set bounty"] = menu.add_player_feature("Set bounty", "value_str", Player_Parents["Funny"].id, function(f, pid)
    local input_stat, input_val = input.get("Value from " .. f.min .. " to " .. f.max, 10000, 5, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        f.on = false
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > 10000 then
        input_val = 10000
    elseif input_val < 1 then
        input_val = 1
    else
        input_val = input_val
    end
    while f.on do
        if not lib.globals.is_player_bounty(pid) then
            lib.scriptevent.set_bounty(pid, input_val, f.value == 0)
        end
        system.wait(100)
    end
end)
Player_Feature["Set bounty"]:set_str_data({"Anonymous", "Named"})

Player_Feature["Never Wanted"] = menu.add_player_feature("Never Wanted", "value_str", Player_Parents["Funny"].id, function(f, pid)
    while f.on do
        if player.get_player_wanted_level(pid) ~= 0 then
            if f.value == 0 then
                lib.scriptevent.clear_wanted(pid)
            elseif f.value == 1 then
                menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".services.remove_wanted_level").on = true
            elseif f.value == 2 then
                lib.scriptevent.bribe_authorities(pid)
            end
        end
        system.wait()
    end
end)
Player_Feature["Never Wanted"]:set_str_data({"v1", "v2", "v3"})

Player_Feature["Trigger CRC Check"] = menu.add_player_feature("Trigger CRC Check", "action", Player_Parents["Funny"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    lib.natives.REMOTE_CHEATER_PLAYER_DETECTED(pid, 0, 0)
end)

Player_Feature["Attach To Player Head"] = menu.add_player_feature("Attach To Player Head", "toggle", Player_Parents["Funny"].id, function(f, pid)
    if f.on then
        if lib.player.its_me(pid, f.name, f) then return end
        entity.set_entity_collision(player.player_ped(), false, true)
        entity.freeze_entity(player.player_ped(), true)
    end
    while f.on do
        local pos1 <const> = player.get_player_coords(pid)
        pos1.z = pos1.z + 2
        entity.set_entity_coords_no_offset(player.player_ped(), v3(pos1.x, pos1.y, pos1.z))
        lib.natives.SET_ENTITY_ROTATION(player.player_ped(), v3(0, 0, player.get_player_heading(pid)))
        system.wait()
    end
    if not f.on then
        entity.freeze_entity(player.player_ped(), false)
        entity.set_entity_collision(player.player_ped(), true, true)
    end
end)

Player_Parents["Trolling"] = menu.add_player_feature("Trolling", "parent", Player_Parents["Player Parents"].id)

Player_Feature["Force Into Freemode Mission"] = menu.add_player_feature("Force Into Freemode Mission", "action", Player_Parents["Trolling"].id, function(f, pid)
    lib.scriptevent.force_into_freemode_mission(pid)
end)

Player_Feature["Send To Random Job"] = menu.add_player_feature("Send To Random Job", "action", Player_Parents["Trolling"].id, function(f, pid)
    lib.scriptevent.send_to_random_job(pid)
end)

Player_Feature["Block Passive Mode"] = menu.add_player_feature("Block Passive Mode", "toggle", Player_Parents["Trolling"].id, function(f, pid)
    if f.on then
        lib.scriptevent.block_passive(pid)
    end
    if not f.on then
        lib.scriptevent.unblock_passive(pid)
    end
end)

Player_Feature["Block Notif Above Minimap"] = menu.add_player_feature("Block Notif Above Minimap", "toggle", Player_Parents["Trolling"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    while f.on do
        lib.scriptevent.job_message(pid, "<font size='9999'>A")
        system.wait(10000)
    end
end)
Player_Feature["Block Notif Above Minimap"].hint = "fefeee"

Player_Feature["Trigger Business Raid"] = menu.add_player_feature("Trigger Business Raid", "action", Player_Parents["Trolling"].id, function(f, pid)
    lib.scriptevent.trigger_business_raid(pid)
end)

Player_Feature["Infinite Loading Screen"] = menu.add_player_feature("Infinite Loading Screen", "action", Player_Parents["Trolling"].id, function(f, pid)
    lib.scriptevent.infinite_loading_screen(pid, f.value)
end)

Player_Feature["Kick From"] = menu.add_player_feature("Kick From", "action_value_str", Player_Parents["Trolling"].id, function(f, pid)
    if f.value == 0 then
        if lib.player.is_player_in_interior(pid) then
            lib.scriptevent.kick_from_interior(pid)
        else
            lua_notify_alert(lib.player.get_player_name(pid) .. " isn't in an interior.", f.name)
        end
    else
        lib.scriptevent.kick_from_organization(pid)
    end
end)
Player_Feature["Kick From"]:set_str_data({"Interior", "Organization"})

Player_Feature["Spam Horn Car"] = menu.add_player_feature("Spam Horn Car", "toggle", Player_Parents["Trolling"].id, function(f, pid)
    local Horn_Car <const> = {}
    if f.on then
        for i = 1, 30 do
            local pos1 <const> = player.get_player_coords(pid)
            Horn_Car[i] = lib.entity.spawn_entity(gameplay.get_hash_key("t20"), v3(pos1.x + 110, pos1.y, 2600), math.random(0, 360), false, true, false, true, false, true)
            vehicle.set_vehicle_mod(Horn_Car[i], 14, 16)
            for i in ipairs(Horn_Car) do
                entity.set_entity_coords_no_offset(Horn_Car[i], v3(pos1.x + 110, pos1.y, 2600))
            end
            system.wait(100)
        end
    end
    while f.on do
        for i in ipairs(Horn_Car) do
            local pos1 <const> = player.get_player_coords(pid)
            entity.set_entity_coords_no_offset(Horn_Car[i], v3(pos1.x, pos1.y, pos1.z + 1.5))
            lib.natives.SET_VEHICLE_ALARM(Horn_Car[i], true)
            lib.natives.START_VEHICLE_ALARM(Horn_Car[i])
            if network.get_entity_net_owner(Horn_Car[i]) ~= player.player_id() then
                for i in ipairs(Horn_Car) do
                    lib.entity.delete_entity(Horn_Car[i])
                end
                lua_notify_alert("An error has occurred, change session if the problem persists.", f.name)
                f.on = false
            end
        end
        system.wait()
    end
    if not f.on then
        for i in ipairs(Horn_Car) do
            lib.entity.delete_entity(Horn_Car[i])
        end
    end
end)

--gr_prop_gr_hobo_stove_01
--ch_chint02_hobo_stove
--prop_hobo_stove_01

Player_Feature["Glitch Sound"] = menu.add_player_feature("Glitch Sound", "toggle", Player_Parents["Trolling"].id, function(f, pid)
    local Glitch_Sound <const> = {}
    if f.on then
        for i = 1, 30 do
            local pos1 <const> = player.get_player_coords(pid)
            Glitch_Sound[i] = lib.entity.spawn_entity(gameplay.get_hash_key("gr_prop_gr_hobo_stove_01"), v3(pos1.x + 75, pos1.y, pos1.z + 75), 0, false, true, false, true, false, true)
            lib.natives.SET_ENTITY_ROTATION(Glitch_Sound[i], v3(0, 180, 0))
            for i in ipairs(Glitch_Sound) do
                entity.set_entity_coords_no_offset(Glitch_Sound[i], v3(pos1.x + 75, pos1.y, pos1.z + 75))
            end
            system.wait(100)
        end
    end
    while f.on do
        local pos1 <const> = player.get_player_coords(pid)
        for i in ipairs(Glitch_Sound) do
            entity.set_entity_coords_no_offset(Glitch_Sound[i], v3(pos1.x, pos1.y, pos1.z - 2))
            if network.get_entity_net_owner(Glitch_Sound[i]) ~= player.player_id() then
                for i in ipairs(Glitch_Sound) do
                    lib.entity.delete_entity(Glitch_Sound[i])
                end
                lua_notify_alert("An error has occurred, change session if the problem persists.", f.name)
                f.on = false
            end
        end
        system.wait()
    end
    if not f.on then
        for i in ipairs(Glitch_Sound) do
            lib.entity.delete_entity(Glitch_Sound[i])
        end
    end
end)

Player_Parents["PTFX"] = menu.add_player_feature("PTFX", "parent", Player_Parents["Trolling"].id)

Player_Feature["PTFX Bypass"] = menu.add_player_feature("PTFX Bypass", "action", Player_Parents["PTFX"].id, function(f, pid)
    local DictionaryName <const> = "scr_exile1"
    local EffectNames <const> = "scr_ex1_plane_exp"
    graphics.set_next_ptfx_asset(DictionaryName)
    lib.essentials.request_ptfx(DictionaryName)
    local pos <const> = player.get_player_coords(pid)
    graphics.start_networked_ptfx_looped_at_coord(EffectNames, v3(pos.x + (math.random(-5, 5)), pos.y + (math.random(-5, 5)), pos.z + (math.random(-5, 5))), v3(0, 0, 0), 1, false, false, false)
end)

--xm_prop_x17_barge_01
--xs_prop_arena_oil_jack_01a
--gr_prop_damship_01a

Player_Feature["Spam PTFX"] = menu.add_player_feature("Spam PTFX", "toggle", Player_Parents["PTFX"].id, function(f, pid)
    local Spam_PTFX <const> = {}
    if f.on then
        for i = 1, 30 do
            local pos1 <const> = player.get_player_coords(pid)
            Spam_PTFX[i] = lib.entity.spawn_entity(gameplay.get_hash_key("xs_prop_arena_oil_jack_01a"), v3(pos1.x + 75, pos1.y, pos1.z + 75), math.random(0, 360), false, true, true, true, false, true)
            lib.natives.SET_ENTITY_ROTATION(Spam_PTFX[i], v3(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
            entity.set_entity_lod_dist(Spam_PTFX[i], 0)
            for i in ipairs(Spam_PTFX) do
                entity.set_entity_coords_no_offset(Spam_PTFX[i], v3(pos1.x + 75, pos1.y, pos1.z + 75))
            end
            system.wait(100)
        end
    end
    while f.on do
        local pos1 <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 0.0, 0.0, -2.0)
        for i in ipairs(Spam_PTFX) do
            entity.set_entity_coords_no_offset(Spam_PTFX[i], v3(pos1.x, pos1.y, pos1.z))
            lib.natives.SET_ENTITY_ROTATION(Spam_PTFX[i], v3(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
            if network.get_entity_net_owner(Spam_PTFX[i]) ~= player.player_id() then
                for i in ipairs(Spam_PTFX) do
                    lib.entity.delete_entity(Spam_PTFX[i])
                end
                lua_notify_alert("An error has occurred, change session if the problem persists.", f.name)
                f.on = false
            end
        end
        system.wait()
    end
    if not f.on then
        for i in ipairs(Spam_PTFX) do
            lib.entity.delete_entity(Spam_PTFX[i])
        end
    end
end)

Player_Feature["Disco Light"] = menu.add_player_feature("Disco Light", "toggle", Player_Parents["Trolling"].id, function(f, pid)
    local Disco_Light <const> = {}
    if f.on then
        for i = 1, 30 do
            local pos1 <const> = player.get_player_coords(pid)
            Disco_Light[i] = lib.entity.spawn_entity(gameplay.get_hash_key("prop_spot_01"), v3(pos1.x + 75, pos1.y, pos1.z + 75), 0, false, true, true, true, false, true)
            lib.natives.SET_ENTITY_ROTATION(Disco_Light[i], v3(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
            for i in ipairs(Disco_Light) do
                entity.set_entity_coords_no_offset(Disco_Light[i], v3(pos1.x + 75, pos1.y, pos1.z + 75))
            end
            system.wait(100)
        end
    end
    while f.on do
        local pos1 <const> = player.get_player_coords(pid)
        for i in ipairs(Disco_Light) do
            entity.set_entity_coords_no_offset(Disco_Light[i], v3(pos1.x, pos1.y, pos1.z + 1.5))
            lib.natives.SET_ENTITY_ROTATION(Disco_Light[i], v3(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
            if network.get_entity_net_owner(Disco_Light[i]) ~= player.player_id() then
                for i in ipairs(Disco_Light) do
                    lib.entity.delete_entity(Disco_Light[i])
                end
                lua_notify_alert("An error has occurred, change session if the problem persists.", f.name)
                f.on = false
            end
        end
        system.wait()
    end
    if not f.on then
        for i in ipairs(Disco_Light) do
            lib.entity.delete_entity(Disco_Light[i])
        end
    end
end)

Player_Feature["Climb Player"] = menu.add_player_feature("Climb Player", "toggle", Player_Parents["Trolling"].id, function(f, pid)
    local Climb_ent_1, Climb_ent_2
    if f.on then
        local pos1 <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 2.7, -2.7, -1.0)
        local pos2 <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 0.0, 0.0, -1.2)
        Climb_ent_1 = lib.entity.spawn_entity(gameplay.get_hash_key("prop_dock_crane_02_ld"), v3(pos1.x, pos1.y, pos1.z), player.get_player_heading(pid) + 180, false, true, false, true, true, true)
        Climb_ent_2 = lib.entity.spawn_entity(gameplay.get_hash_key("stt_prop_stunt_bblock_sml2"), v3(pos2.x, pos2.y, pos2.z), player.get_player_heading(pid), false, true, false, true, true, true)
    end
    while f.on do
        local pos1 <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 2.7, -2.7, -1.0)
        local pos2 <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 0.0, 0.0, -1.2)
        entity.set_entity_coords_no_offset(Climb_ent_1, v3(pos1.x, pos1.y, pos1.z))
        entity.set_entity_coords_no_offset(Climb_ent_2, v3(pos2.x, pos2.y, pos2.z))
        lib.natives.SET_ENTITY_ROTATION(Climb_ent_1, v3(0, 0, player.get_player_heading(pid) + 180))
        lib.natives.SET_ENTITY_ROTATION(Climb_ent_2, v3(0, 0, player.get_player_heading(pid)))
        if network.get_entity_net_owner(Climb_ent_1) ~= player.player_id() or network.get_entity_net_owner(Climb_ent_2) ~= player.player_id() then
            lib.entity.delete_entity(Climb_ent_1)
            lib.entity.delete_entity(Climb_ent_2)
            lua_notify_alert("An error has occurred, change session if the problem persists.", f.name)
            f.on = false
        end
        system.wait()
    end
    if not f.on then
        lib.entity.delete_entity(Climb_ent_1)
        lib.entity.delete_entity(Climb_ent_2)
    end
end)

Player_Feature["Crush Player"] = menu.add_player_feature("Crush Player", "toggle", Player_Parents["Trolling"].id, function(f, pid)
    local crush_ent
    if f.on then
        local pos1 <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 0.0, 3.0, 0.0)
        crush_ent = lib.entity.spawn_entity(gameplay.get_hash_key("BUS"), v3(pos1.x, pos1.y, player.get_player_coords(pid).z + 100), player.get_player_heading(pid), false, true, true, false, true, true)
        entity.set_entity_gravity(crush_ent, false)
        system.wait()
        entity.set_entity_visible(crush_ent, false)
        entity.set_entity_lod_dist(crush_ent, 0)
    end
    while f.on do
        local pos1 <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 0.0, 3.0, 0.0)
        entity.set_entity_coords_no_offset(crush_ent, v3(pos1.x, pos1.y, player.get_player_coords(pid).z + 5))
        lib.natives.SET_ENTITY_ROTATION(crush_ent, v3(0, 0, player.get_player_heading(pid)))
        system.wait(250)
        entity.apply_force_to_entity(crush_ent, 1, 0, 0, -25, 0, 0, 0, false, true)
        system.wait(500)
        if network.get_entity_net_owner(crush_ent) ~= player.player_id() then
            lua_notify_alert("An error has occurred, change session if the problem persists.", f.name)
            f.on = false
        end
    end
    if not f.on then
        lib.entity.delete_entity(crush_ent)
    end
end)

Player_Feature["Bump Player"] = menu.add_player_feature("Bump Player", "toggle", Player_Parents["Trolling"].id, function(f, pid)
    local bump_ent
    if f.on then
        local pos1 <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 0.0, 3.0, 0.0)
        bump_ent = lib.entity.spawn_entity(gameplay.get_hash_key("BUS"), v3(pos1.x, pos1.y, player.get_player_coords(pid).z + 100), player.get_player_heading(pid), false, true, true, false, true, true)
        entity.set_entity_gravity(bump_ent, false)
        system.wait()
        entity.set_entity_visible(bump_ent, false)
        entity.set_entity_lod_dist(bump_ent, 0)
    end
    while f.on do
        local pos1 <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 0.0, 3.0, 0.0)
        entity.set_entity_coords_no_offset(bump_ent, v3(pos1.x, pos1.y, player.get_player_coords(pid).z - 10))
        lib.natives.SET_ENTITY_ROTATION(bump_ent, v3(0, 0, player.get_player_heading(pid)))
        system.wait(250)
        entity.apply_force_to_entity(bump_ent, 1, 0, 0, 25, 0, 0, 0, false, true)
        system.wait(1000)
        if network.get_entity_net_owner(bump_ent) ~= player.player_id() then
            lua_notify_alert("An error has occurred, change session if the problem persists.", f.name)
            f.on = false
        end
    end
    if not f.on then
        lib.entity.delete_entity(bump_ent)
    end
end)

Player_Feature["Ram Player"] = menu.add_player_feature("Ram Player", "toggle", Player_Parents["Trolling"].id, function(f, pid)
    local bump_ent
    if f.on then
        local pos1 <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 0.0, 0.0, 5.0)
        ram_ent = lib.entity.spawn_entity(gameplay.get_hash_key("BUS"), v3(pos1.x, pos1.y, player.get_player_coords(pid).z + 100), player.get_player_heading(pid), false, true, true, false, true, true)
        entity.set_entity_gravity(ram_ent, false)
        system.wait()
        entity.set_entity_visible(ram_ent, false)
        entity.set_entity_lod_dist(ram_ent, 0)
    end
    while f.on do
        local pos1 <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 0.0, 0.0, 5.0)
        entity.set_entity_coords_no_offset(ram_ent, v3(pos1.x, pos1.y, player.get_player_coords(pid).z - 10))
        lib.natives.SET_ENTITY_ROTATION(ram_ent, v3(0, 0, math.random(0, 360)))
        local heading <const> = entity.get_entity_heading(ram_ent)
        local pos2 <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ram_ent, 0.0, 15.0, 0.0)
        entity.set_entity_coords_no_offset(ram_ent, v3(pos2.x, pos2.y, player.get_player_coords(pid).z - 0))
        lib.natives.SET_ENTITY_ROTATION(ram_ent, v3(0, 0, heading - 180))
        system.wait(250)
        entity.apply_force_to_entity(ram_ent, 1, 0, 100, 0, 0, 0, 0, true, true)
        system.wait(250)
        if network.get_entity_net_owner(ram_ent) ~= player.player_id() then
            lua_notify_alert("An error has occurred, change session if the problem persists.", f.name)
            f.on = false
        end
    end
    if not f.on then
        lib.entity.delete_entity(ram_ent)
    end
end)

Player_Feature["Give Wanted Level"] = menu.add_player_feature("Give Wanted Level", "toggle", Player_Parents["Trolling"].id, function(f, pid)
    local cop
    if f.on then
        menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".services.give_wanted_level").value = 5
        menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".services.give_wanted_level").on = true
        cop = {}
        local cop_list <const> = {
            [1] = "S_M_Y_Swat_01",
            [2] = "S_M_Y_HwayCop_01",
            [3] = "S_M_Y_Cop_01",
            [4] = "S_F_Y_Cop_01",
            [5] = "S_M_Y_Marine_01",
            [6] = "S_M_Y_Marine_02",
            [7] = "S_M_Y_Marine_03",
            [8] = "S_M_M_SnowCop_01",
            [9] = "S_M_M_Marine_01",
            [10] = "S_M_M_Marine_02",
        }
        local pos1 <const> = player.get_player_coords(pid)
        for i = 1, 10 do
            cop[i] = lib.entity.spawn_entity(gameplay.get_hash_key(cop_list[i]), v3(pos1.x, pos1.y + 110, 2600), 0, false, false, false, true, false, true)
        end
    end
    while f.on do
        system.wait(100)
        menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".services.give_wanted_level").value = 5
        menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".services.give_wanted_level").on = true
        local pos1 <const> = player.get_player_coords(pid)
        for i in ipairs(cop) do
            entity.set_entity_coords_no_offset(cop[i], v3(pos1.x, pos1.y + 110, 2600))
        end
        fire.add_explosion(entity.get_entity_coords(cop[1]), lib.table.eExplosionTag["Grenade"], false, true, 0, player.get_player_ped(pid))
        system.wait(100)
        for i in ipairs(cop) do
            ped.resurrect_ped(cop[i])
        end
    end
    if not f.on then
        for i in ipairs(cop) do
            lib.entity.delete_entity(cop[i])
        end
    end
end)

Player_Feature["Player Magnet"] = menu.add_player_feature("Player Magnet", "toggle", Player_Parents["Trolling"].id, function(f, pid)
    while f.on do
        for i, ent in pairs(ped.get_all_peds()) do
            if not ped.is_ped_a_player(ent) then
                network.request_control_of_entity(ent)
                if network.get_entity_net_owner(ent) == player.player_id() then
                    lib.entity.entity_owner_can_migrate(ent, false)
                    if lib.entity.is_ped_using_any_vehicle(ent) then
                        ped.clear_ped_tasks_immediately(ent)
                    end
                    local NewOffset <const> = player.get_player_coords(pid) - entity.get_entity_coords(ent)
                    entity.apply_force_to_entity(ent, 1, NewOffset.x * 500, NewOffset.y * 500, NewOffset.z * 500, 0, 0, 0, false, true)
                end
            end
        end
        for i, entveh in pairs(vehicle.get_all_vehicles()) do
            for pid in lib.player.list(false) do
                if lib.entity.is_ped_using_vehicle(player.get_player_ped(pid), entveh) then
                    goto Magnet_Continue
                end
            end
            if network.get_entity_net_owner(entveh) == player.player_id() then
                lib.entity.entity_owner_can_migrate(entveh, false)
                lib.natives.SET_ENTITY_ROTATION(entveh, v3(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
                local NewOffset <const> = player.get_player_coords(pid) - entity.get_entity_coords(entveh)
                entity.apply_force_to_entity(entveh, 1, NewOffset.x * 500, NewOffset.y * 500, NewOffset.z * 500, 0, 0, 0, false, true)
            else
                network.request_control_of_entity(entveh)
            end
            ::Magnet_Continue::
        end
        system.wait(250)
    end
    if not f.on then
        for i, entped in pairs(ped.get_all_peds()) do
            lib.entity.entity_owner_can_migrate(entped, true)
            entity.set_entity_god_mode(entped, false)
        end
        for i, entveh in pairs(vehicle.get_all_vehicles()) do
            lib.entity.entity_owner_can_migrate(entveh, true)
        end
    end
end)

Player_Feature["Force Camera Farward"] = menu.add_player_feature("Force Camera Farward", "toggle", Player_Parents["Trolling"].id, function(f, pid)
    while f.on do
        lib.scriptevent.camera_farward(pid)
        system.wait()
    end
end)

Player_Feature["DirectX Fucker"] = menu.add_player_feature("DirectX Fucker", "action", Player_Parents["Trolling"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    Delete_Ped_Paparazzi_Crash = true
    local PedCrash1, PedCrash2 <const> = {}, {}
    for i = 1, 20 do
        local pos1 <const> = player.get_player_coords(pid)
        PedCrash1[i] = lib.entity.spawn_entity(gameplay.get_hash_key("CS_Stretch"), v3(pos1.x + 110, pos1.y, 2600), math.random(0, 360), false, true, true, true, false, true)
        PedCrash2[i] = lib.entity.spawn_entity(gameplay.get_hash_key("MP_F_DeadHooker"), v3(pos1.x + 110, pos1.y, 2600), math.random(0, 360), false, true, true, true, false, true)
        for i in ipairs(PedCrash1) do
            entity.set_entity_coords_no_offset(PedCrash1[i], v3(pos1.x + 110, pos1.y, 2600))
            entity.set_entity_coords_no_offset(PedCrash2[i], v3(pos1.x + 110, pos1.y, 2600))
        end
        system.wait(250)
    end
    local time <const> = utils.time_ms() + 3000
    while time > utils.time_ms() do
        for i in ipairs(PedCrash1) do
            local pos1 <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 0.0, 50.0, -1.65)
            entity.set_entity_coords_no_offset(PedCrash1[i], v3(pos1.x, pos1.y, pos1.z))
            entity.set_entity_coords_no_offset(PedCrash2[i], v3(pos1.x, pos1.y, pos1.z))
        end
        system.wait()
    end
    for i in ipairs(PedCrash1) do
        lib.entity.delete_entity(PedCrash1[i])
        lib.entity.delete_entity(PedCrash2[i])
    end
    Delete_Ped_Paparazzi_Crash = false
    lua_notify(lib.player.get_player_name(pid) .. " received the directX fucker well.", f.name)
end)

Player_Parents["Glitch Collision"] = menu.add_player_feature("Glitch Collision", "parent", Player_Parents["Trolling"].id)

Player_Feature["Glitch Collision Soft"] = menu.add_player_feature("Glitch Collision Soft", "toggle", Player_Parents["Glitch Collision"].id, function(f, pid)
    local objtrolls1
    if f.on then
        objtrolls1 = lib.entity.spawn_entity(gameplay.get_hash_key("prop_cablespool_02"), player.get_player_coords(pid), 0, false, true, false, false, true, true)
    end
    while f.on do
        entity.set_entity_coords_no_offset(objtrolls1, player.get_player_coords(pid))
        lib.natives.SET_ENTITY_ROTATION(objtrolls1, v3(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
        if network.get_entity_net_owner(objtrolls1) ~= player.player_id() then
            lua_notify_alert("An error has occurred, change session if the problem persists.", f.name)
            f.on = false
        end
        system.wait()
    end
    if not f.on then
        lib.entity.delete_entity(objtrolls1)
    end
end)

Player_Feature["Glitch Collision Medium"] = menu.add_player_feature("Glitch Collision Medium", "toggle", Player_Parents["Glitch Collision"].id, function(f, pid)
    if f.on then
        objtrolls2 = lib.entity.spawn_entity(gameplay.get_hash_key("prop_sub_trans_02a"), player.get_player_coords(pid) + v3(0, 0, -3), 0, false, true, false, true, true, true)
    end
    while f.on do
        entity.set_entity_coords_no_offset(objtrolls2, player.get_player_coords(pid) + v3(0, 0, -3))
        lib.natives.SET_ENTITY_ROTATION(objtrolls2, v3(0, 0, math.random(0, 360)))
        if network.get_entity_net_owner(objtrolls2) ~= player.player_id() then
            lua_notify_alert("An error has occurred, change session if the problem persists.", f.name)
            f.on = false
        end
        system.wait()
    end
    if not f.on then
        lib.entity.delete_entity(objtrolls2)
    end
end)

Player_Feature["Glitch Collision Hard"] = menu.add_player_feature("Glitch Collision Hard", "toggle", Player_Parents["Glitch Collision"].id, function(f, pid)
    if f.on then
        objtrolls3 = lib.entity.spawn_entity(gameplay.get_hash_key("p_spinning_anus_s"), player.get_player_coords(pid), 0, false, true, false, false, true, true)
    end
    while f.on do
        entity.set_entity_coords_no_offset(objtrolls3, player.get_player_coords(pid))
        lib.natives.SET_ENTITY_ROTATION(objtrolls3, v3(0, 0, math.random(0, 360)))
        if network.get_entity_net_owner(objtrolls3) ~= player.player_id() then
            lua_notify_alert("An error has occurred, change session if the problem persists.", f.name)
            f.on = false
        end
        system.wait()
    end
    if not f.on then
        lib.entity.delete_entity(objtrolls3)
    end
end)

--prop_garden_chimes_01
--v_ind_coo_heed
--v_ind_coo_quarter
--v_ind_coo_half

Player_Feature["Glitch Collision Ultra Hard"] = menu.add_player_feature("Glitch Collision Ultra Hard", "toggle", Player_Parents["Glitch Collision"].id, function(f, pid)
    if f.on then
        local pos1
        objtrolls4 = {}
        for i = 1, 7 do
            pos1 = player.get_player_coords(pid)
            objtrolls4[i] = lib.entity.spawn_entity(gameplay.get_hash_key("v_ind_coo_quarter"), v3(pos1.x + 75, pos1.y, pos1.z + 75), 0, false, true, false, false, true, true)
            for i in ipairs(objtrolls4) do
                entity.set_entity_coords_no_offset(objtrolls4[i], v3(pos1.x + 75, pos1.y, pos1.z + 75))
            end
            system.wait(100)
        end
        local objtrolls4_ <const> = lib.entity.spawn_entity(gameplay.get_hash_key("v_ind_bin_01"), v3(pos1.x + 75, pos1.y, pos1.z + 76), 0, false, true, false, false, true, true)
        entity.apply_force_to_entity(objtrolls4_, 1, 0, 0, -10, 0, 0, 0, false, true)
        system.wait(500)
        lib.entity.delete_entity(objtrolls4_)
    end
    while f.on do
        local pos1 <const> = player.get_player_coords(pid)
        for i in ipairs(objtrolls4) do
            entity.set_entity_coords_no_offset(objtrolls4[i], v3(pos1.x, pos1.y, pos1.z + 3))
            if network.get_entity_net_owner(objtrolls4[i]) ~= player.player_id() then
                lua_notify_alert("An error has occurred, change session if the problem persists.", f.name)
                f.on = false
            end
        end
        system.wait()
    end
    if not f.on then
        for i in ipairs(objtrolls4) do
            lib.entity.delete_entity(objtrolls4[i])
        end
    end
end)

Player_Parents["Disable Stuff"] = menu.add_player_feature("Disable Stuff", "parent", Player_Parents["Trolling"].id)

Player_Feature["Freeze v1"] = menu.add_player_feature("Freeze v1", "toggle", Player_Parents["Disable Stuff"].id, function(f, pid)
    while f.on do
        lib.scriptevent.freeze_player(pid)
        system.wait(100)
    end
end)

Player_Feature["Freeze v2"] = menu.add_player_feature("Freeze v2", "toggle", Player_Parents["Disable Stuff"].id, function(f, pid)
    while f.on do
        for i, ent in pairs(vehicle.get_all_vehicles()) do
            if network.get_entity_net_owner(ent) == pid then
                lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), ent, lib.table.temp_action["Brake"], 3000000)
            end
        end
        system.wait()
    end
    if not f.on then
        local time <const> = utils.time_ms() + 1000
        while time > utils.time_ms() do
            for i, ent in pairs(vehicle.get_all_vehicles()) do
                lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), ent, lib.table.temp_action["nil"], 1000)
            end
            system.wait()
        end
    end
end)

Player_Feature["Disable Jump & Weapon"] = menu.add_player_feature("Disable Jump & Weapon", "toggle", Player_Parents["Disable Stuff"].id, function(f, pid)
    while f.on do
        for i, ent in pairs(vehicle.get_all_vehicles()) do
            lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), ent, lib.table.temp_action["nil"], 1000)
        end
        system.wait()
    end
end)

Player_Feature["Disable Jump & Climb"] = menu.add_player_feature("Disable Jump & Climb", "toggle", Player_Parents["Disable Stuff"].id, function(f, pid)
    local DisableJumpVeh
    if f.on then
        local pos1 <const> = player.get_player_coords(pid)
        DisableJumpVeh = lib.entity.spawn_entity(gameplay.get_hash_key("dump"), v3(pos1.x, pos1.y, pos1.z), player.get_player_heading(pid), false, true, false, true, false, true)
    end
    while f.on do
        local pos1 <const> = player.get_player_coords(pid)
        entity.set_entity_coords_no_offset(DisableJumpVeh, v3(pos1.x, pos1.y, pos1.z))
        lib.natives.SET_ENTITY_ROTATION(DisableJumpVeh, v3(0, 0, player.get_player_heading(pid)))
        if network.get_entity_net_owner(DisableJumpVeh) ~= player.player_id() then
            lua_notify_alert("An error has occurred, change session if the problem persists.", f.name)
            f.on = false
        end
        system.wait()
    end
    if not f.on then
        lib.entity.delete_entity(DisableJumpVeh)
    end
end)

Player_Feature["Disable Projectiles"] = menu.add_player_feature("Disable Projectiles", "action", Player_Parents["Disable Stuff"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    for i = 1, 5 do
        local pos1 <const> = player.get_player_coords(pid)
        for i = 1, 60 do
            weapon.give_delayed_weapon_to_ped(player.player_ped(), gameplay.get_hash_key("WEAPON_BALL"), 0, false)
            gameplay.shoot_single_bullet_between_coords(v3(pos1.x, pos1.y, pos1.z), v3(pos1.x, pos1.y, pos1.z + 5), 0, gameplay.get_hash_key("WEAPON_BALL"), player.player_ped(), false, true, 0)
        end
        system.wait(500)
        lib.natives.CLEAR_AREA_OF_PROJECTILES(player.get_player_coords(player.player_id()), 400, 0)
        system.wait(100)
    end
end)

Player_Feature["Force To Casino Cutscene"] = menu.add_player_feature("Force To Casino Cutscene", "action", Player_Parents["Trolling"].id, function(f, pid)
    lib.scriptevent.force_to_casino_cutscene(pid)
end)

Player_Parents["Vehicle"] = menu.add_player_feature("Vehicle", "parent", Player_Parents["Player Parents"].id)

Player_Parents["Spawn Vehicle"] = menu.add_player_feature("Spawn", "parent", Player_Parents["Vehicle"].id, function(f, pid)
    if f.child_count == 0 then
        for _, eVehicleClass in ipairs(lib.essentials.sort_table_alphabetically("left", lib.table.eVehicleClass)) do
            Player_Parents[eVehicleClass.right] = menu.add_player_feature(eVehicleClass.left, "parent", Player_Parents["Spawn Vehicle"], function(f, pid)
                if f.child_count == 0 then
                    for _, vehicle_name_x_model in ipairs(lib.essentials.sort_table_alphabetically("right", vehicle_name_x_model)) do
                        local vehicle_models_hash <const> = gameplay.get_hash_key(vehicle_name_x_model.left)
                        if eVehicleClass.right == lib.natives.GET_VEHICLE_CLASS_FROM_NAME(vehicle_models_hash) then
                            Player_Feature[vehicle_models_hash] = menu.add_player_feature(vehicle_name_x_model.right, "action", Player_Parents[eVehicleClass.right], function(f, pid)
                                local spawn_vehicle <const> = lib.entity.spawn_entity(vehicle_models_hash, lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 0.0, lib.entity.get_hash_offset_dimension(vehicle_models_hash), 0.0), player.get_player_heading(pid), true, false, true, false, true, true)
                                vehicle.set_vehicle_on_ground_properly(spawn_vehicle)
                            end)
                        end
                    end
                end
            end).id
        end
    end
end).id

Player_Feature["Hijack & Lock Vehicle"] = menu.add_player_feature("Hijack & Lock Vehicle", "toggle", Player_Parents["Vehicle"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local PedHijackVehicle, plyrvehicle1
    if f.on then
        plyrvehicle1 = player.get_player_vehicle(pid)
        local pos1 <const> = player.get_player_coords(pid)
        PedHijackVehicle = lib.entity.spawn_entity(gameplay.get_hash_key("A_M_M_MexCntry_01"), v3(pos1.x, pos1.y, pos1.z - 5), 0, false, true, true, false, false, true)
        lib.natives.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(PedHijackVehicle, true)
        lib.natives.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(PedHijackVehicle, true)
        system.wait()
        entity.set_entity_visible(PedHijackVehicle, false)
        entity.set_entity_lod_dist(PedHijackVehicle, 0)
    end
    while f.on do
        local plyrvehicle2 <const> = player.get_player_vehicle(pid)
        if plyrvehicle1 ~= plyrvehicle2 and lib.natives.DOES_ENTITY_EXIST(plyrvehicle1) and lib.natives.IS_PED_SITTING_IN_ANY_VEHICLE(player.get_player_ped(pid)) then
            lua_notify(lib.player.get_player_name(pid) .. " changed his vehicle.", f.name)
            plyrvehicle1 = plyrvehicle2
        end
        if lib.natives.DOES_ENTITY_EXIST(plyrvehicle1) then
            lib.natives.TASK_ENTER_VEHICLE(PedHijackVehicle, plyrvehicle1, -1, -1, 2.0, 24, 0)
            ped.set_ped_into_vehicle(PedHijackVehicle, plyrvehicle1, -1)
        else
            lua_notify_alert(lib.player.get_player_name(pid) .. " has no assigned vehicle.", f.name)
            f.on = false
        end
        system.wait()
    end
    if not f.on then
        lib.entity.delete_entity(PedHijackVehicle)
    end
end)

Player_Feature["Destroy Personal Vehicle"] = menu.add_player_feature("Destroy Personal Vehicle", "action", Player_Parents["Vehicle"].id, function(f, pid)
    lib.scriptevent.destroy_personal_vehicle(pid)
end)

--[[
Player_Feature["is_player_online"] = menu.add_player_feature("is_player_online", "action", 0, function(f, pid)
    lib.player.is_player_online(pid)
end)
]]

Player_Feature["Steal Vehicle"] = menu.add_player_feature("Steal Vehicle", "action", Player_Parents["Vehicle"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local plyrvehicle <const> = player.get_player_vehicle(pid)
    local pos1 <const> = player.get_player_coords(pid)
    if lib.natives.DOES_ENTITY_EXIST(plyrvehicle) then
        local PedStealVehicle <const> = lib.entity.spawn_entity(gameplay.get_hash_key("A_M_M_MexCntry_01"), v3(pos1.x, pos1.y, pos1.z - 5), 0, false, true, true, false, false, true)
        lib.natives.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(PedHijackVehicle, true)
        lib.natives.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(PedStealVehicle, true)
        system.wait()
        entity.set_entity_visible(PedStealVehicle, false)
        entity.set_entity_lod_dist(PedStealVehicle, 0)
        lib.natives.TASK_ENTER_VEHICLE(PedStealVehicle, plyrvehicle, -1, -1, 2.0, 24, 0)
        local time <const> = utils.time_ms() + 3000
        while time > utils.time_ms() do
            if lib.natives.IS_PED_SITTING_IN_ANY_VEHICLE(PedStealVehicle) then
                lib.entity.delete_entity(PedStealVehicle)
                system.wait()
                ped.set_ped_into_vehicle(player.player_ped(), plyrvehicle, -1)
            end
            system.wait()
        end
        lib.entity.delete_entity(PedStealVehicle)
    else
        lua_notify_alert(lib.player.get_player_name(pid) .. " has no assigned vehicle.", f.name)
    end
end)

Player_Feature["Disable Driving"] = menu.add_player_feature("Disable Driving", "action", Player_Parents["Vehicle"].id, function(f, pid)
    lib.scriptevent.disable_driving_vehicles(pid)
end)

Player_Feature["Glitch Vehicle"] = menu.add_player_feature("Glitch Vehicle", "toggle", Player_Parents["Vehicle"].id, function(f, pid)
    local PedGlitchVehicle, VehGlitchVehicle, FreeSeatGlitchVehicle
    if f.on then
        FreeSeatGlitchVehicle = vehicle.get_free_seat(player.get_player_vehicle(pid))
    end
    while f.on do
        if lib.natives.IS_PED_SITTING_IN_ANY_VEHICLE(player.get_player_ped(pid)) then
            if FreeSeatGlitchVehicle ~= -2 then
                if not lib.natives.DOES_ENTITY_EXIST(PedGlitchVehicle) then
                    local pos1 <const> = player.get_player_coords(pid)
                    PedGlitchVehicle = lib.entity.spawn_entity(gameplay.get_hash_key("CSB_Avery"), v3(pos1.x, pos1.y, pos1.z), 0, false, true, false, false, true, true)
                    VehGlitchVehicle = lib.entity.spawn_entity(gameplay.get_hash_key("v_ind_cf_chickfeed"), v3(pos1.x, pos1.y, pos1.z), 0, false, true, false, false, true, true)
                end
                ped.set_ped_into_vehicle(PedGlitchVehicle, player.get_player_vehicle(pid), FreeSeatGlitchVehicle)
                entity.attach_entity_to_entity(VehGlitchVehicle, PedGlitchVehicle, 0, v3(0, 0, 0), v3(math.random(0, 360), math.random(0, 360), math.random(0, 360)), false, true, false, 0, true)
            else
                lua_notify_alert("No free seats in the vehicle.", f.name)
                f.on = false
            end
        else
            lua_notify_alert(lib.player.get_player_name(pid) .. " is not in a vehicle.", f.name)
            f.on = false
        end
        system.wait()
    end
    if not f.on then
        if lib.natives.DOES_ENTITY_EXIST(PedGlitchVehicle) and lib.natives.DOES_ENTITY_EXIST(VehGlitchVehicle) then
            lib.entity.delete_entity(PedGlitchVehicle)
            lib.entity.delete_entity(VehGlitchVehicle)
        end
    end
end)

Player_Feature["Kick From Vehicle"] = menu.add_player_feature("Kick From Vehicle", "action", Player_Parents["Vehicle"].id, function(f, pid)
    lib.scriptevent.kick_from_vehicle(pid)
end)

Player_Parents["Control Vehicle"] = menu.add_player_feature("Control Vehicle", "parent", Player_Parents["Vehicle"].id)

Player_Feature["Accelerate"] = menu.add_player_feature("Accelerate", "action", Player_Parents["Control Vehicle"].id, function(f, pid)
    lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), lib.table.temp_action["Accelerate"], Local_Feature["Running Time Control Vehicle"].value)
end)

Player_Feature["Reverse"] = menu.add_player_feature("Reverse", "action", Player_Parents["Control Vehicle"].id, function(f, pid)
    lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), lib.table.temp_action["Reverse"], Local_Feature["Running Time Control Vehicle"].value)
end)

Player_Feature["Brake"] = menu.add_player_feature("Brake", "action", Player_Parents["Control Vehicle"].id, function(f, pid)
    lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), lib.table.temp_action["Brake"], Local_Feature["Running Time Control Vehicle"].value)
end)

Player_Feature["Right"] = menu.add_player_feature("Right", "action", Player_Parents["Control Vehicle"].id, function(f, pid)
    lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), lib.table.temp_action["Right"], Local_Feature["Running Time Control Vehicle"].value)
end)

Player_Feature["Left"] = menu.add_player_feature("Left", "action", Player_Parents["Control Vehicle"].id, function(f, pid)
    lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), lib.table.temp_action["Left"], Local_Feature["Running Time Control Vehicle"].value)
end)

Player_Feature["Right + Accelerate"] = menu.add_player_feature("Right + Accelerate", "action", Player_Parents["Control Vehicle"].id, function(f, pid)
    lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), lib.table.temp_action["Right + Accelerate"], Local_Feature["Running Time Control Vehicle"].value)
end)

Player_Feature["Left + Accelerate"] = menu.add_player_feature("Left + Accelerate", "action", Player_Parents["Control Vehicle"].id, function(f, pid)
    lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), lib.table.temp_action["Left + Accelerate"], Local_Feature["Running Time Control Vehicle"].value)
end)

Player_Feature["Right + Reverse"] = menu.add_player_feature("Right + Reverse", "action", Player_Parents["Control Vehicle"].id, function(f, pid)
    lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), lib.table.temp_action["Right + Reverse"], Local_Feature["Running Time Control Vehicle"].value)
end)

Player_Feature["Left + Reverse"] = menu.add_player_feature("Left + Reverse", "action", Player_Parents["Control Vehicle"].id, function(f, pid)
    lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), lib.table.temp_action["Left + Reverse"], Local_Feature["Running Time Control Vehicle"].value)
end)

Player_Feature["Burnout"] = menu.add_player_feature("Burnout", "action", Player_Parents["Control Vehicle"].id, function(f, pid)
    lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), lib.table.temp_action["Burnout"], Local_Feature["Running Time Control Vehicle"].value)
end)

Player_Feature["Accelerate + Handbrake"] = menu.add_player_feature("Accelerate + Handbrake", "action", Player_Parents["Control Vehicle"].id, function(f, pid)
    lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), lib.table.temp_action["Accelerate + Handbrake"], Local_Feature["Running Time Control Vehicle"].value)
end)

Player_Feature["Control With Keyboard"] = menu.add_player_feature("Control With Keyboard", "toggle", Player_Parents["Control Vehicle"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    while f.on do
        menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".spectate_player").on = true
        entity.freeze_entity(player.player_ped(), true)
        local plyrvehicle <const> = player.get_player_vehicle(pid)
        if lib.natives.IS_PED_SITTING_IN_ANY_VEHICLE(player.get_player_ped(pid)) then
            if lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Up Only"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move LR"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Left Only"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Down Only"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Jump"]) then
                lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), plyrvehicle, lib.table.temp_action["Accelerate"], 200)
            end
            if lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move LR"]) and lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Up Only"]) then
                lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), plyrvehicle, lib.table.temp_action["Right + Accelerate"], 200)
            end
            if lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Left Only"]) and lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Up Only"]) then
                lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), plyrvehicle, lib.table.temp_action["Left + Accelerate"], 200)
            end
            if lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Down Only"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Up Only"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move LR"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Left Only"]) then
                lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), plyrvehicle, lib.table.temp_action["Reverse"], 200)
            end
            if lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move LR"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Up Only"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Down Only"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Jump"]) then
                lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), plyrvehicle, lib.table.temp_action["Right"], 200)
            end
            if lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Left Only"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Up Only"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Down Only"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Jump"]) then
                lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), plyrvehicle, lib.table.temp_action["Left"], 200)
            end
            if lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Jump"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Up Only"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move LR"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Left Only"]) then
                lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), plyrvehicle, lib.table.temp_action["Brake"], 200)
            end
            if lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Down Only"]) and lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Up Only"]) then
                lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), plyrvehicle, lib.table.temp_action["Burnout"], 200)
            end
            if lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Jump"]) and lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Up Only"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move LR"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Left Only"]) then
                lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), plyrvehicle, lib.table.temp_action["Accelerate + Handbrake"], 200)
            end
            if lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move LR"]) and lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Down Only"]) then
                lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), plyrvehicle, lib.table.temp_action["Right + Reverse"], 200)
            end
            if lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Left Only"]) and lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Down Only"]) then
                lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), plyrvehicle, lib.table.temp_action["Left + Reverse"], 200)
            end
            if lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Jump"]) and lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move LR"]) then
                lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), plyrvehicle, lib.table.temp_action["Brake + Right"], 200)
            end
            if lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Jump"]) and lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Left Only"]) then
                lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), plyrvehicle, lib.table.temp_action["Brake + Left"], 200)
            end
        end
        system.wait()
    end
    if not f.on then
        entity.freeze_entity(player.player_ped(), false)
        menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".spectate_player").on = false
    end
end)

Player_Feature["Horn Boost"] = menu.add_player_feature("Horn Boost", "value_i", Player_Parents["Vehicle"].id, function(f, pid)
    while f.on do
        local plyrvehicle <const> = player.get_player_vehicle(pid)
        if player.is_player_in_any_vehicle(pid) and player.is_player_pressing_horn(pid) then
            if lib.essentials.request_control(plyrvehicle, 2500) then
                vehicle.set_vehicle_forward_speed(plyrvehicle, lib.entity.get_entity_speed_with_pos(plyrvehicle) + f.value)
            else
                f.on = false
                f.value = 0
                lua_notify_alert("Failed to horn boost.", f.name)
                return
            end
        end
        system.wait()
    end
end)
Player_Feature["Horn Boost"].max = 100
Player_Feature["Horn Boost"].min = 0
Player_Feature["Horn Boost"].mod = 1
Player_Feature["Horn Boost"].value = 0

Player_Feature["Invincible"] = menu.add_player_feature("Invincible", "value_str", Player_Parents["Vehicle"].id, function(f, pid)
    if f.on then
        lib.player.check_player_vehicle_and_spec_if_necessary(pid, function()
            local plyrvehicle <const> = player.get_player_vehicle(pid)
            if f.value == 0 then
                if not entity.get_entity_god_mode(plyrvehicle) then
                    if lib.essentials.request_control(plyrvehicle, 2500) then
                        entity.set_entity_god_mode(plyrvehicle, true)
                        vehicle.set_vehicle_can_be_visibly_damaged(plyrvehicle, false)
                    else
                        f.on = false
                        lua_notify_alert("Failed to give Invincible.", f.name)
                        return
                    end
                end
            else
                if entity.get_entity_god_mode(plyrvehicle) then
                    if lib.essentials.request_control(plyrvehicle, 2500) then
                        entity.set_entity_god_mode(plyrvehicle, false)
                        vehicle.set_vehicle_can_be_visibly_damaged(plyrvehicle, true)
                    else
                        f.on = false
                        lua_notify_alert("Failed to remove Invincible.", f.name)
                        return
                    end
                end
            end
        end)
    end
    while f.on do
        local plyrvehicle <const> = player.get_player_vehicle(pid)
        if f.value == 0 then
            if not entity.get_entity_god_mode(plyrvehicle) and lib.essentials.request_control(plyrvehicle, 2500) then
                entity.set_entity_god_mode(plyrvehicle, true)
                vehicle.set_vehicle_can_be_visibly_damaged(plyrvehicle, false)
            end
        else
            if entity.get_entity_god_mode(plyrvehicle) and lib.essentials.request_control(plyrvehicle, 2500) then
                entity.set_entity_god_mode(plyrvehicle, false)
                vehicle.set_vehicle_can_be_visibly_damaged(plyrvehicle, true)
            end
        end
        system.wait()
    end
end)
Player_Feature["Invincible"]:set_str_data({"Give", "Remove"})

Player_Feature["Modify Speed"] = menu.add_player_feature("Modify Speed", "action_value_f", Player_Parents["Vehicle"].id, function(f, pid)
    lib.player.check_player_vehicle_and_spec_if_necessary(pid, function()
        local plyrvehicle <const> = player.get_player_vehicle(pid)
        if not lib.natives.DOES_ENTITY_EXIST(plyrvehicle) then
            lua_notify_alert(lib.player.get_player_name(pid) .. " has no assigned vehicle.", f.name)
            return
        end
        if lib.essentials.request_control(plyrvehicle, 2500) then
            lua_notify("Speed modify to " .. string.format("%.2f", f.value), f.name)
            vehicle.modify_vehicle_top_speed(plyrvehicle, (string.format("%.2f", f.value) - 1) * 100)
        else
            lua_notify_alert("Failed to modify speed.", f.name)
        end
    end)
end)
Player_Feature["Modify Speed"].max = 10.00
Player_Feature["Modify Speed"].min = -1.00
Player_Feature["Modify Speed"].mod = 0.10
Player_Feature["Modify Speed"].value = 1.00

Player_Feature["Freeze Vehicle"] = menu.add_player_feature("Freeze", "action_value_str", Player_Parents["Vehicle"].id, function(f, pid)
    lib.player.check_player_vehicle_and_spec_if_necessary(pid, function()
        local plyrvehicle <const> = player.get_player_vehicle(pid)
        if not lib.natives.DOES_ENTITY_EXIST(plyrvehicle) then
            lua_notify_alert(lib.player.get_player_name(pid) .. " has no assigned vehicle.", f.name)
            return
        end
        if f.value == 0 then
            if not lib.entity.is_entity_frozen(plyrvehicle) then
                if lib.essentials.request_control(plyrvehicle, 2500) then
                    entity.freeze_entity(plyrvehicle, true)
                else
                    lua_notify_alert("Failed to give freeze.", f.name)
                end
            else
                lua_notify_alert("Vehicle already freeze.", f.name)
            end
        else
            if lib.entity.is_entity_frozen(plyrvehicle) then
                if lib.essentials.request_control(plyrvehicle, 2500) then
                    entity.freeze_entity(plyrvehicle, false)
                else
                    lua_notify_alert("Failed to remove freeze.", f.name)
                end
            else
                lua_notify_alert("Vehicle already unfreeze.", f.name)
            end
        end
    end)
end)
Player_Feature["Freeze Vehicle"]:set_str_data({"Give", "Remove"})

Player_Feature["Tunings"] = menu.add_player_feature("Tunings", "action_value_str", Player_Parents["Vehicle"].id, function(f, pid)
    lib.player.check_player_vehicle_and_spec_if_necessary(pid, function()
        local plyrvehicle <const> = player.get_player_vehicle(pid)
        if not lib.natives.DOES_ENTITY_EXIST(plyrvehicle) then
            lua_notify_alert(lib.player.get_player_name(pid) .. " has no assigned vehicle.", f.name)
            return
        end
        if lib.essentials.request_control(plyrvehicle, 2500) then
            if f.value == 0 then
                lib.entity.upgrade(plyrvehicle, false)
            elseif f.value == 1 then
                lib.entity.downgrade(plyrvehicle, false)
            elseif f.value == 2 then
                lib.entity.upgrade(plyrvehicle, true)
            elseif f.value == 3 then
                lib.entity.downgrade(plyrvehicle, true)
            end
        else
            lua_notify_alert("Failed to tunings vehicle.", f.name)
        end
    end)
end)
Player_Feature["Tunings"]:set_str_data({"Upgrade", "Downgrade", "Upgrade Only Perf", "Downgrade Only Perf"})

Player_Feature["Engine"] = menu.add_player_feature("Engine", "action_value_str", Player_Parents["Vehicle"].id, function(f, pid)
    lib.player.check_player_vehicle_and_spec_if_necessary(pid, function()
        local plyrvehicle <const> = player.get_player_vehicle(pid)
        if not lib.natives.DOES_ENTITY_EXIST(plyrvehicle) then
            lua_notify_alert(lib.player.get_player_name(pid) .. " has no assigned vehicle.", f.name)
            return
        end
        if f.value == 0 then
            if lib.natives.GET_VEHICLE_ENGINE_HEALTH(plyrvehicle) ~= -4000 then
                if lib.essentials.request_control(plyrvehicle, 2500) then
                    vehicle.set_vehicle_engine_health(plyrvehicle, -4000)
                else
                    lua_notify_alert("Failed to kill engine.", f.name)
                end
            else
                lua_notify_alert("Engine already kill.", f.name)
            end
        elseif f.value == 1 then
            if lib.natives.GET_VEHICLE_ENGINE_HEALTH(plyrvehicle) ~= 1000 then
                if lib.essentials.request_control(plyrvehicle, 2500) then
                    vehicle.set_vehicle_engine_health(plyrvehicle, 1000)
                else
                    lua_notify_alert("Failed to revive engine.", f.name)
                end
            else
                lua_notify_alert("Engine already revive.", f.name)
            end
        elseif f.value == 2 then
            if lib.essentials.request_control(plyrvehicle, 2500) then
                vehicle.set_vehicle_engine_on(plyrvehicle, false, true, false)
            else
                lua_notify_alert("Failed to revive engine.", f.name)
            end
        end
    end)
end)
Player_Feature["Engine"]:set_str_data({"Kill", "Revive", "Turn Off"})

Player_Feature["Doors"] = menu.add_player_feature("Doors", "action_value_str", Player_Parents["Vehicle"].id, function(f, pid)
    lib.player.check_player_vehicle_and_spec_if_necessary(pid, function()
        local plyrvehicle <const> = player.get_player_vehicle(pid)
        if not lib.natives.DOES_ENTITY_EXIST(plyrvehicle) then
            lua_notify_alert(lib.player.get_player_name(pid) .. " has no assigned vehicle.", f.name)
            return
        end
        if f.value == 0 then
            if not vehicle.get_vehicle_doors_locked_for_player(plyrvehicle, pid) then
                if lib.essentials.request_control(plyrvehicle, 2500) then
                    vehicle.set_vehicle_doors_locked(plyrvehicle, lib.table.lock_status["Locked Player Inside"])
                    vehicle.set_vehicle_doors_locked_for_player(player.get_player_vehicle(pid), pid, true)
                else
                    lua_notify_alert("Failed to lock doors.", f.name)
                end
            else
                lua_notify_alert("Doors already lock.", f.name)
            end
        elseif f.value == 1 then
            if vehicle.get_vehicle_doors_locked_for_player(plyrvehicle, pid) then
                if lib.essentials.request_control(plyrvehicle, 2500) then
                    vehicle.set_vehicle_doors_locked(plyrvehicle, lib.table.lock_status["Unlocked"])
                    vehicle.set_vehicle_doors_locked_for_player(player.get_player_vehicle(pid), pid, false)
                else
                    lua_notify_alert("Failed to unlock doors.", f.name)
                end
            else
                lua_notify_alert("Doors already unlock.", f.name)
            end
        elseif f.value == 2 then
            local DOOR_DAMAGED
            DOOR_DAMAGED = false
            for i = 0, 20 do
                if lib.natives.GET_IS_DOOR_VALID(plyrvehicle, i) and not lib.natives.IS_VEHICLE_DOOR_DAMAGED(plyrvehicle, i) then
                    DOOR_DAMAGED = true
                end
            end
            if DOOR_DAMAGED then
                if lib.essentials.request_control(plyrvehicle, 2500) then
                    for i = 0, 20 do
                        lib.natives.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(plyrvehicle, i, true)
                    end
                    system.wait()
                    for i = 0, 20 do
                        lib.natives.SET_VEHICLE_DOOR_BROKEN(plyrvehicle, i, false)
                    end
                else
                    lua_notify_alert("Failed to break doors.", f.name)
                end
            else
                lua_notify_alert("Doors already broken.", f.name)
            end
        end
    end)
end)
Player_Feature["Doors"]:set_str_data({"Lock", "Unlock", "Break"})

Player_Feature["Other"] = menu.add_player_feature("Other", "action_value_str", Player_Parents["Vehicle"].id, function(f, pid)
    lib.player.check_player_vehicle_and_spec_if_necessary(pid, function()
        local plyrvehicle <const> = player.get_player_vehicle(pid)
        if not lib.natives.DOES_ENTITY_EXIST(plyrvehicle) then
            lua_notify_alert(lib.player.get_player_name(pid) .. " has no assigned vehicle.", f.name)
            return
        end
        if f.value ~= 2 and lib.essentials.request_control(plyrvehicle, 2500) then
            if f.value == 0 then
                lib.entity.fix_vehicle(plyrvehicle)
            elseif f.value == 1 then
                entity.delete_entity(plyrvehicle)
                lib.essentials.table_remove(anarchy_spawned_entity, Entity)
            end
        end
        if f.value == 2 then
            if lib.player.its_me(pid, f.name, f) then return end
            lib.entity.clone_vehicle(plyrvehicle, lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.player_ped(), 0.0, lib.entity.get_hash_offset_dimension(entity.get_entity_model_hash(plyrvehicle)), 0.0), player.get_player_heading(player.player_id()))
        end
    end)
end)
Player_Feature["Other"]:set_str_data({"Repair", "Delete", "Clone"})

Player_Parents["Notif & Sound"] = menu.add_player_feature("Notif & Sound", "parent", Player_Parents["Player Parents"].id)

Player_Feature["Send Custom Job Message"] = menu.add_player_feature("Send Custom Job Message", "action", Player_Parents["Notif & Sound"].id, function(f, pid)
    local input_stat, input_val <const> = input.get("Enter your message (Limited to 93 characters)", "", 93, 0)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    lib.scriptevent.job_message(pid, "<font size='20'>~h~" .. input_val .. "<font size='0'>")
    lua_notify("Send: " .. input_val, f.name)
end)

Player_Feature["Send Custom SMS"] = menu.add_player_feature("Send Custom SMS", "action", Player_Parents["Notif & Sound"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local input_stat, input_val <const> = input.get("Enter your message (Limited to 63 characters)", "", 63, 0)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    if input_val == "" then
        lib.player.send_sms(pid, ".")
    else
        lib.player.send_sms(pid, input_val)
    end
    lua_notify("Send: " .. input_val, f.name)
end)

Player_Feature["Spam Notif v1"] = menu.add_player_feature("Spam Notif v1", "toggle", Player_Parents["Notif & Sound"].id, function(f, pid)
    while f.on do
        lib.scriptevent.notif_1(pid)
        system.wait(500)
    end
end)

Player_Feature["Spam Notif v2"] = menu.add_player_feature("Spam Notif v2", "toggle", Player_Parents["Notif & Sound"].id, function(f, pid)
    while f.on do
        lib.scriptevent.random_job_message(pid)
    end
end)

Player_Feature["Spam Notif v3"] = menu.add_player_feature("Spam Notif v3", "toggle", Player_Parents["Notif & Sound"].id, function(f, pid)
    while f.on do
        lib.scriptevent.notif_2(pid)
        system.wait()
    end
end)

Player_Feature["Spam Sound v1"] = menu.add_player_feature("Spam Sound v1", "toggle", Player_Parents["Notif & Sound"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    while f.on do
        lib.player.send_sms(pid, ".")
        system.wait(100)
    end
end)

Player_Feature["Spam Sound v2"] = menu.add_player_feature("Spam Sound v2", "toggle", Player_Parents["Notif & Sound"].id, function(f, pid)
    while f.on do
        lib.scriptevent.sound(pid)
        system.wait(100)
    end
end)

Player_Feature["Send Friend Request"] = menu.add_player_feature("Send Friend Request", "action", Player_Parents["Notif & Sound"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    network.add_friend(player.get_player_scid(pid), "")
end)

Player_Parents["Advertising"] = menu.add_player_feature("Advertising", "parent", Player_Parents["Notif & Sound"].id)

local All_Advertising_Job <const> = {
    "~r~Anarchy on top ^^\n~y~Best Lua for 2Take1\n~b~Discord: GfmmeQNc93",
    "~b~Anarchy on top ^^\n~y~Best Lua for 2Take1\n~r~Discord: GfmmeQNc93",
    "~y~Anarchy on top ^^\n~b~Best Lua for 2Take1\n~r~Discord: GfmmeQNc93",
    "~r~Anarchy on top ^^\n~b~Best Lua for 2Take1\n~y~Discord: GfmmeQNc93",
    "~b~Anarchy on top ^^\n~r~Best Lua for 2Take1\n~y~Discord: GfmmeQNc93",
    "~y~Anarchy on top ^^\n~r~Best Lua for 2Take1\n~b~Discord: GfmmeQNc93",
}

Player_Feature["Send Advertising Message"] = menu.add_player_feature("Send Advertising Job", "toggle", Player_Parents["Advertising"].id, function(f, pid)
    while f.on do
        lib.scriptevent.job_message(pid, "<font size='15'>~h~" .. All_Advertising_Job[math.random(1, #All_Advertising_Job)] .. "<font size='0'>")
        system.wait(2000)
    end
end)

Player_Feature["Send Advertising Message"] = menu.add_player_feature("Send Advertising SMS", "toggle", Player_Parents["Advertising"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    while f.on do
        lib.player.send_sms(pid, "Anarchy on top ^^                            Best Lua for 2Take1")
        system.wait(2000)
    end
end)

Player_Feature["Send Advertising Friend Request"] = menu.add_player_feature("Send Advertising Friend Request", "action", Player_Parents["Advertising"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    network.add_friend(player.get_player_scid(pid), "Anarchy on top\nBest Lua for 2Take1\nDiscord ; GfmmeQNc93")
end)

Player_Parents["Removal"] = menu.add_player_feature("Removal", "parent", Player_Parents["Player Parents"].id)

--[[
Player_Feature["Test Crash"] = menu.add_player_feature("Test Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    local pos <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 0.0, 50.0, 100.0)
    local cargobob <const> = lib.entity.spawn_entity(gameplay.get_hash_key("Cargobob"), pos, 0, false, true, true, false, true, true)
    local comet4 <const> = lib.entity.spawn_entity(gameplay.get_hash_key("comet4"), v3(pos.x, pos.y, pos.z - 10), 0, false, true, true, false, true, true)
    lib.natives.SET_CARGOBOB_FORCE_DONT_DETACH_VEHICLE(cargobob, true)
    lib.natives.CREATE_PICK_UP_ROPE_FOR_CARGOBOB(cargobob, 0)
    lib.natives.SET_PICKUP_ROPE_LENGTH_FOR_CARGOBOB(cargobob, 0.0, 100.0, true)
    vehicle.set_heli_blades_full_speed(cargobob)
    local time <const> = utils.time_ms() + 5000
    while time > utils.time_ms() and not lib.natives.IS_VEHICLE_ATTACHED_TO_CARGOBOB(cargobob, comet4) do
        lib.natives.ATTACH_VEHICLE_TO_CARGOBOB(cargobob, comet4, -1, 0.0, 0.0, 0.0)
        system.wait()
    end
    system.wait(10000)
    lib.entity.delete_entity(cargobob)
    lib.entity.delete_entity(comet4)
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)
]]

Player_Feature["Smart Kick"] = menu.add_player_feature("Smart Kick", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    lib.player.smart_kick_player(pid)
end)

Player_Feature["Ultra Lag Player"] = menu.add_player_feature("Ultra Lag Player", "toggle", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    lib.player.block_outgoing_syncs(pid, function()
        LagPlayer = {}
        for i = 1, 23 do
            LagPlayer[i] = lib.entity.spawn_entity(gameplay.get_hash_key("patrolboat"), v3(10000, 10000, 2600), 0, false, true, false, false, false, true)
            lib.entity.sync_for_all_player(LagPlayer[i])
            entity.set_entity_gravity(LagPlayer[i], false)
            system.wait(100)
        end
        system.wait(5000)
        for i = 24, 31 do
            LagPlayer[i] = lib.entity.spawn_entity(gameplay.get_hash_key("tug"), v3(10000, 10000, 2600), 0, false, true, false, false, false, true)
            lib.entity.sync_for_all_player(LagPlayer[i])
            entity.set_entity_gravity(LagPlayer[i], false)
        end
        NtwrkJetski = lib.entity.spawn_entity(gameplay.get_hash_key("A_M_Y_Jetski_01"), v3(10000, 10000, 2600), 0, false, true, false, true, false, false)
        lua_notify(lib.player.get_player_name(pid).." received the ultra lag well.", f.name)
        while f.on do
            for i in ipairs(LagPlayer) do
                entity.attach_entity_to_entity(LagPlayer[i], NtwrkJetski, 0, v3(0, 0, 0), v3(math.random(0, 360), math.random(0, 360), math.random(0, 360)), false, true, false, 0, true)
            end
            system.wait()
        end
        for i in ipairs(LagPlayer) do
            lib.entity.delete_entity(LagPlayer[i])
        end
        lib.entity.delete_entity(NtwrkJetski)
    end)
end)

Player_Feature["Script Event Crash"] = menu.add_player_feature("Script Event Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    lib.scriptevent.crash(pid)
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)

Player_Feature["6G Crash"] = menu.add_player_feature("6G Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    lib.player.check_player_vehicle_and_spec_if_necessary(pid, function()
        if ped.is_ped_in_any_vehicle(player.get_player_ped(pid)) then
            lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), lib.table.temp_action["Crash 1"], 1000)
            lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), lib.table.temp_action["Crash 2"], 1000)
            lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), lib.table.temp_action["Crash 3"], 1000)
            lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), player.get_player_vehicle(pid), lib.table.temp_action["Crash 4"], 1000)
        else
            local adder <const> = lib.entity.spawn_entity(gameplay.get_hash_key("adder"), player.get_player_coords(pid) + v3(0, 0, -10), 0, false, true, true, true, true, true)
            lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), adder, lib.table.temp_action["Crash 1"], 1000)
            lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), adder, lib.table.temp_action["Crash 2"], 1000)
            lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), adder, lib.table.temp_action["Crash 3"], 1000)
            lib.natives.TASK_VEHICLE_TEMP_ACTION(player.get_player_ped(pid), adder, lib.table.temp_action["Crash 4"], 1000)
            system.wait(1000)
            lib.entity.delete_entity(adder)
        end
    end)
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)

Player_Feature["Sound Crash"] = menu.add_player_feature("Sound Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local time <const> = utils.time_ms() + 2500
    while time > utils.time_ms() do
        for i = 1, 10 do
            audio.play_sound_from_coord(-1, "Event_Message_Purple", player.get_player_coords(pid), "GTAO_FM_Events_Soundset", true, 1, false)
        end
        system.wait()
    end
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)

Player_Feature["Ruiner Crash"] = menu.add_player_feature("Ruiner Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    lib.player.block_outgoing_syncs(pid, function()
        Ruiner_Crash()
    end)
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)

Player_Feature["Ugly Crash"] = menu.add_player_feature("Ugly Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local pos <const> = player.get_player_coords(pid)
    pos.z = pos.z + 10
    local ranger <const> = lib.entity.spawn_entity(gameplay.get_hash_key("u_m_y_rsranger_01"), pos, 0, true, true, true, true, false, true)
    local time <const> = utils.time_ms() + 5000
    while time > utils.time_ms() do
        local pos <const> = player.get_player_coords(pid)
        pos.z = pos.z + 10
        lib.natives.TASK_SWEEP_AIM_POSITION(ranger, "anim@mp_player_intupperstinker", "", "", "", -1, 0.0, 0.0, 0.0, 0.0, 0.0)
        entity.set_entity_coords_no_offset(ranger, pos)
        network.give_player_control_of_entity(pid, ranger)
        if network.get_entity_net_owner(ranger) == pid then
            lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
            system.wait(1000)
            lib.entity.delete_entity(ranger)
            return
        end
        system.wait()
    end
    lib.entity.delete_entity(ranger)
    lua_notify_alert("Failed: " .. lib.player.get_player_name(pid) .. " probably blocks the sync.", f.name)
end)

Player_Feature["Parachute Crash"] = menu.add_player_feature("Parachute Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    lib.player.block_outgoing_syncs(pid, function()
        Parachute_Crash()
    end)
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)

Player_Feature["Slod Crash"] = menu.add_player_feature("Slod Crash", "action_value_str", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local slod_1, slod_2, slod_3
    menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".spectate_player").on = false
    local save_pos <const> = player.get_player_coords(player.player_id())
    entity.set_entity_coords_no_offset(player.player_ped(), v3(8000, 8000, 1000))
    entity.freeze_entity(player.player_ped(), true)
    if f.value == 0 or f.value == 3 then
        slod_1 = lib.entity.spawn_entity(gameplay.get_hash_key("slod_human"), player.get_player_coords(pid), 0, false, true, true, true, false, true)
    elseif f.value == 1 or f.value == 3 then
        slod_2 = lib.entity.spawn_entity(gameplay.get_hash_key("slod_small_quadped"), player.get_player_coords(pid), 0, false, true, true, true, false, true)
    elseif f.value == 2 or f.value == 3 then
        slod_3 = lib.entity.spawn_entity(gameplay.get_hash_key("slod_large_quadped"), player.get_player_coords(pid), 0, false, true, true, true, false, true)
    end
    system.wait(250)
    if lib.natives.DOES_ENTITY_EXIST(slod_1) then
        lib.entity.delete_entity(slod_1)
    end
    if lib.natives.DOES_ENTITY_EXIST(slod_2) then
        lib.entity.delete_entity(slod_2)
    end
    if lib.natives.DOES_ENTITY_EXIST(slod_3) then
        lib.entity.delete_entity(slod_3)
    end
    entity.freeze_entity(player.player_ped(), false)
    entity.set_entity_coords_no_offset(player.player_ped(), save_pos)
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)
Player_Feature["Slod Crash"]:set_str_data({"human", "small quadped", "large quadped", "AIO"})

Player_Feature["Grenade Crash"] = menu.add_player_feature("Grenade Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local weapon_ped <const> = lib.entity.spawn_entity(gameplay.get_hash_key("A_C_Rat"), player.get_player_coords(pid), 0, false, false, false, false, true, true)
    lib.natives.GIVE_WEAPON_TO_PED(weapon_ped, gameplay.get_hash_key("WEAPON_GRENADE"), 1, true, true)
    local pos <const> = player.get_player_coords(pid)
    lib.natives.TASK_THROW_PROJECTILE(weapon_ped, pos.x, pos.y, pos.z, 0, false)
    system.wait(1000)
    lib.entity.delete_entity(weapon_ped)
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)

Player_Feature["Cute Crash"] = menu.add_player_feature("Cute Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local pos <const> = player.get_player_coords(pid)
    pos.z = pos.z + 10
    local A_C_Rat <const> = lib.entity.spawn_entity(gameplay.get_hash_key("A_C_Rat"), pos, 0, false, true, true, false, true, true)
    local BMX <const> = lib.entity.spawn_entity(gameplay.get_hash_key("thruster"), pos, 0, false, true, true, true, true, true)
    local time <const> = utils.time_ms() + 2500
    while time > utils.time_ms() do
        ped.set_ped_into_vehicle(A_C_Rat, BMX, -1)
        ped.set_ped_health(A_C_Rat, 0.0)
        lib.natives.TASK_LEAVE_VEHICLE(A_C_Rat, BMX, 0)
        system.wait(100)
        ped.set_ped_health(A_C_Rat, 100.0)
    end
    lib.entity.delete_entity(A_C_Rat)
    lib.entity.delete_entity(BMX)
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)

Player_Feature["Knuckle Crash"] = menu.add_player_feature("Knuckle Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local weapon_ped <const> = lib.entity.spawn_entity(gameplay.get_hash_key("cs_taostranslator2"), player.get_player_coords(pid), 0, false, false, false, false, true, true)
    weapon.give_delayed_weapon_to_ped(weapon_ped, gameplay.get_hash_key("WEAPON_KNUCKLE"), 0, true)
    lib.natives.SET_PED_GADGET(weapon_ped, gameplay.get_hash_key("WEAPON_KNUCKLE"), true)
    ped.set_ped_health(weapon_ped, 0)
    system.wait(1000)
    lib.entity.delete_entity(weapon_ped)
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)

Player_Feature["Ped Component Variation Crash"] = menu.add_player_feature("Ped Component Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".spectate_player").on = false
    local save_pos <const> = player.get_player_coords(player.player_id())
    entity.set_entity_coords_no_offset(player.player_ped(), v3(8000, 8000, 1000))
    entity.freeze_entity(player.player_ped(), true)
    local ped_variation <const> = lib.entity.spawn_entity(gameplay.get_hash_key("Player_Zero"), player.get_player_coords(pid), 0, false, true, true, true, false, true)
    ped.set_ped_component_variation(ped_variation, 0, 0, 7, 0)
    local time <const> = utils.time_ms() + 1000
    while time > utils.time_ms() do
        entity.set_entity_coords_no_offset(ped_variation, player.get_player_coords(pid))
        system.wait()
    end
    lib.entity.delete_entity(ped_variation)
    entity.freeze_entity(player.player_ped(), false)
    entity.set_entity_coords_no_offset(player.player_ped(), save_pos)
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)

Player_Feature["Control Crash"] = menu.add_player_feature("Control Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local pos  <const> = player.get_player_coords(pid)
    pos.z = pos.z + 50
    local mod_veh <const> = {"metrotrain", "microlight"}
    local spawn_veh <const> = {}
    local number = 0
    for i = 1, 5 do
        for v = 1, #mod_veh do
            number = number + 1
            spawn_veh[number] = lib.entity.spawn_entity(gameplay.get_hash_key(mod_veh[v]), pos, 0, false, false, true, true, true, true)
        end
    end
    system.wait(1000)
    local time <const> = utils.time_ms() + 1000
    while time > utils.time_ms() do
        for i in ipairs(spawn_veh) do
            lib.entity.entity_owner_can_migrate(spawn_veh[i], true)
            system.wait()
            network.give_player_control_of_entity(pid, spawn_veh[i])
        end
    end
    system.wait(1000)
    for i in ipairs(spawn_veh) do
        lib.entity.delete_entity(spawn_veh[i])
    end
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)

Player_Feature["Towtruck Crash"] = menu.add_player_feature("Towtruck Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local fixter <const> = {}
    local pos <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 0.0, 10.0, 0.0)
    local Towtruck <const> = lib.entity.spawn_entity(gameplay.get_hash_key("Towtruck"), pos, 0, false, true, false, true, true, true)
    for i = 1, 5 do
        fixter[i] = lib.entity.spawn_entity(gameplay.get_hash_key("fixter"), pos, 0, false, true, true, false, true, true)
        entity.attach_entity_to_entity(fixter[i], Towtruck, 0, v3(0, 0, 0), v3(0, 0, 0), true, true, false, 0, true)
        system.wait()
    end
    system.wait(5000)
    for i in ipairs(fixter) do
        lib.entity.delete_entity(fixter[i])
    end
    lib.entity.delete_entity(Towtruck)
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)

Player_Feature["Small Crash"] = menu.add_player_feature("Small Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local pos <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 0.0, 3.0, 0.0)
    local ped_crash <const> = lib.entity.spawn_entity(gameplay.get_hash_key("S_M_M_Janitor"), v3(pos.x, pos.y, pos.z + 1), 0, false, true, false, false, false, true)
    local obj_crash <const> = lib.entity.spawn_entity(gameplay.get_hash_key("v_ilev_gunhook"), pos, 0, false, true, false, false, false, true)
    local veh_crash <const> = lib.entity.spawn_entity(gameplay.get_hash_key("fixter"), pos, 0, false, true, false, false, false, true)
    ped.set_ped_to_ragdoll(ped_crash, 99999, 0, 0)
    system.wait(500)
    entity.attach_entity_to_entity(obj_crash, ped_crash, 0, v3(0, 0, 0), v3(0, 0, 0), true, true, false, 0, true)
    entity.attach_entity_to_entity(veh_crash, obj_crash, 0, v3(0, 0, 0), v3(0, 0, 0), true, true, false, 0, true)
    system.wait(1000)
    lib.entity.delete_entity(ped_crash)
    lib.entity.delete_entity(obj_crash)
    lib.entity.delete_entity(veh_crash)
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)

Player_Feature["Pepper Crash"] = menu.add_player_feature("Pepper Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local pos <const> = player.get_player_coords(pid)
    pos.z = pos.z + 10
    local A_M_Y_SouCent_04 <const> = lib.entity.spawn_entity(gameplay.get_hash_key("A_M_Y_SouCent_04"), pos, 0, true, true, true, true, false, true)
    local ninef2 <const> = lib.entity.spawn_entity(gameplay.get_hash_key("ninef2"), pos, 0, true, true, true, true, false, true)
    ped.set_ped_into_vehicle(A_M_Y_SouCent_04, ninef2, -1)
    local time <const> = utils.time_ms() + 5000
    while time > utils.time_ms() do
        local pos <const> = player.get_player_coords(pid)
        pos.z = pos.z + 10
        lib.natives.TASK_PLANE_LAND(A_M_Y_SouCent_04, ninef2, 0,0, 0.0, 0.0, 0.0, 0.0, 0.0)
        entity.set_entity_coords_no_offset(ninef2, pos)
        network.give_player_control_of_entity(pid, A_M_Y_SouCent_04)
        network.give_player_control_of_entity(pid, ninef2)
        if network.get_entity_net_owner(A_M_Y_SouCent_04) == pid and network.get_entity_net_owner(ninef2) == pid then
            lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
            system.wait(1000)
            lib.entity.delete_entity(A_M_Y_SouCent_04)
            lib.entity.delete_entity(ninef2)
            return
        end
        system.wait()
    end
    lib.entity.delete_entity(A_M_Y_SouCent_04)
    lib.entity.delete_entity(ninef2)
    lua_notify_alert("Failed: " .. lib.player.get_player_name(pid) .. " probably blocks the sync.", f.name)
end)

Player_Feature["Door Crash"] = menu.add_player_feature("Door Crash", "toggle", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local all_Broken_veh <const> = {
        "dubsta",
        "dubsta2",
        "fq2",
        "patriot",
        "radi",
        "habanero",
        "landstalker",
        "serrano",
        "cavalcade",
        "rocoto",
        "GRANGER",
        "Baller",
        "gresley",
        "baller2",
        "cavalcade2",
        "MESA",
        "Seminole",
        "BjXL",
        "mesa2",
        "huntley",
        "toros",
        "squaddie",
        "rebla",
        "baller3",
        "baller4",
        "baller5",
        "baller6",
        "xls",
        "xls2",
        "contender",
        "patriot2",
        "Novak",
        "landstalker2",
        "seminole2",
        "iwagen",
        "astron",
        "baller7",
        "jubilee",
        "granger2",
    }
    local Broken_vehs <const> = {}
    if f.on then
        local pos1 <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.get_player_ped(pid), 0.0, 110.0, 0.0)
        for i = 1, #all_Broken_veh do
            Broken_vehs[i] = lib.entity.spawn_entity(gameplay.get_hash_key(all_Broken_veh[i]), v3(pos1.x, pos1.y, 2600), 0, false, false, true, true, false, true)
            for i in ipairs(Broken_vehs) do
                entity.set_entity_coords_no_offset(Broken_vehs[i], v3(pos1.x, pos1.y, 2600))
            end
            system.wait(25)
        end
        lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
    end
    while f.on do
        local pos1 <const> = player.get_player_coords(pid)
        for i in ipairs(Broken_vehs) do
            entity.set_entity_coords_no_offset(Broken_vehs[i], v3(pos1.x, pos1.y, pos1.z + 2))
            for d = 0, 20 do
                lib.natives.SET_DOOR_ALLOWED_TO_BE_BROKEN_OFF(Broken_vehs[i], d, true)
            end
            system.wait()
            for d = 0, 20 do
                lib.natives.SET_VEHICLE_DOOR_BROKEN(Broken_vehs[i], d, false)
            end
        end
        system.wait()
        for i in ipairs(Broken_vehs) do
            vehicle.set_vehicle_fixed(Broken_vehs[i])
        end
    end
    if not f.on then
        for i in ipairs(Broken_vehs) do
            lib.entity.delete_entity(Broken_vehs[i])
        end
    end
end)

Player_Feature["Stinker Crash"] = menu.add_player_feature("Stinker Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local pos <const> = player.get_player_coords(pid)
    pos.z = pos.z + 10
    local ranger <const> = lib.entity.spawn_entity(gameplay.get_hash_key("u_m_y_rsranger_01"), pos, 0, true, true, true, true, false, true)
    local time <const> = utils.time_ms() + 5000
    while time > utils.time_ms() do
        local pos <const> = player.get_player_coords(pid)
        pos.z = pos.z + 10
        lib.natives.TASK_SWEEP_AIM_ENTITY(ranger, "anim@mp_player_intupperstinker", "", "", "", -1, ranger, 0.0, 0.0)
        entity.set_entity_coords_no_offset(ranger, pos)
        network.give_player_control_of_entity(pid, ranger)
        if network.get_entity_net_owner(ranger) == pid then
            lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
            system.wait(1000)
            lib.entity.delete_entity(ranger)
            return
        end
        system.wait()
    end
    lib.entity.delete_entity(ranger)
    lua_notify_alert("Failed: " .. lib.player.get_player_name(pid) .. " probably blocks the sync.", f.name)
end)

Player_Feature["Vegetation Crash"] = menu.add_player_feature("Vegetation Crash", "action_value_str", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local Basegame_Obj_Crash <const> = {
        "proc_forest_grass01",
        "prop_tall_grass_ba",
        "urbanweeds02_l1",
    }
    local Mpheist4_Obj_Crash <const> = {
        "h4_prop_bush_buddleia_low_01",
        "h4_prop_bush_ear_aa",
        "h4_prop_bush_ear_ab",
        "h4_prop_bush_fern_low_01",
        "h4_prop_bush_fern_tall_cc",
        "h4_prop_bush_mang_low_aa",
        "h4_prop_bush_mang_ad",
        "h4_prop_bush_mang_low_ab",
        "h4_prop_bush_seagrape_low_01",
        "h4_prop_grass_med_01",
        "h4_prop_grass_tropical_lush_01",
        "h4_prop_grass_wiregrass_01",
        "h4_prop_weed_groundcover_01",
    }
    local Obj_Crash_1, Obj_Crash_2 <const> = {}, {}
    if f.value == 0 or f.value == 2 then
        for i = 1, #Basegame_Obj_Crash do
            Obj_Crash_1[i] = lib.entity.spawn_entity(gameplay.get_hash_key(Basegame_Obj_Crash[i]), player.get_player_coords(pid), 0, false, true, false, true, false, true)
        end
    end
    if f.value == 1 or f.value == 2 then
        for i = 1, #Mpheist4_Obj_Crash do
            Obj_Crash_2[i] = lib.entity.spawn_entity(gameplay.get_hash_key(Mpheist4_Obj_Crash[i]), player.get_player_coords(pid), 0, false, true, false, true, false, true)
        end
    end
    system.wait(250)
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
    for i in ipairs(Obj_Crash_1) do
        lib.entity.delete_entity(Obj_Crash_1[i])
    end
    for i in ipairs(Obj_Crash_2) do
        lib.entity.delete_entity(Obj_Crash_2[i])
    end
end)
Player_Feature["Vegetation Crash"]:set_str_data({"v1", "v2", "AIO"})

Player_Feature["Ranger Crash"] = menu.add_player_feature("Ranger Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local pos <const> = player.get_player_coords(pid)
    pos.z = pos.z + 10
    local ranger <const> = lib.entity.spawn_entity(gameplay.get_hash_key("u_m_y_rsranger_01"), pos, 0, true, true, true, true, false, true)
    local technical <const> = lib.entity.spawn_entity(gameplay.get_hash_key("technical2"), pos, 0, true, true, true, true, false, true)
    ped.set_ped_into_vehicle(ranger, technical, 1)
    local time <const> = utils.time_ms() + 5000
    while time > utils.time_ms() do
        local pos <const> = player.get_player_coords(pid)
        pos.z = pos.z + 10
        lib.natives.SET_MOUNTED_WEAPON_TARGET(ranger, ranger, 0, 0.0, 0.0, 0.0, 5, true)
        entity.set_entity_coords_no_offset(technical, pos)
        network.give_player_control_of_entity(pid, ranger)
        network.give_player_control_of_entity(pid, technical)
        if network.get_entity_net_owner(ranger) == pid and network.get_entity_net_owner(technical) == pid then
            lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
            system.wait(1000)
            lib.entity.delete_entity(ranger)
            lib.entity.delete_entity(technical)
            return
        end
        system.wait()
    end
    lib.entity.delete_entity(ranger)
    lib.entity.delete_entity(technical)
    lua_notify_alert("Failed: " .. lib.player.get_player_name(pid) .. " probably blocks the sync.", f.name)
end)

Player_Feature["Look Crash"] = menu.add_player_feature("Look Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".spectate_player").on = false
    local save_pos <const> = player.get_player_coords(player.player_id())
    entity.set_entity_coords_no_offset(player.player_ped(), v3(8000, 8000, 1000))
    entity.freeze_entity(player.player_ped(), true)
    local ent <const> = lib.entity.spawn_world_object(gameplay.get_hash_key("minitank"), player.get_player_coords(pid), 0, false, true, false, false, false, true, false)
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
    system.wait(1000)
    lib.entity.delete_entity(ent)
    entity.freeze_entity(player.player_ped(), false)
    entity.set_entity_coords_no_offset(player.player_ped(), save_pos)
end)

Player_Feature["Oil Crash"] = menu.add_player_feature("Oil Crash", "action", Player_Parents["Removal"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local pos <const> = player.get_player_coords(pid)
    pos.z = pos.z + 10
    local spanw_ob <const> = lib.entity.spawn_entity(gameplay.get_hash_key("p_oil_pjack_02_s"), pos, 0, false, true, false, true, false, true)
    local crash_ped_task <const> = lib.entity.spawn_entity(gameplay.get_hash_key("a_c_rat"), pos, 0, false, true, false, false, false, true)
    local time <const> = utils.time_ms() + 5000
    while time > utils.time_ms() do
        lib.natives.TASK_CLIMB_LADDER(crash_ped_task)
        system.wait(100)
        ped.clear_ped_tasks_immediately(crash_ped_task)
    end
    lib.entity.delete_entity(spanw_ob)
    lib.entity.delete_entity(crash_ped_task)
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)

--[[
Player_Feature["Collision Crash"] = menu.add_player_feature("Collision Crash", "toggle", Player_Parents["Removal"].id, function(f, pid)
    local veh1, veh2, Abracada
    if lib.player.its_me(pid, f.name, f) then return end
    local Abracada <const> = {}
    while f.on do
        local pos1 <const> = player.get_player_coords(pid)
        pos1.y = pos1.y + 100
        pos1.z = pos1.z + 100
        local veh1 <const> = lib.entity.spawn_entity(gameplay.get_hash_key("t20"), v3(pos1.x, pos1.y, pos1.z + 10), 0, false, true, false, true, true, true)
        for i = 1, 45 do
            Abracada[i] = lib.entity.spawn_entity(gameplay.get_hash_key("frogger2"), pos1, 0, false, true, false, false, true, true)
            entity.attach_entity_to_entity(Abracada[i], veh1, 0, v3(pos1.x, pos1.y, pos1.z), v3(0, 0, 0), false, true, false, 0, true)
            system.wait(100)
        end
        lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
        for i in ipairs(Abracada) do
            lib.natives.ATTACH_ENTITY_TO_ENTITY_PHYSICALLY(Abracada[i], veh1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, int_max, true, true, true, true, 2)
        end
        system.wait(2500)
        for i in ipairs(Abracada) do
            lib.entity.delete_entity(Abracada[i])
        end
        lib.entity.delete_entity(veh1)
    end
end)
]]

Player_Parents["Need Stand"] = menu.add_player_feature("Need Stand", "parent", Player_Parents["Removal"].id, function(f, pid)
    lua_notify_alert("Your game will crash if you don't use the stand mod menu.", "Stand User")
end)

Player_Feature["Backpack Crash"] = menu.add_player_feature("Backpack Crash", "action", Player_Parents["Need Stand"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    lib.player.block_outgoing_syncs(pid, function()
        Backpack_Crash()
    end)
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)

Player_Feature["Fragment Crash"] = menu.add_player_feature("Fragment Crash", "action", Player_Parents["Need Stand"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local fragment <const> = lib.entity.spawn_entity(gameplay.get_hash_key("prop_fragtest_cnst_04"), player.get_player_coords(pid) + v3(0, 0, -10), 0, false, false, true, false, true, true)
    lib.natives.BREAK_OBJECT_FRAGMENT_CHILD(fragment, 1, false)
    lib.natives.BREAK_OBJECT_FRAGMENT_CHILD(fragment, 2, false)
    system.wait(1000)
    for i, ent in pairs(object.get_all_objects()) do
        if entity.get_entity_model_hash(ent) == 310817095 then
            lib.entity.delete_entity(ent)
        end
    end
    lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
end)

Player_Feature["Vladimir Crash"] = menu.add_player_feature("Vladimir Crash", "action", Player_Parents["Need Stand"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local pos <const> = player.get_player_coords(pid)
    pos.z = pos.z + 10
    local A_M_Y_SouCent_04 <const> = lib.entity.spawn_entity(gameplay.get_hash_key("A_M_Y_SouCent_04"), pos, 0, true, true, true, true, false, true)
    local ninef2 <const> = lib.entity.spawn_entity(gameplay.get_hash_key("ninef2"), pos, 0, true, true, true, true, false, true)
    ped.set_ped_into_vehicle(A_M_Y_SouCent_04, ninef2, -1)
    local time <const> = utils.time_ms() + 5000
    while time > utils.time_ms() do
        local pos <const> = player.get_player_coords(pid)
        pos.z = pos.z + 10
        lib.natives.TASK_VEHICLE_HELI_PROTECT(A_M_Y_SouCent_04, ninef2, player.get_player_ped(pid), 10.0, 0, 10, 0, 0)
        entity.set_entity_coords_no_offset(ninef2, pos)
        network.give_player_control_of_entity(pid, A_M_Y_SouCent_04)
        network.give_player_control_of_entity(pid, ninef2)
        if network.get_entity_net_owner(A_M_Y_SouCent_04) == pid and network.get_entity_net_owner(ninef2) == pid then
            lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
            system.wait(1000)
            lib.entity.delete_entity(A_M_Y_SouCent_04)
            lib.entity.delete_entity(ninef2)
            return
        end
        system.wait()
    end
    lib.entity.delete_entity(A_M_Y_SouCent_04)
    lib.entity.delete_entity(ninef2)
    lua_notify_alert("Failed: " .. lib.player.get_player_name(pid) .. " probably blocks the sync.", f.name)
end)

Player_Feature["Risky Self Crash"] = menu.add_player_feature("Risky Self Crash", "action", Player_Parents["Need Stand"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local pos <const> = player.get_player_coords(pid)
    pos.z = pos.z + 20
    local A_M_Y_SouCent_04 <const> = lib.entity.spawn_entity(gameplay.get_hash_key("A_M_Y_SouCent_04"), pos, 0, true, true, true, true, false, true)
    local ninef2 <const> = lib.entity.spawn_entity(gameplay.get_hash_key("ninef2"), pos, 0, true, true, true, true, false, true)
    ped.set_ped_into_vehicle(A_M_Y_SouCent_04, ninef2, -1)
    lib.natives.TASK_SUBMARINE_GOTO_AND_STOP(A_M_Y_SouCent_04, ninef2, 0, 0, 0, false)
    local time <const> = utils.time_ms() + 5000
    while time > utils.time_ms() do
        local pos <const> = player.get_player_coords(pid)
        pos.z = pos.z + 20
        entity.set_entity_coords_no_offset(ninef2, pos)
        network.give_player_control_of_entity(pid, A_M_Y_SouCent_04)
        network.give_player_control_of_entity(pid, ninef2)
        if network.get_entity_net_owner(A_M_Y_SouCent_04) == pid and network.get_entity_net_owner(ninef2) == pid then
            lua_notify(lib.player.get_player_name(pid) .. " received the crash well.", f.name)
            system.wait(1000)
            lib.entity.delete_entity(A_M_Y_SouCent_04)
            lib.entity.delete_entity(ninef2)
            return
        end
        system.wait()
    end
    lib.entity.delete_entity(A_M_Y_SouCent_04)
    lib.entity.delete_entity(ninef2)
    lua_notify_alert("Failed: " .. lib.player.get_player_name(pid) .. " probably blocks the sync.", f.name)
end)

Player_Parents["Advanced Detection"] = menu.add_player_feature("Advanced Detection", "parent", Player_Parents["Player Parents"].id)

Player_Feature["Invincible Detection"] = menu.add_player_feature("Invincible Detection", "action", Player_Parents["Advanced Detection"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".spectate_player").on = true
    system.wait(500)
    local health_old <const> = player.get_player_health(pid)
    local armor_old <const> = player.get_player_armor(pid)
    gameplay.shoot_single_bullet_between_coords(player.get_player_coords(pid) + v3(0, 0, 0.1), player.get_player_coords(pid), 1, gameplay.get_hash_key("WEAPON_COMPACTRIFLE"), player.player_ped(), false, true, 0)
    system.wait(250)
    gameplay.shoot_single_bullet_between_coords(player.get_player_coords(pid) + v3(0, 0, 0.1), player.get_player_coords(pid), 1, gameplay.get_hash_key("WEAPON_COMPACTRIFLE"), player.player_ped(), false, true, 0)
    system.wait(250)
    gameplay.shoot_single_bullet_between_coords(player.get_player_coords(pid) + v3(0, 0, 0.1), player.get_player_coords(pid), 1, gameplay.get_hash_key("WEAPON_COMPACTRIFLE"), player.player_ped(), false, true, 0)
    system.wait(1000)
    local health_new <const> = player.get_player_health(pid)
    if health_old == health_new and armor_old == player.get_player_armor(pid) then
        lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Player Invincible", "Anarchy Modder Detection")
    end
    menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".spectate_player").on = false
end)

function advanced_modder_detection(f, pid, hash)
    local pos1 <const> = player.get_player_coords(pid)
    local DetectEntity
    if hash == gameplay.get_hash_key("MP_F_Freemode_01") or hash == gameplay.get_hash_key("MP_M_Freemode_01") then
        DetectEntity = lib.entity.spawn_entity(hash, v3(pos1.x, pos1.y, pos1.z - 5), 0, true, true, true, true, false, true)
        lib.natives.CLONE_PED_TO_TARGET(player.get_player_ped(pid), DetectEntity)
    else
        DetectEntity = lib.entity.spawn_entity(gameplay.get_hash_key(hash), v3(pos1.x, pos1.y, pos1.z - 5), 0, true, true, true, true, false, true)
    end
    local time <const> = utils.time_ms() + 3000
    while time > utils.time_ms() do
        network.give_player_control_of_entity(pid, DetectEntity)
        local pos1 <const> = player.get_player_coords(pid)
        entity.set_entity_coords_no_offset(DetectEntity, v3(pos1.x, pos1.y, pos1.z - 5))
        local owner <const> = network.get_entity_net_owner(DetectEntity)
        if not lib.natives.DOES_ENTITY_EXIST(DetectEntity) then
            return "true"
        end
        if owner ~= nil and owner ~= pid and owner ~= player.player_id() and player.is_player_valid(owner) then
            local name_other_owner <const> = lib.player.get_player_name(owner)
            lua_notify(name_other_owner .. " are too close to the Target.", f.name)
            return "stop"
        end
        if owner == pid then
            local time <const> = utils.time_ms() + 3000
            while time > utils.time_ms() do
                network.request_control_of_entity(DetectEntity)
                if network.get_entity_net_owner(DetectEntity) == player.player_id() then
                    lib.entity.delete_entity(DetectEntity)
                    return "false"
                end
                system.wait()
            end
            return "true"
        end
        system.wait()
    end
    lib.entity.delete_entity(DetectEntity)
    return "true"
end

Player_Feature["Modder Detection"] = menu.add_player_feature("Modder Detection", "action", Player_Parents["Advanced Detection"].id, function(f, pid)
    if lib.player.its_me(pid, f.name, f) then return end
    local Cage, Fish, Wade, Tow_Truck, Clone
    menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".spectate_player").on = true
    system.wait(500)
    menu.create_thread(function()
        Clone = advanced_modder_detection(f, pid, player.get_player_model(pid))
        Fish = advanced_modder_detection(f, pid, "A_C_Fish")
        Wade = advanced_modder_detection(f, pid, "IG_Wade")
    end)
    repeat
        system.wait()
    until Clone ~= nil and Fish ~= nil and Wade ~= nil
    if Clone == "true" or Fish == "true" or Wade == "true" then
        lua_notify(lib.player.get_player_name(pid) .. " is detected as a modder.", f.name)
        player.set_player_as_modder(pid, 1 << 0x00)
        menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".spectate_player").on = false
        return
    end
    menu.create_thread(function() Cage = advanced_modder_detection(f, pid, "prop_gold_cont_01") end)
    menu.create_thread(function() Tow_Truck = advanced_modder_detection(f, pid, "Towtruck") end)
    repeat
        system.wait()
    until Cage ~= nil and Tow_Truck ~= nil
    if Cage == "true" or Tow_Truck == "true" then
        lua_notify(lib.player.get_player_name(pid) .. " is detected as a modder.", f.name)
        player.set_player_as_modder(pid, 1 << 0x00)
    else
        lua_notify("No detection.", f.name)
    end
    menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".spectate_player").on = false
end)

Local_Parents["Local Prents"] = menu.add_integrated_feature_before(Jaune .. "Anarchy", "parent", menu.get_feature_by_hierarchy_key("local.player_options")).id
--Local_Parents["Local Prents"] = menu.add_feature("Anarchy", "parent", 0).id

Local_Feature[">> Go To Anarchy Tab <<"] = menu.add_feature(Jaune .. ">> Go To Anarchy Tab <<", "action", 0, function(f)
    local anarchy_children <const> = menu.get_feature_by_hierarchy_key("local._ff00ffff_anarchy").children
    Local_Feature["Anarchy Tab"] = menu.add_integrated_feature_before("Anarchy Tab", "action", anarchy_children[1], function(f) end)
    local menu_feat <const> = menu.get_feature_by_hierarchy_key("local._ff00ffff_anarchy.anarchy_tab")
    menu_feat.parent:toggle()
    menu_feat:select()
    menu.delete_feature(menu_feat.id)
end)

Local_Parents["Self"] = menu.add_feature("Self", "parent", Local_Parents["Local Prents"]).id

Local_Parents["Respawn"] = menu.add_feature("Respawn", "parent", Local_Parents["Self"]).id

Local_Feature["Fast"] = menu.add_feature("Fast", "toggle", Local_Parents["Respawn"], function(f)
    while f.on do
        if entity.is_entity_dead(player.player_ped()) then
            graphics.animpostfx_stop_all()
            lib.essentials.stop_sound()
            lib.globals.fast_respawn()
        end
        system.wait(10)
    end
end)

Local_Feature["On Death Coords"] = menu.add_feature("On Death Coords", "toggle", Local_Parents["Respawn"], function(f)
    local DeathCoords = nil
    while f.on do
        if entity.is_entity_dead(player.player_ped()) and not DeathCoords then
            DeathCoords = player.get_player_coords(player.player_id())
        end
        if not entity.is_entity_dead(player.player_ped()) and DeathCoords then
            entity.set_entity_coords_no_offset(player.player_ped(), DeathCoords)
            DeathCoords = nil
        end
        system.wait(10)
    end
end)

Local_Parents["Movement"] = menu.add_feature("Movement", "parent", Local_Parents["Self"]).id

Local_Feature["Fast Roll"] = menu.add_feature("Fast Roll", "toggle", Local_Parents["Movement"], function(f)
    while f.on do
        stats.stat_set_int(gameplay.get_hash_key("MP" .. lib.essentials.get_char_slot() .. "_SHOOTING_ABILITY"), 200, true)
        system.wait()
    end
end)

Local_Feature["Crouch"] = menu.add_feature("Crouch", "toggle", Local_Parents["Movement"], function(f)
    local crouch_active = false
    while f.on do
        controls.disable_control_action(0, lib.table.input_type["Duckl3"], true)
        if controls.is_disabled_control_just_pressed(0, lib.table.input_type["Duckl3"]) and not crouch_active then
            crouch_active = true
            while not streaming.has_anim_set_loaded("move_ped_crouched") do
                streaming.request_anim_set("move_ped_crouched")
                system.wait()
            end
            lib.natives.SET_PED_MOVEMENT_CLIPSET(player.player_ped(), 'move_ped_crouched', 0.5)
            lib.natives.SET_PED_STRAFE_CLIPSET(player.player_ped(), 'move_ped_crouched_strafing')
            streaming.remove_anim_dict('move_ped_crouched')
            system.wait(100)
        end
        if controls.is_disabled_control_just_pressed(0, lib.table.input_type["Duckl3"]) and crouch_active then
            crouch_active = false
            lib.natives.RESET_PED_MOVEMENT_CLIPSET(player.player_ped(), 0.5)
            lib.natives.RESET_PED_STRAFE_CLIPSET(player.player_ped())
            system.wait(100)
        end
        system.wait()
    end
    if not f.on then
        lib.natives.RESET_PED_MOVEMENT_CLIPSET(player.player_ped(), 0.5)
        lib.natives.RESET_PED_STRAFE_CLIPSET(player.player_ped())
        controls.disable_control_action(0, lib.table.input_type["Duckl3"], false)
    end
end)

Local_Feature["Walk Under Water"] = menu.add_feature("Walk Under Water", "toggle", Local_Parents["Movement"], function(f)
    while f.on do
        ped.set_ped_config_flag(player.player_ped(), 65, 0)
        if entity.is_entity_in_water(player.player_ped()) then
            entity.apply_force_to_entity(player.player_ped(), 1, 0, 0, -20, 0, 0, 0, false, false)
            local pos <const> = player.get_player_coords(player.player_id())
            local pos2 <const> = v3()
            pos2.x = pos.x
            pos2.y = pos.y
            pos2.z = lib.essentials.get_ground_z_under_water(v2(pos.x, pos.y))
            if pos:magnitude(pos2) > 10 then
                entity.apply_force_to_entity(player.player_ped(), 1, 0, 0, -75, 0, 0, 0, false, true)
            end
        end
        if lib.natives.GET_PED_CONFIG_FLAG(player.player_ped(), 168, true) then
            ped.clear_ped_tasks_immediately(player.player_ped())
        end
        system.wait()
    end
end)

Local_Feature["Phone Animations"] = menu.add_feature("Phone Animations", "toggle", Local_Parents["Movement"], function(f)
    while f.on do
        ped.set_ped_config_flag(player.player_ped(), 242, 0)
        ped.set_ped_config_flag(player.player_ped(), 243, 0)
        ped.set_ped_config_flag(player.player_ped(), 244, 0)
        system.wait(100)
    end
    if not f.on then
        ped.set_ped_config_flag(player.player_ped(), 242, 1)
        ped.set_ped_config_flag(player.player_ped(), 243, 1)
        ped.set_ped_config_flag(player.player_ped(), 244, 1)
    end
end)

Local_Feature["Flexible Legs"] = menu.add_feature("Flexible Legs", "toggle", Local_Parents["Movement"], function(f)
    while f.on do
        ped.set_ped_config_flag(player.player_ped(), 60, 0)
        system.wait()
    end
end)

Local_Feature["Reduced Collision"] = menu.add_feature("Reduced Collision", "toggle", Local_Parents["Movement"], function(f)
    while f.on do
        lib.natives.SET_PED_CAPSULE(player.player_ped(), 0.00001)
        system.wait()
    end
end)

Local_Feature["Swim In Air"] = menu.add_feature("Swim In Air", "toggle", Local_Parents["Movement"], function(f)
    while f.on do
        ped.set_ped_config_flag(player.player_ped(), 65, 1)
        system.wait()
    end
end)

Local_Feature["Block Aim Assist"] = menu.add_feature("Block Aim Assist", "toggle", Local_Parents["Self"], function(f)
    lib.natives.SET_PED_CAN_BE_TARGETTED(player.player_ped(), f.on == false)
end)

Local_Feature["Undetected Player Invincible"] = menu.add_feature("Undetected Player Invincible", "toggle", Local_Parents["Self"], function(f)
    while f.on do
        lib.natives.SET_ENTITY_ONLY_DAMAGED_BY_RELATIONSHIP_GROUP(player.player_ped(), true, 0)
        system.wait()
    end
    if not f.on then
        lib.natives.SET_ENTITY_ONLY_DAMAGED_BY_RELATIONSHIP_GROUP(player.player_ped(), false, 0)
    end
end)

Local_Parents["Weapons"] = menu.add_feature("Weapons", "parent", Local_Parents["Local Prents"]).id

Local_Parents["Weapon Loadout"] = menu.add_feature("Weapon Loadout", "parent", Local_Parents["Weapons"]).id

Local_Feature["Enable Give Weapons"] = menu.add_feature("Enable", "toggle", Local_Parents["Weapon Loadout"], function(f)
    while f.on do
        for name, hash in pairs(lib.table.weapon) do
            if Local_Feature["Weapon: " .. name].value == 1 then
                weapon.give_delayed_weapon_to_ped(player.player_ped(), gameplay.get_hash_key(hash), 0, false)
            elseif Local_Feature["Weapon: " .. name].value == 2 then
                weapon.remove_weapon_from_ped(player.player_ped(), gameplay.get_hash_key(hash))
            end
        end
        system.wait()
    end
end)

Local_Feature["Set All Weapons"] = menu.add_feature("Set All", "action_value_str", Local_Parents["Weapon Loadout"], function(f)
    for name, hash in pairs(lib.table.weapon) do
        if f.value == 0 then
            Local_Feature["Weapon: " .. name].value = 0
        elseif f.value == 1 then
            Local_Feature["Weapon: " .. name].value = 1
        elseif f.value == 2 then
            Local_Feature["Weapon: " .. name].value = 2
        end
    end
end)
Local_Feature["Set All Weapons"]:set_str_data({"Don't Override", "Equip", "Unequip"})

for _, eWeaponWheelSlot in ipairs(lib.essentials.sort_table_alphabetically("left", lib.table.eWeaponWheelSlot)) do
    Local_Parents["eWeaponWheelSlot" .. eWeaponWheelSlot.right] = menu.add_feature(eWeaponWheelSlot.left, "parent", Local_Parents["Weapon Loadout"]).id

    Local_Feature["Set All Weapons " .. eWeaponWheelSlot.left] = menu.add_feature("Set All " .. eWeaponWheelSlot.left, "action_value_str", Local_Parents["eWeaponWheelSlot" .. eWeaponWheelSlot.right], function(f)
        for name, hash in pairs(lib.table.weapon) do
            if weapon.get_weapon_weapon_wheel_slot(gameplay.get_hash_key(hash)) == eWeaponWheelSlot.right then
                if f.value == 0 then
                    Local_Feature["Weapon: " .. name].value = 0
                elseif f.value == 1 then
                    Local_Feature["Weapon: " .. name].value = 1
                elseif f.value == 2 then
                    Local_Feature["Weapon: " .. name].value = 2
                end
            end
        end
    end)
    Local_Feature["Set All Weapons " .. eWeaponWheelSlot.left]:set_str_data({"Don't Override", "Equip", "Unequip"})
end

for _, weapon_table in pairs(lib.essentials.sort_table_alphabetically("left", lib.table.weapon)) do
    Local_Feature["Weapon: " .. weapon_table.left] = menu.add_feature(weapon_table.left, "action_value_str", Local_Parents["eWeaponWheelSlot" .. weapon.get_weapon_weapon_wheel_slot(gameplay.get_hash_key(weapon_table.right))], function(f)
    end)
    Local_Feature["Weapon: " .. weapon_table.left]:set_str_data({"Don't Override", "Equip", "Unequip"})
end

Local_Feature["Lock-On To Players"] = menu.add_feature("Lock-On To Players", "toggle", Local_Parents["Weapons"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            lib.natives.ADD_PLAYER_TARGETABLE_ENTITY(player.player_id(), player.get_player_ped(pid))
            lib.natives.SET_ENTITY_IS_TARGET_PRIORITY(player.get_player_ped(pid), false, 400.0)
        end
        system.wait()
    end
    if not f.on then
        for pid in lib.player.list(false) do
            lib.natives.REMOVE_PLAYER_TARGETABLE_ENTITY(player.player_id(), player.get_player_ped(pid))
        end
    end
end)

Local_Feature["Delete Gun"] = menu.add_feature("Delete Gun", "toggle", Local_Parents["Weapons"], function(f)
    while f.on do
        local aiming_entity <const> = player.get_entity_player_is_aiming_at(player.player_id())
        if ped.is_ped_shooting(player.player_ped()) then
            if entity.is_entity_a_ped(aiming_entity) and ped.is_ped_in_any_vehicle(aiming_entity) then
                if not lib.globals.is_loading() then
                    local vehentity <const> = ped.get_vehicle_ped_is_using(aiming_entity)
                    ped.clear_ped_tasks_immediately(aiming_entity)
                    lib.entity.delete_entity_thread(vehentity)
                else
                    lua_notify_alert("You can't do it in story mode or in a loading screen.", f.name)
                end
            else
                if not lib.globals.is_loading() then
                    lib.entity.delete_entity_thread(aiming_entity)
                else
                    lua_notify_alert("You can't do it in story mode or in a loading screen.", f.name)
                end
            end
        end
        system.wait()
    end
end)

Local_Feature["Fast Swaps"] = menu.add_feature("Fast Swaps", "toggle", Local_Parents["Weapons"], function(f)
    while f.on do
        if ai.is_task_active(player.player_ped(), 56) then
            lib.natives.FORCE_PED_AI_AND_ANIMATION_UPDATE(player.player_ped())
        end
        system.wait()
    end
end)

Local_Parents["Vehicle"] = menu.add_feature("Vehicle", "parent", Local_Parents["Local Prents"]).id

Local_Parents["Super Drive"] = menu.add_feature("Super Drive", "parent", Local_Parents["Vehicle"]).id

Local_Feature["Super Drive Enable"] = menu.add_feature("Enable", "toggle", Local_Parents["Super Drive"], function(f)
    while f.on do
        if player.is_player_in_any_vehicle(player.player_id())
        and lib.player.is_player_driver(player.player_id())
        and lib.natives.IS_PED_SITTING_IN_ANY_VEHICLE(player.player_ped())
        and not lib.natives.IS_PED_IN_ANY_HELI(player.player_ped())
        and not lib.natives.IS_PED_IN_ANY_PLANE(player.player_ped())
        and not entity.is_entity_dead(player.player_ped())
        then
            if lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Up Only"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Veh Brake"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Veh Handbrake"]) then
                entity.apply_force_to_entity(player.player_vehicle(), 1, 0, Local_Feature["Super Drive Forward Speed"].value, Local_Feature["Apply Force When You Forward"].value, 0, 0, 0, true, false)
            end
            if lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Move Down Only"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Veh Accelerate"]) and not lib.natives.IS_CONTROL_PRESSED(0, lib.table.input_type["Veh Handbrake"]) then
                entity.apply_force_to_entity(player.player_vehicle(), 1, 0, Local_Feature["Super Drive Backward Speed"].value, Local_Feature["Apply Force When You Backward"].value, 0, 0, 0, true, false)
            end
        end
        system.wait()
    end
end)

Local_Feature["Super Drive Forward Speed"] = menu.add_feature("Forward Speed", "action_value_i", Local_Parents["Super Drive"], function(f)
    local input_stat, input_val = input.get("Forward Speed from " .. f.min .. " to " .. f.max, "", 7, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Super Drive Forward Speed"].max = 999999
Local_Feature["Super Drive Forward Speed"].min = 0
Local_Feature["Super Drive Forward Speed"].mod = 1
Local_Feature["Super Drive Forward Speed"].value = 1000

Local_Feature["Apply Force When You Forward"] = menu.add_feature("Apply Force When You Forward", "action_value_i", Local_Parents["Super Drive"], function(f)
    local input_stat, input_val = input.get("Apply Force When You Forward from " .. f.min .. " to " .. f.max, "", 7, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Apply Force When You Forward"].max = 999999
Local_Feature["Apply Force When You Forward"].min = -999999
Local_Feature["Apply Force When You Forward"].mod = 1
Local_Feature["Apply Force When You Forward"].value = 0

Local_Feature["Super Drive Backward Speed"] = menu.add_feature("Backward Speed", "action_value_i", Local_Parents["Super Drive"], function(f)
    local input_stat, input_val = input.get("Backward Speed from " .. f.min .. " to " .. f.max, "", 7, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Super Drive Backward Speed"].max = 0
Local_Feature["Super Drive Backward Speed"].min = -999999
Local_Feature["Super Drive Backward Speed"].mod = 1
Local_Feature["Super Drive Backward Speed"].value = -1000

Local_Feature["Apply Force When You Backward"] = menu.add_feature("Apply Force When You Backward", "action_value_i", Local_Parents["Super Drive"], function(f)
    local input_stat, input_val = input.get("Apply Force When You Backward from " .. f.min .. " to " .. f.max, "", 7, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Apply Force When You Backward"].max = 999999
Local_Feature["Apply Force When You Backward"].min = -999999
Local_Feature["Apply Force When You Backward"].mod = 1
Local_Feature["Apply Force When You Backward"].value = -300

Local_Feature["Undetected Vehicle Invincible"] = menu.add_feature("Undetected Vehicle Invincible", "toggle", Local_Parents["Vehicle"], function(f)
    while f.on do
        lib.natives.SET_ENTITY_ONLY_DAMAGED_BY_RELATIONSHIP_GROUP(player.player_vehicle(), true, 0)
        system.wait()
    end
    if not f.on then
        lib.natives.SET_ENTITY_ONLY_DAMAGED_BY_RELATIONSHIP_GROUP(player.player_vehicle(), false, 0)
    end
end)

Local_Feature["Set Vehicle Seat"] = menu.add_feature("Set Vehicle Seat", "action_value_str", Local_Parents["Vehicle"], function(f)
    if player.is_player_in_any_vehicle(player.player_id()) then
        ped.set_ped_into_vehicle(player.player_ped(), player.player_vehicle(), f.value - 1)
    end
end)

local Unreleased_Vehicles <const> = {

}

Local_Feature["Remove Detection By Other Menu"] = menu.add_feature("Remove Detection For Other Menu", "toggle", Local_Parents["Vehicle"], function(f)
    while f.on do
        if player.is_player_in_any_vehicle(player.player_id()) and not lib.essentials.table_contains(Unreleased_Vehicles, vehicle.get_vehicle_model(player.player_vehicle()), "right") then
            decorator.decor_remove(player.player_vehicle(), "MPBitset")
        end
        system.wait()
    end
end)

Local_Feature["Fast Enter / Exit"] = menu.add_feature("Fast Enter / Exit", "toggle", Local_Parents["Vehicle"], function(f)
    while f.on do
        if (ai.is_task_active(player.player_ped(), 160) or ai.is_task_active(player.player_ped(), 167) or ai.is_task_active(player.player_ped(), 165)) and not ai.is_task_active(player.player_ped(), 195) then
            lib.natives.FORCE_PED_AI_AND_ANIMATION_UPDATE(player.player_ped())
        end
        system.wait()
    end
end)

Local_Feature["Always Up"] = menu.add_feature("Always Up", "toggle", Local_Parents["Vehicle"], function(f)
    while f.on do
        local veh <const> = player.player_vehicle()
        if veh and not lib.natives.IS_VEHICLE_ON_ALL_WHEELS(veh) and lib.natives.GET_ENTITY_HEIGHT_ABOVE_GROUND(veh) < 100 then
            local pos <const> = entity.get_entity_coords(veh)
            local rot = entity.get_entity_rotation(veh)
            local rot_o = rot + v3(0, 0, 90)
            rot:transformRotToDir()
            rot_o:transformRotToDir()
            rot = rot * 2
            rot_o = rot_o
            local hit_forward, point_forward <const> = worldprobe.raycast(pos + rot, pos + rot - v3(0, 0, 150), 1, 0)
            local hit_backward, point_backward <const> = worldprobe.raycast(pos - rot, pos - rot - v3(0, 0, 150), 1, 0)
            local hit_left, point_left <const> = worldprobe.raycast(pos + rot_o, pos + rot_o - v3(0, 0, 150), 1, 0)
            local hit_right, point_right <const> = worldprobe.raycast(pos - rot_o, pos - rot_o - v3(0, 0, 150), 1, 0)
            local dx <const> = point_forward.x - point_backward.x
            local dy <const> = point_forward.y - point_backward.y
            local dz <const> = point_forward.z - point_backward.z
            local xrot <const> =  math.deg(math.atan(dz, math.sqrt(dx * dx + dy * dy + dz * dz)))
            local dx <const> = point_left.x - point_right.x
            local dy <const> = point_left.y - point_right.y
            local dz <const> = point_left.z - point_right.z
            local yrot <const> = math.deg(math.atan(dz, math.sqrt(dx * dx + dy * dy + dz * dz)))
            local rrot <const> = entity.get_entity_rotation(veh)
            lib.natives.SET_ENTITY_ROTATION(veh, v3(xrot or rrot.x, yrot or rrot.y, rrot.z))
        end
        system.wait()
    end
end)

Local_Feature["Bypass Anti Lock-On"] = menu.add_feature("Bypass Anti Lock-On", "toggle", Local_Parents["Vehicle"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if ped.is_ped_in_any_vehicle(player.get_player_ped(pid)) then
                lib.natives.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON_SYNCED(player.get_player_vehicle(pid), true)
            end
        end
        system.wait()
    end
end)

Local_Feature["Invisible Driving"] = menu.add_feature("Invisible Driving", "toggle", Local_Parents["Vehicle"], function(f)
    if f.on then
        if lib.natives.IS_PED_SITTING_IN_ANY_VEHICLE(player.player_ped()) then
            lib.natives.TASK_CLIMB(player.player_ped())
            entity.freeze_entity(player.player_ped(), true)
            menu.get_feature_by_hierarchy_key("local.player_options.invisible").on = true
            menu.get_feature_by_hierarchy_key("online.services.off_the_radar").on = true
        else
            lua_notify_alert("You are not in a vehicle.", f.name)
            f.on = false
            return
        end
    end
    while f.on do
        if not lib.natives.IS_PED_SITTING_IN_ANY_VEHICLE(player.player_ped()) then
            lua_notify_alert("You are not in a vehicle.", f.name)
            entity.freeze_entity(player.player_ped(), false)
            menu.get_feature_by_hierarchy_key("local.player_options.invisible").on = false
            menu.get_feature_by_hierarchy_key("online.services.off_the_radar").on = false
            entity.set_entity_visible(player.player_ped(), true)
            lib.natives.CLEAR_FOCUS()
            f.on = false
            return
        end
        lib.natives.SET_FOCUS_POS_AND_VEL(entity.get_entity_coords(player.player_vehicle()), 0.0, 0.0, 0.0)
        system.wait()
    end
    if not f.on then
        local carpos <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.player_vehicle(), -2.0, 0.0, 0.0)
        entity.freeze_entity(player.player_ped(), false)
        menu.get_feature_by_hierarchy_key("local.player_options.invisible").on = false
        menu.get_feature_by_hierarchy_key("online.services.off_the_radar").on = false
        entity.set_entity_visible(player.player_ped(), true)
        entity.set_entity_coords_no_offset(player.player_ped(), carpos)
        lib.natives.CLEAR_FOCUS()
    end
end)

Local_Parents["Online"] = menu.add_feature("Online", "parent", Local_Parents["Local Prents"]).id

Local_Parents["Multi Selection"] = menu.add_feature("Multi Selection", "parent", Local_Parents["Online"]).id

local selected_player <const> = {}

function multi_selection_executor(code, pid)
    for pid in lib.player.list(true) do
        if Local_Feature["Exclude What's Selected"].on then
            if not selected_player[pid] then
                code(pid)
            end
        else
            if selected_player[pid] then
                code(pid)
            end
        end
    end
end

Local_Feature["Kick"] = menu.add_feature("Kick", "action", Local_Parents["Multi Selection"], function(f)
    multi_selection_executor(function(pid)
        lib.player.smart_kick_player(pid)
    end)
end)

Local_Feature["Teleport Player To"] = menu.add_feature("Teleport Player To", "action_value_str", Local_Parents["Multi Selection"], function(f, pid)
    multi_selection_executor(function(pid)
        if f.value == 0 then
            menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".teleport.teleport_player_to_me").on = true
        elseif f.value == 1 then
            menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".teleport.teleport_player_to_waypoint").on = true
        end
    end)
end)
Local_Feature["Teleport Player To"]:set_str_data({"Me", "Waypoint"})

do
    local all_selected_player_rp = {}

    Local_Feature["Money + RP Drop"] = menu.add_feature("Money + RP Drop", "toggle", Local_Parents["Multi Selection"], function(f)
        while f.on do
            multi_selection_executor(function(pid)
                local random_rp_hash <const> = {"vw_prop_vw_colle_alien", "vw_prop_vw_colle_beast", "vw_prop_vw_colle_imporage", "vw_prop_vw_colle_pogo", "vw_prop_vw_colle_prbubble", "vw_prop_vw_colle_rsrcomm", "vw_prop_vw_colle_rsrgeneric", "vw_prop_vw_colle_sasquatch"}
                local random_hash <const> = gameplay.get_hash_key(random_rp_hash[math.random(1, #random_rp_hash)])
                lib.essentials.request_model(random_hash)
                local pos1 <const> = player.get_player_coords(pid) + v3(0, 0, Local_Feature["Money + RP Drop Settings Position Z Axis"].value)
                local RP_Ent <const> = lib.natives.CREATE_AMBIENT_PICKUP(gameplay.get_hash_key("PICKUP_CUSTOM_SCRIPT"), pos1, 0, 1, random_hash, false, true)
                system.wait()
                lib.entity.entity_owner_can_migrate(RP_Ent, false)
                entity.apply_force_to_entity(RP_Ent, 1, 0, 0, Local_Feature["Money + RP Drop Settings Apply Force"].value, 0, 0, 0, false, true)
                Money_Rp_Wait_Multi[RP_Ent] = 0
                All_RP_Ent_Multi[#All_RP_Ent_Multi + 1] = RP_Ent
                all_selected_player_rp = 0
                for i in lib.player.list(true) do
                    if Local_Feature["Exclude What's Selected"].on then
                        if not selected_player[i] then
                            all_selected_player_rp = all_selected_player_rp + 1
                        end
                    else
                        if selected_player[i] then
                            all_selected_player_rp = all_selected_player_rp + 1
                        end
                    end
                end
                system.wait(math.floor(Local_Feature["Money + RP Drop Settings Interval (in ms)"].value / all_selected_player_rp))
            end)
            system.wait()
        end
        if not f.on then
            for i, RP_Ent in ipairs(All_RP_Ent_Multi) do
                Money_Rp_Wait_Multi[RP_Ent] = 0
                lib.entity.delete_entity(RP_Ent)
            end
            All_RP_Ent_Multi = {}
        end
    end)
end

Local_Parents["Money + RP Drop Settings"] = menu.add_feature("Money + RP Drop Settings", "parent", Local_Parents["Multi Selection"]).id

Local_Feature["Money + RP Drop Settings Interval (in ms)"] = menu.add_feature("Interval (in ms)", "action_value_i", Local_Parents["Money + RP Drop Settings"], function(f)
    local input_stat, input_val = input.get("Interval (in ms) from " .. f.min .. " to " .. f.max, "", 5, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Money + RP Drop Settings Interval (in ms)"].max = 3000
Local_Feature["Money + RP Drop Settings Interval (in ms)"].min = 0
Local_Feature["Money + RP Drop Settings Interval (in ms)"].mod = 1
Local_Feature["Money + RP Drop Settings Interval (in ms)"].value = 1000

Local_Feature["Money + RP Drop Settings Position Z Axis"] = menu.add_feature("Z Axis", "action_value_f", Local_Parents["Money + RP Drop Settings"], function(f)
    local input_stat, input_val = input.get("Z Axis from " .. f.min .. " to " .. f.max, "", 5, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Money + RP Drop Settings Position Z Axis"].max = 10.00
Local_Feature["Money + RP Drop Settings Position Z Axis"].min = 0.00
Local_Feature["Money + RP Drop Settings Position Z Axis"].mod = 1.00
Local_Feature["Money + RP Drop Settings Position Z Axis"].value = 5.00

Local_Feature["Money + RP Drop Settings Apply Force"] = menu.add_feature("Apply Force", "action_value_i", Local_Parents["Money + RP Drop Settings"], function(f)
    local input_stat, input_val = input.get("Apply Force from " .. f.min .. " to " .. f.max, "", 4, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Money + RP Drop Settings Apply Force"].max = 0
Local_Feature["Money + RP Drop Settings Apply Force"].min = -100
Local_Feature["Money + RP Drop Settings Apply Force"].mod = 1
Local_Feature["Money + RP Drop Settings Apply Force"].value = -25

do
    local all_selected_player_card = {}

    Local_Feature["Money + Card Drop"] = menu.add_feature("Money + Card Drop", "toggle", Local_Parents["Multi Selection"], function(f)
        while f.on do
            multi_selection_executor(function(pid)
                lib.essentials.request_model(gameplay.get_hash_key("vw_prop_vw_lux_card_01a"))
                local pos1 <const> = player.get_player_coords(pid) + v3(0, 0, Local_Feature["Money + Card Drop Settings Position Z Axis"].value)
                local Card_Ent <const> = lib.natives.CREATE_AMBIENT_PICKUP(gameplay.get_hash_key("PICKUP_CUSTOM_SCRIPT"), pos1, 0, 1, gameplay.get_hash_key("vw_prop_vw_lux_card_01a"), false, true)
                system.wait()
                lib.entity.entity_owner_can_migrate(Card_Ent, false)
                entity.apply_force_to_entity(Card_Ent, 1, 0, 0, Local_Feature["Money + RP Drop Settings Apply Force"].value, 0, 0, 0, false, true)
                Card_Wait_Multi[Card_Ent] = 0
                All_Card_Ent_Multi[#All_Card_Ent_Multi + 1] = Card_Ent
                all_selected_player_card = 0
                for i in lib.player.list(true) do
                    if Local_Feature["Exclude What's Selected"].on then
                        if not selected_player[i] then
                            all_selected_player_card = all_selected_player_card + 1
                        end
                    else
                        if selected_player[i] then
                            all_selected_player_card = all_selected_player_card + 1
                        end
                    end
                end
                system.wait(math.floor(Local_Feature["Money + Card Drop Settings Interval (in ms)"].value / all_selected_player_card))
            end)
            system.wait()
        end
        if not f.on then
            for i, Card_Ent in ipairs(All_Card_Ent_Multi) do
                Card_Wait_Multi[Card_Ent] = 0
                lib.entity.delete_entity(Card_Ent)
            end
            All_Card_Ent_Multi = {}
        end
    end)
end

Local_Parents["Money + Card Drop Settings"] = menu.add_feature("Money + Card Drop Settings", "parent", Local_Parents["Multi Selection"]).id

Local_Feature["Money + Card Drop Settings Interval (in ms)"] = menu.add_feature("Interval (in ms)", "action_value_i", Local_Parents["Money + Card Drop Settings"], function(f)
    local input_stat, input_val = input.get("Interval (in ms) from " .. f.min .. " to " .. f.max, "", 5, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Money + Card Drop Settings Interval (in ms)"].max = 3000
Local_Feature["Money + Card Drop Settings Interval (in ms)"].min = 0
Local_Feature["Money + Card Drop Settings Interval (in ms)"].mod = 1
Local_Feature["Money + Card Drop Settings Interval (in ms)"].value = 1000

Local_Feature["Money + Card Drop Settings Position Z Axis"] = menu.add_feature("Z Axis", "action_value_f", Local_Parents["Money + Card Drop Settings"], function(f)
    local input_stat, input_val = input.get("Z Axis from " .. f.min .. " to " .. f.max, "", 5, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Money + Card Drop Settings Position Z Axis"].max = 10.00
Local_Feature["Money + Card Drop Settings Position Z Axis"].min = 0.00
Local_Feature["Money + Card Drop Settings Position Z Axis"].mod = 1.00
Local_Feature["Money + Card Drop Settings Position Z Axis"].value = 5.00

Local_Feature["Money + Card Drop Settings Apply Force"] = menu.add_feature("Apply Force", "action_value_i", Local_Parents["Money + Card Drop Settings"], function(f)
    local input_stat, input_val = input.get("Apply Force from " .. f.min .. " to " .. f.max, "", 4, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Money + Card Drop Settings Apply Force"].max = 0
Local_Feature["Money + Card Drop Settings Apply Force"].min = -100
Local_Feature["Money + Card Drop Settings Apply Force"].mod = 1
Local_Feature["Money + Card Drop Settings Apply Force"].value = -25

Local_Parents["Collectibles"] = menu.add_feature("Collectibles", "parent", Local_Parents["Multi Selection"]).id

Local_Feature["LD Organics Merchandise"] = menu.add_feature("LD Organics Merchandise", "action", Local_Parents["Collectibles"], function(f)
    multi_selection_executor(function(pid)
        lib.scriptevent.ld_organics_merchandise(pid)
    end)
end)

Local_Feature["Movie Props"] = menu.add_feature("Movie Props", "action", Local_Parents["Collectibles"], function(f)
    multi_selection_executor(function(pid)
        lib.scriptevent.movie_props(pid)
    end)
end)

Local_Feature["Snowmen"] = menu.add_feature("Snowmen", "action", Local_Parents["Collectibles"], function(f)
    multi_selection_executor(function(pid)
        lib.scriptevent.snowmen(pid)
    end)
end)

Local_Feature["Radio Antennas"] = menu.add_feature("Radio Antennas", "action", Local_Parents["Collectibles"], function(f)
    multi_selection_executor(function(pid)
        lib.scriptevent.radio_antennas(pid)
    end)
end)

Local_Feature["Media USBs"] = menu.add_feature("Media USBs", "action", Local_Parents["Collectibles"], function(f)
    multi_selection_executor(function(pid)
        lib.scriptevent.media_usb(pid)
    end)
end)

Local_Feature["G's Cache"] = menu.add_feature("G's Cache", "action", Local_Parents["Collectibles"], function(f)
    multi_selection_executor(function(pid)
        lib.scriptevent.g_s_cache(pid)
    end)
end)

Local_Feature["Buried Stashes (Daily)"] = menu.add_feature("Buried Stashes (Daily)", "action", Local_Parents["Collectibles"], function(f)
    multi_selection_executor(function(pid)
        lib.scriptevent.buried_stashes(pid)
    end)
end)

Local_Feature["Hidden Caches (Daily)"] = menu.add_feature("Hidden Caches (Daily)", "action", Local_Parents["Collectibles"], function(f)
    multi_selection_executor(function(pid)
        lib.scriptevent.hidden_caches(pid)
    end)
end)

Local_Feature["Junk Energy Skydives (Daily)"] = menu.add_feature("Junk Energy Skydives (Daily)", "action", Local_Parents["Collectibles"], function(f)
    multi_selection_executor(function(pid)
        lib.scriptevent.junk_energy_skydives(pid)
    end)
end)

Local_Feature["Shipwrecks (Daily)"] = menu.add_feature("Shipwrecks (Daily)", "action", Local_Parents["Collectibles"], function(f)
    multi_selection_executor(function(pid)
        lib.scriptevent.shipwrecks(pid)
    end)
end)

Local_Feature["Treasure Chests (Daily)"] = menu.add_feature("Treasure Chests (Daily)", "action", Local_Parents["Collectibles"], function(f)
    multi_selection_executor(function(pid)
        lib.scriptevent.treasure_chests(pid)
    end)
end)

Local_Feature["Jack O' Lanterns (Daily)"] = menu.add_feature("Jack O' Lanterns (Daily)", "action", Local_Parents["Collectibles"], function(f)
    multi_selection_executor(function(pid)
        lib.scriptevent.jack_o_lanterns(pid)
    end)
end)

Local_Feature["Exclude What's Selected"] = menu.add_feature("Exclude What's Selected", "toggle", Local_Parents["Multi Selection"], function(f) end)

Local_Feature["Multi Selection Separation"] = menu.add_feature("", "action", Local_Parents["Multi Selection"], function(f)end)

for pid = 0, 31 do
    selected_player[pid] = false
    multi_pid[pid] = menu.add_feature(pid, "toggle", Local_Parents["Multi Selection"], function(f)
        if f.on then
            selected_player[pid] = true
        else
            selected_player[pid] = false
        end
    end)
    multi_pid[pid].hidden = true
end

Local_Parents["Chat"] = menu.add_feature("Chat", "parent", Local_Parents["Online"]).id

Local_Feature["Announce Crash Protection"] = menu.add_feature("Announce Crash Protection", "value_str", Local_Parents["Chat"], function(f)
    local log_2take1, Treated_Line, pids
    if f.on then
        log_2take1 = io.open(Log_File, "r")
        log_2take1:seek("end")
        Treated_Line = {}
        Listeners["Announce Crash Protection"] = event.add_event_listener("modder", function(modder)
            if string.find(player.get_modder_flag_text(modder.flag):lower(), "crash") then
                local menu_names <const> = {"Anarchy", "2Take1", "Stand", "Cherax", "X-Force", "Nightfall", "Kiddion"}
                local menu_name <const> = menu_names[f.value + 1]
                network.send_chat_message(lib.player.get_player_name(modder.player) .. " failed to crash a " .. menu_name .. " user.", false)
            end
        end)
    end
    while f.on do
        local line <const> = log_2take1:read("*line")
        if line and not Treated_Line[line] and line:find("Crash Protection") then
            pids = nil
            for pid in lib.player.list(false) do
                if line:find(lib.player.get_player_name(pid)) then
                    pids = pid
                end
            end
            if pids then
                local menu_names <const> = {"Anarchy", "2Take1", "Stand", "Cherax", "X-Force", "Nightfall", "Kiddion"}
                local menu_name <const> = menu_names[f.value + 1]
                network.send_chat_message(lib.player.get_player_name(pids) .. " failed to crash a " .. menu_name .. " user.", false)
            end
            Treated_Line[line] = true
        end
        system.wait()
    end
    if not f.on then
        log_2take1:close()
        event.remove_event_listener("modder", Listeners["Announce Crash Protection"])
    end
end)
Local_Feature["Announce Crash Protection"]:set_str_data({"Anarchy User", "2Take1 User", "Stand User", "Cherax User", "X-Force User", "Nightfall User", "Kiddion User"})

Local_Feature["Announce Modder Detection"] = menu.add_feature("Announce Modder Detection", "toggle", Local_Parents["Chat"], function(f)
    if f.on then
        Listeners["Announce Crash Detection"] = event.add_event_listener("modder", function(modder)
            network.send_chat_message("Detected " .. lib.player.get_player_name(modder.player) .. " as modder with the reason " .. player.get_modder_flag_text(modder.flag) .. ".", false)
        end)
    end
    if not f.on then
        event.remove_event_listener("modder", Listeners["Announce Crash Detection"])
    end
end)

Local_Feature["Chat Spammer"] = menu.add_feature("Chat Spammer", "value_str", Local_Parents["Chat"], function(f)
    if f.on then
        local messages <const> = {}
        Listeners["Chat Spammer"] = event.add_event_listener("chat", function(chat)
            if chat.player == player.player_id() then
                return
            end
            local message <const> = messages[chat.player]
            if not message then
                messages[chat.player] = {
                    ["count"] = 1,
                    ["body"] = chat.body
                }
                return
            end
            if message.body ~= chat.body then
                message.count = 1
                message.body = chat.body
                return
            end
            message.count = message.count + 1
            if message.count >= 3 then
                if f.value == 0 then
                    lua_notify("Kick " .. lib.player.get_player_name(chat.player) .. " for sending the same message.", f.name)
                    messages[chat.player] = nil
                    lib.player.smart_kick_player(chat.player)
                    lib.player.block_chat(chat.player, 3000)
                elseif f.value == 1 then
                    lua_notify("All messages from " .. lib.player.get_player_name(chat.player) .. " are blocked for 10s.", f.name)
                    messages[chat.player] = nil
                    lib.player.block_chat(chat.player, 10000)
                elseif f.value == 2 then
                    lua_notify(lib.player.get_player_name(chat.player) .. " sending the same message.", f.name)
                    messages[chat.player] = nil
                end
            end
        end)
    end
    if not f.on then
        event.remove_event_listener("chat", Listeners["Chat Spammer"])
    end
end)
Local_Feature["Chat Spammer"]:set_str_data({"Kick", "Block", "Notif"})

Local_Feature["Advertisement"] = menu.add_feature("Advertisement", "value_str", Local_Parents["Chat"], function(f)
    if f.on then
        Listeners["Advertisement"] = event.add_event_listener("chat", function(chat)
            local message_filter <const> = chat.body:gsub("З", "3")
            :gsub("А", "A")
            :gsub("а", "a")
            :gsub("В", "B")
            :gsub("С", "C")
            :gsub("с", "c")
            :gsub("Е", "E")
            :gsub("е", "e")
            :gsub("Н", "H")
            :gsub("К", "K")
            :gsub("М", "M")
            :gsub("О", "O")
            :gsub("о", "o")
            :gsub("Р", "P")
            :gsub("р", "p")
            :gsub("Т", "T")
            :gsub("Х", "X")
            :gsub("х", "x")
            :gsub("у", "y")
            for i, advertising in pairs(lib.table.advertising) do
                if string.lower(message_filter):find(string.lower(advertising)) and chat.player ~= player.player_id() then
                    if f.value == 0 then
                        lua_notify("Kick " .. lib.player.get_player_name(chat.player) .. " for sending an advertisement.", f.name)
                        lib.player.smart_kick_player(chat.player)
                        lib.player.block_chat(chat.player, 3000)
                    elseif f.value == 1 then
                        lua_notify("All messages from " .. lib.player.get_player_name(chat.player) .. " are blocked for 60s.", f.name)
                        lib.player.block_chat(chat.player, 60000)
                    elseif f.value == 2 then
                        lua_notify(lib.player.get_player_name(chat.player) .. " sending an advertisement.", f.name)
                    end
                end
            end
        end)
    end
    if not f.on then
        event.remove_event_listener("chat", Listeners["Advertisement"])
    end
end)
Local_Feature["Advertisement"]:set_str_data({"Kick", "Block", "Notif"})

Local_Feature["Bypassed Message Filter"] = menu.add_feature("Bypassed Message Filter", "value_str", Local_Parents["Chat"], function(f)
    if f.on then
        Listeners["Bypassed Message Filter"] = event.add_event_listener("chat", function(chat)
            local message_filter <const> = chat.body:gsub("З", "3")
            :gsub("А", "A")
            :gsub("а", "a")
            :gsub("В", "B")
            :gsub("С", "C")
            :gsub("с", "c")
            :gsub("Е", "E")
            :gsub("е", "e")
            :gsub("Н", "H")
            :gsub("К", "K")
            :gsub("М", "M")
            :gsub("О", "O")
            :gsub("о", "o")
            :gsub("Р", "P")
            :gsub("р", "p")
            :gsub("Т", "T")
            :gsub("Х", "X")
            :gsub("х", "x")
            :gsub("у", "y")
            for i, profanities in pairs(lib.table.message_filter) do
                if string.lower(message_filter):find(string.lower(profanities)) then
                    if f.value == 0 then
                        lua_notify("Kick " .. lib.player.get_player_name(chat.player) .. " because message filter is bypassed.", f.name)
                        lib.player.smart_kick_player(chat.player)
                        lib.player.block_chat(chat.player, 3000)
                        player.set_player_as_modder(chat.sender, ProtectionFlags["Bypassed Message Filter"])
                    elseif f.value == 1 then
                        lua_notify("All messages from " .. lib.player.get_player_name(chat.player) .. " are blocked for 10s.", f.name)

                        lib.player.block_chat(chat.player, 10000)
                        player.set_player_as_modder(chat.sender, ProtectionFlags["Bypassed Message Filter"])
                    elseif f.value == 2 then
                        lua_notify(lib.player.get_player_name(chat.player) .. " bypassed message filter.", f.name)
                    end
                end
            end
        end)
    end
    if not f.on then
        event.remove_event_listener("chat", Listeners["Bypassed Message Filter"])
    end
end)
Local_Feature["Bypassed Message Filter"]:set_str_data({"Kick", "Block", "Notif"})

Local_Parents["Session Advertising"] = menu.add_feature("Session Advertising", "parent", Local_Parents["Online"]).id

Local_Feature["Send Advertising Chat"] = menu.add_feature("Send Advertising Chat", "toggle", Local_Parents["Session Advertising"], function(f)
    while f.on do
        network.send_chat_message("Anarchy on top\nBest Lua for 2Take1\nHere: discord.gg/GfmmeQNc93", false)
        system.wait(2000)
    end
end)

Local_Feature["Send Advertising Job"] = menu.add_feature("Send Advertising Job", "toggle", Local_Parents["Session Advertising"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            lib.scriptevent.job_message(pid, "<font size='15'>~h~" .. All_Advertising_Job[math.random(1, #All_Advertising_Job)] .. "<font size='0'>")
        end
        system.wait(2000)
    end
end)

Local_Feature["Send Advertising SMS"] = menu.add_feature("Send Advertising SMS", "toggle", Local_Parents["Session Advertising"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            lib.player.send_sms(pid, "Anarchy on top ^^                            Best Lua for 2Take1")
        end
        system.wait(2000)
    end
end)

Local_Feature["Send Advertising Friend Request"] = menu.add_feature("Send Advertising Friend Request", "action", Local_Parents["Session Advertising"], function(f)
    for pid in lib.player.list(false) do
        network.add_friend(player.get_player_scid(pid), "Anarchy on top\nBest Lua for 2Take1\nDiscord ; GfmmeQNc93")
    end
end)

Local_Parents["Removal"] = menu.add_feature("Removal", "parent", Local_Parents["Online"]).id

Local_Feature["Ultra Lag Session"] = menu.add_feature("Ultra Lag Session", "toggle", Local_Parents["Removal"], function(f)
    LagPlayer = {}
    for i = 1, 23 do
        LagPlayer[i] = lib.entity.spawn_entity(gameplay.get_hash_key("patrolboat"), v3(10000, 10000, 2600), 0, false, true, false, false, false, true)
        lib.entity.sync_for_all_player(LagPlayer[i])
        entity.set_entity_gravity(LagPlayer[i], false)
        system.wait(100)
    end
    system.wait(5000)
    for i = 24, 31 do
        LagPlayer[i] = lib.entity.spawn_entity(gameplay.get_hash_key("tug"), v3(10000, 10000, 2600), 0, false, true, false, false, false, true)
        lib.entity.sync_for_all_player(LagPlayer[i])
        entity.set_entity_gravity(LagPlayer[i], false)
    end
    NtwrkJetski = lib.entity.spawn_entity(gameplay.get_hash_key("A_M_Y_Jetski_01"), v3(10000, 10000, 2600), 0, false, true, false, true, false, false)
    lua_notify(lib.player.get_player_name(pid).." received the ultra lag well.", f.name)
    while f.on do
        for i in ipairs(LagPlayer) do
            entity.attach_entity_to_entity(LagPlayer[i], NtwrkJetski, 0, v3(0, 0, 0), v3(math.random(0, 360), math.random(0, 360), math.random(0, 360)), false, true, false, 0, true)
        end
        system.wait()
    end
    for i in ipairs(LagPlayer) do
        lib.entity.delete_entity(LagPlayer[i])
    end
    lib.entity.delete_entity(NtwrkJetski)
end)

Local_Feature["Sound Crash"] = menu.add_feature("Sound Crash", "action", Local_Parents["Removal"], function(f)
    local time <const> = utils.time_ms() + 2500
    while time > utils.time_ms() do
        for i = 1, 10 do
            audio.play_sound_from_coord(-1, "Event_Message_Purple", v3(0, 0, 0), "GTAO_FM_Events_Soundset", true, 0, false)
        end
        system.wait()
    end
end)

function Ruiner_Crash()
    for i = 1, 5 do
        local ruiner <const> = lib.entity.spawn_entity(gameplay.get_hash_key("ruiner2"), v3(0, 0, 2600), 0, false, true, false, false, false, true)
        local ped1 <const> = lib.entity.spawn_entity(gameplay.get_hash_key("A_M_M_TrampBeac_01"), v3(0, 0, 2600), 0, false, true, false, false, false, true)
        ped.set_ped_into_vehicle(ped1, ruiner, -1)
        vehicle.set_vehicle_parachute_model(ruiner, gameplay.get_hash_key("prop_air_windsock"))
        system.wait()
        vehicle.set_vehicle_parachute_active(ruiner, true)
        system.wait(500)
        lib.entity.delete_entity(ruiner)
        lib.entity.delete_entity(ped1)
    end
end

Local_Feature["Ruiner Crash"] = menu.add_feature("Ruiner Crash", "action", Local_Parents["Removal"], function(f)
    Ruiner_Crash()
    lua_notify("The session received the crash well.", f.name)
end)

function Parachute_Crash()
    local save <const> = player.get_player_coords(player.player_id())
    entity.set_entity_coords_no_offset(player.player_ped(), v3(0, 0, 2600))
    weapon.give_delayed_weapon_to_ped(player.player_ped(), gameplay.get_hash_key("GADGET_PARACHUTE"), 0, true)
    player.set_player_parachute_model(player.player_id(), gameplay.get_hash_key("prop_air_windsock"))
    lib.natives.SET_PLAYER_HAS_RESERVE_PARACHUTE(player.player_ped())
    lib.natives.SET_PLAYER_RESERVE_PARACHUTE_MODEL_OVERRIDE(player.player_id(), gameplay.get_hash_key("prop_air_windsock"))
    ai.task_sky_dive(player.player_ped(), true)
    system.wait()
    lib.natives.FORCE_PED_TO_OPEN_PARACHUTE(player.player_ped())
    local time <const> = utils.time_ms() + 5000
    repeat system.wait() until lib.natives.GET_PED_PARACHUTE_STATE(player.player_ped()) == 2 or time < utils.time_ms()
    ai.task_sky_dive(player.player_ped(), true)
    system.wait()
    lib.natives.FORCE_PED_TO_OPEN_PARACHUTE(player.player_ped())
    repeat system.wait() until lib.natives.GET_PED_PARACHUTE_STATE(player.player_ped()) == 2 or time < utils.time_ms()
    ped.clear_ped_tasks_immediately(player.player_ped())
    system.wait()
    lib.natives.CLEAR_PLAYER_PARACHUTE_MODEL_OVERRIDE(player.player_id())
    lib.natives.CLEAR_PLAYER_RESERVE_PARACHUTE_MODEL_OVERRIDE(player.player_id())
    entity.set_entity_coords_no_offset(player.player_ped(), save)
end

Local_Feature["Parachute Crash"] = menu.add_feature("Parachute Crash", "action", Local_Parents["Removal"], function(f)
    Parachute_Crash()
    lua_notify("The session received the crash well.", f.name)
end)

Local_Parents["Need Stand"] = menu.add_feature("Need Stand", "parent", Local_Parents["Removal"], function(f)
    lua_notify_alert("Your game will crash if you don't use the stand mod menu.", "Stand User")
end).id

function Backpack_Crash()
    for i = 1, 5 do
        weapon.give_delayed_weapon_to_ped(player.player_ped(), gameplay.get_hash_key("GADGET_PARACHUTE"), 0, true)
        lib.natives.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(player.player_id(), gameplay.get_hash_key("urbanweeds02_l1"))
        ai.task_sky_dive(player.player_ped(), true)
        system.wait()
        ped.clear_ped_tasks_immediately(player.player_ped())
        weapon.give_delayed_weapon_to_ped(player.player_ped(), gameplay.get_hash_key("GADGET_PARACHUTE"), 0, true)
        system.wait(1000)
        lib.natives.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(player.player_id())
        ped.clear_ped_tasks_immediately(player.player_ped())
        ped.set_ped_health(player.player_ped(), 0)
        ped.resurrect_ped(player.player_ped())
    end
end

Local_Feature["Backpack Crash"] = menu.add_feature("Backpack Crash", "action", Local_Parents["Need Stand"], function(f)
    Backpack_Crash()
    lua_notify("The session received the crash well.", f.name)
end)

Local_Feature["Rope Crash (Break Session)"] = menu.add_feature("Rope Crash (Break Session)" , "action", Local_Parents["Need Stand"], function(f)
    local time <const> = utils.time_ms() + 1000
    while not rope.rope_are_textures_loaded() and time > utils.time_ms() do
        rope.rope_load_textures()
        system.wait()
    end
    local carc <const> = lib.entity.spawn_entity(gameplay.get_hash_key("bullet"), player.get_player_coords(player.player_id()) + v3(0, 0, 10), 0, false, true, false, true, false, true)
    local pedc <const> = lib.entity.spawn_entity(gameplay.get_hash_key("A_M_Y_BusiCas_01"), player.get_player_coords(player.player_id()) + v3(0, 0, 10), 0, false, true, false, true, false, true)
    local ropec <const> = rope.add_rope(player.get_player_coords(player.player_id()) + v3(0, 0, 10), v3(0, 0, 0), 9999999999, 1, 1, 1, 1, true, true, true, 1.0, true)
    rope.attach_entities_to_rope(ropec, carc, pedc, entity.get_entity_coords(carc), entity.get_entity_coords(pedc), 2, 0, 0, "Center", "Center")
    system.wait(250)
    local time <const> = utils.time_ms() + 1000
    while rope.does_rope_exist(ropec) and time > utils.time_ms() do
        rope.delete_rope(ropec)
        system.wait()
    end
    lib.entity.delete_entity(carc)
    lib.entity.delete_entity(pedc)
    lua_notify("The session received the crash well.", f.name)
end)

Local_Parents["Open Extra Slots"] = menu.add_feature("Open Extra Slots", "parent", Local_Parents["Online"]).id

Local_Feature["Slots Info"] = menu.add_feature("Slots Info", "action", Local_Parents["Open Extra Slots"], function(f)
    local All_Players <const> = player.player_count()
    local Free_Slots_Player <const> = lib.natives.NETWORK_SESSION_GET_MATCHMAKING_GROUP_FREE(0)
    local Free_Slots_SCTV <const> = lib.natives.NETWORK_SESSION_GET_MATCHMAKING_GROUP_FREE(4)
    lua_notify("All Players: " .. All_Players .. "\nFree Slots: " .. Free_Slots_Player .. "\nFree SCTV: " .. Free_Slots_SCTV, f.name)
end)

Local_Feature["Host / 32 Players"] = menu.add_feature("Host / 32 Players", "toggle", Local_Parents["Open Extra Slots"], function(f)
    while f.on do
        if network.network_is_host() then
            lib.natives.NETWORK_SESSION_SET_MATCHMAKING_GROUP_MAX(0, 32)
        else
            lib.natives.NETWORK_SESSION_SET_MATCHMAKING_GROUP_MAX(0, 30)
        end
        system.wait()
    end
    if not f.on then
        lib.natives.NETWORK_SESSION_SET_MATCHMAKING_GROUP_MAX(0, 30)
    end
end)

Local_Feature["Host / 0 SCTV"] = menu.add_feature("Host / 0 SCTV", "toggle", Local_Parents["Open Extra Slots"], function(f)
    while f.on do
        if network.network_is_host() then
            lib.natives.NETWORK_SESSION_SET_MATCHMAKING_GROUP_MAX(4, 0)
        else
            lib.natives.NETWORK_SESSION_SET_MATCHMAKING_GROUP_MAX(4, 2)
        end
        system.wait()
    end
    if not f.on then
        lib.natives.NETWORK_SESSION_SET_MATCHMAKING_GROUP_MAX(4, 2)
    end
end)

Local_Feature["No Host / 31 Players"] = menu.add_feature("No Host / 31 Players", "toggle", Local_Parents["Open Extra Slots"], function(f)
    while f.on do
        if not network.network_is_host() then
            lib.natives.NETWORK_SESSION_SET_MATCHMAKING_GROUP(4)
        else
            lib.natives.NETWORK_SESSION_SET_MATCHMAKING_GROUP(0)
        end
        system.wait()
    end
    if not f.on then
        lib.natives.NETWORK_SESSION_SET_MATCHMAKING_GROUP(0)
    end
end)

Local_Parents["Notify Activity"] = menu.add_feature("Notify Activity", "parent", Local_Parents["Online"]).id

Local_Feature["Notify Host Migration"] = menu.add_feature("Host Migration", "toggle", Local_Parents["Notify Activity"], function(f)
    local sh_is_loading
    local host_1 = player.get_host()
    while f.on do
        if lib.globals.is_loading() and not sh_is_loading then
            system.wait(100)
            sh_is_loading = true
            host_1 = -1
            repeat system.wait() until player.get_host() ~= -1
        end
        if not lib.globals.is_loading() then
            sh_is_loading = false
        end
        local host_2 <const> = player.get_host()
        if host_1 ~= host_2 and host_2 ~= -1 then
            lua_notify(Jaune..lib.player.get_player_name(host_2)..BleuClair .. " is the host.", f.name)
            host_1 = host_2
        end
        system.wait(100)
    end
end)

Local_Feature["Notify Script Host Migration"] = menu.add_feature("Script Host Migration", "toggle", Local_Parents["Notify Activity"], function(f)
    local sh_is_loading
    local script_host_1 = script.get_host_of_this_script()
    while f.on do
        if lib.globals.is_loading() and not sh_is_loading then
            system.wait(100)
            sh_is_loading = true
            script_host_1 = -1
            repeat system.wait() until script.get_host_of_this_script() ~= -1
        end
        if not lib.globals.is_loading() then
            sh_is_loading = false
        end
        local script_host_2 = script.get_host_of_this_script()
        if script_host_1 ~= script_host_2 and script_host_2 ~= -1 then
            lua_notify(Jaune..lib.player.get_player_name(script_host_2)..BleuClair .. " is the script host.", f.name)
            script_host_1 = script_host_2
        end
        system.wait(100)
    end
end)

Local_Feature["Notify Using Guided Missile"] = menu.add_feature("Using Guided Missile", "toggle", Local_Parents["Notify Activity"], function(f)
    local IsUsingGuidedMissile <const> = {}
    if f.on then
        for pid = 0, 31 do
            IsUsingGuidedMissile[pid] = false
        end
    end
    while f.on do
        for pid in lib.player.list(false) do
            if lib.globals.is_using_guided_missile(pid) then
                if not IsUsingGuidedMissile[pid] then
                    lua_notify(Jaune..lib.player.get_player_name(pid)..BleuClair .. " is using an guided missile.", f.name)
                end
                IsUsingGuidedMissile[pid] = true
            else
                if IsUsingGuidedMissile[pid] then
                    lua_notify(Jaune..lib.player.get_player_name(pid)..BleuClair .. " is no longer using an guided missile.", f.name)
                end
                IsUsingGuidedMissile[pid] = false
            end
        end
        local objects = object.get_all_objects()
        for i = 1, #objects do
            if entity.get_entity_model_hash(objects[i]) == gameplay.get_hash_key("h4_prop_h4_airmissile_01a") then
                if ui.get_blip_from_entity(objects[i]) == 0 then
                    local blip <const> = ui.add_blip_for_entity(objects[i])
                    ui.set_blip_sprite(blip, 548)
                    ui.set_blip_colour(blip, 1)
                end
            end
        end
        system.wait(1000)
    end
end)

Local_Feature["Notify Using Orbital Cannon"] = menu.add_feature("Using Orbital Cannon", "toggle", Local_Parents["Notify Activity"], function(f)
    local IsInOrbitalCannonRoom <const> = {}
    local IsUsingOrbitalCannon <const> = {}
    if f.on then
        for pid = 0, 31 do
            IsInOrbitalCannonRoom[pid] = false
            IsUsingOrbitalCannon[pid] = false
        end
    end
    while f.on do
        for pid in lib.player.list(false) do
            if player.get_player_coords(pid):magnitude(v3(329.02, 4828.75, -58.55)) < 8 then
                if not IsInOrbitalCannonRoom[pid] then
                    lua_notify(Jaune..lib.player.get_player_name(pid)..BleuClair .. " entered the orbital cannon room.", f.name)
                end
                IsInOrbitalCannonRoom[pid] = true
            else
                if IsInOrbitalCannonRoom[pid] then
                    lua_notify(Jaune..lib.player.get_player_name(pid)..BleuClair .. " left the orbital cannon room.", f.name)
                end
                IsInOrbitalCannonRoom[pid] = false
            end
            if lib.globals.is_using_orbital_cannon(pid) then
                if not IsUsingOrbitalCannon[pid] then
                    lua_notify(Jaune..lib.player.get_player_name(pid)..BleuClair .. " is using an orbital cannon.", f.name)
                end
                IsUsingOrbitalCannon[pid] = true
            else
                if IsUsingOrbitalCannon[pid] then
                    lua_notify(Jaune..lib.player.get_player_name(pid)..BleuClair .. " is no longer using an orbital cannon.", f.name)
                end
                IsUsingOrbitalCannon[pid] = false
            end
        end
        system.wait(100)
    end
end)

Local_Feature["Notify Player Connection"] = menu.add_feature("Player Connection", "toggle", Local_Parents["Notify Activity"], function(f)
    local YouSplitConnection = {}
    local SplitConnectionWithYou = {}
    while f.on do
        if not lib.globals.is_loading() then
            for pid in lib.player.list(false) do
                if not YouSplitConnection[pid] and lib.natives.NETWORK_GET_AVERAGE_PING(pid) > 99999 then
                    lua_notify("You split syncs with " .. lib.player.get_player_name(pid) .. ".", f.name)
                    YouSplitConnection[pid] = true
                elseif YouSplitConnection[pid] and lib.natives.NETWORK_GET_AVERAGE_PING(pid) < 99999 and player.get_player_coords(pid).x < 10700 and player.get_player_coords(pid).y < 10700 and player.get_player_coords(pid).x > -10700 and player.get_player_coords(pid).y > -10700 then
                    lua_notify("You regained syncs with " .. lib.player.get_player_name(pid) .. ".", f.name)
                    YouSplitConnection[pid] = false
                end
                if not SplitConnectionWithYou[pid] and lib.natives.NETWORK_GET_AVERAGE_PACKET_LOSS(pid) == 1.0 then
                    lua_notify(lib.player.get_player_name(pid) .. " lost connection with you.", f.name)
                    SplitConnectionWithYou[pid] = true
                elseif SplitConnectionWithYou[pid] and lib.natives.NETWORK_GET_AVERAGE_PACKET_LOSS(pid) <= 0.25 then
                    lua_notify(lib.player.get_player_name(pid) .. " regained connection with you.", f.name)
                    SplitConnectionWithYou[pid] = false
                end
            end
        else
            YouSplitConnection = {}
            SplitConnectionWithYou = {}
        end
        system.wait(100)
    end
end)

Local_Feature["Notify Typing"] = menu.add_feature("Typing", "toggle", Local_Parents["Notify Activity"], function(f)
    if f.on then
        for pid = 0, 31 do
            Player_Typing[pid] = false
        end
    end
    while f.on do
        if not lib.globals.is_loading() then
            for pid in lib.player.list(false) do
                if lib.globals.is_player_typing(pid) and not Player_Typing[pid] then
                    lua_notify(Jaune..lib.player.get_player_name(pid)..BleuClair .. " started typing.", f.name)
                    Player_Typing[pid] = true
                end
                if not lib.globals.is_player_typing(pid) and Player_Typing[pid] then
                    lua_notify(Jaune..lib.player.get_player_name(pid)..BleuClair .. " stopped typing.", f.name)
                    Player_Typing[pid] = false
                end
            end
        end
        system.wait(10)
    end
    if not f.on then
        for pid = 0, 31 do
            Player_Typing[pid] = false
        end
    end
end)

Local_Feature["Notify Talking"] = menu.add_feature("Talking", "toggle", Local_Parents["Notify Activity"], function(f)
    if f.on then
        for pid = 0, 31 do
            Player_Talking[pid] = false
        end
    end
    while f.on do
        if not lib.globals.is_loading() then
            for pid in lib.player.list(false) do
                if lib.natives.NETWORK_IS_PLAYER_TALKING(pid) and not Player_Talking[pid] then
                    lua_notify(Jaune..lib.player.get_player_name(pid)..BleuClair .. " started talking.", f.name)
                    Player_Talking[pid] = true
                end
                if not lib.natives.NETWORK_IS_PLAYER_TALKING(pid) and Player_Talking[pid] then
                    lua_notify(Jaune..lib.player.get_player_name(pid)..BleuClair .. " stopped talking.", f.name)
                    Player_Talking[pid] = false
                end
            end
        end
        system.wait(10)
    end
    if not f.on then
        for pid = 0, 31 do
            Player_Talking[pid] = false
        end
    end
end)

Local_Parents["Money Manager"] = menu.add_feature("Money Manager", "parent", Local_Parents["Online"]).id

--[[
Local_Parents["Nightclub"] = menu.add_feature("Nightclub", "parent", Local_Parents["Money Manager"]).id

Local_Feature["Teleport To Safe"] = menu.add_feature("Teleport To Safe", "toggle", Local_Parents["Nightclub"], function(f)
    local safe_rotation
    if f.on then
        safe_rotation = 0
    end
    while f.on do
        if lib.globals.get_interior_player_is_in(player.player_id()) ~= 271617 and lib.natives.IS_PLAYER_CONTROL_ON(player.player_id()) then
            menu.get_feature_by_hierarchy_key("local.teleport.business.nightclub").on = true
            safe_rotation = safe_rotation + 10
            lib.natives.SET_ENTITY_ROTATION(player.player_ped(), v3(0, 0, safe_rotation))
        end
        if lib.globals.get_interior_player_is_in(player.player_id()) == 271617 and lib.natives.IS_PLAYER_CONTROL_ON(player.player_id()) then
            entity.set_entity_coords_no_offset(player.player_ped(), v3(-1615.61, -3015.80, -75.20))
            Local_Feature["Teleport To Safe"].on = false
        end
        system.wait()
    end
end)

Local_Feature["Skip Setups"] = menu.add_feature("Skip Setups", "action", Local_Parents["Nightclub"], function(f)
    lib.natives.SET_PACKED_STAT_BOOL_CODE(18161, true, lib.essentials.get_char_slot())
    lib.natives.SET_PACKED_STAT_BOOL_CODE(22067, true, lib.essentials.get_char_slot())
    lib.natives.SET_PACKED_STAT_BOOL_CODE(22068, true, lib.essentials.get_char_slot())
end)

Local_Feature["Max Popularity"] = menu.add_feature("Max Popularity", "action", Local_Parents["Nightclub"], function(f)
    stats.stat_set_int(gameplay.get_hash_key("MP" .. lib.essentials.get_char_slot() .. "_CLUB_POPULARITY"), 1000, true)
end)

Local_Feature["Max Safe Revenue"] = menu.add_feature("Max Safe Revenue", "action", Local_Parents["Nightclub"], function(f)
    lib.globals.max_safe_revenue()
end)

Local_Feature["17M Every Minute"] = menu.add_feature("17M Every Minute", "toggle", Local_Parents["Nightclub"], function(f)
    while f.on do
        entity.set_entity_coords_no_offset(player.player_ped(), v3(-1615.61, -3015.80, -75.20))
        Local_Feature["Max Popularity"].on = true
        Local_Feature["Max Safe Revenue"].on = true
        system.wait()
    end
end)

Local_Parents["Orbital"] = menu.add_feature("Orbital", "parent", Local_Parents["Money Manager"]).id

Local_Feature["6.25M Every 2 Minutes"] = menu.add_feature("6.25M Every 2 Minutes", "toggle", Local_Parents["Orbital"], function(f)
    while f.on do
        lib.globals.orbital_750k()
        system.wait(1000)
        lib.globals.orbital_500k()
        system.wait(1000)
    end
end)

Local_Feature["750k"] = menu.add_feature("750k", "action", Local_Parents["Orbital"], function(f)
    lib.globals.orbital_750k()
end)

Local_Feature["500k"] = menu.add_feature("500k", "action", Local_Parents["Orbital"], function(f)
    lib.globals.orbital_500k()
end)
]]

Local_Feature["Money Value"] = menu.add_feature("Value", "action_value_i", Local_Parents["Money Manager"], function(f)
    local input_stat, input_val = input.get("Value from " .. f.min .. " to " .. f.max, "", 10, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Money Value"].max = 0
Local_Feature["Money Value"].min = 0
Local_Feature["Money Value"].mod = 1
Local_Feature["Money Value"].value = 1

menu.create_thread(function()
    while true do
        if Local_Feature["Money Methode"] ~= nil and Local_Feature["Money Methode"].value == 0 then
            Local_Feature["Money Value"].min = 1
            Local_Feature["Money Value"].max = 1000000
        else
            Local_Feature["Money Value"].min = 100
            Local_Feature["Money Value"].max = int_max
        end
        system.wait()
    end
end)

Local_Feature["Money Methode"] = menu.add_feature("Methode", "autoaction_value_str", Local_Parents["Money Manager"], function(f)
end)
Local_Feature["Money Methode"]:set_str_data({"Add", "Remove"})

Local_Feature["Money Enable"] = menu.add_feature("Enable", "value_str", Local_Parents["Money Manager"], function(f)
    while f.on and f.value == 0 do
        if Local_Feature["Money Methode"].value == 0 then
            lib.globals.add_money(Local_Feature["Money Value"].value)
        else
            if Local_Feature["Money Value"].value > lib.natives.NETWORK_GET_STRING_WALLET_BALANCE(lib.essentials.get_char_slot()) then
                lib.globals.remove_money(lib.natives.NETWORK_GET_STRING_WALLET_BALANCE(lib.essentials.get_char_slot()))
            else
                lib.globals.remove_money(Local_Feature["Money Value"].value)
            end
        end
        system.wait()
    end
    if f.value == 1 then
        if Local_Feature["Money Methode"].value == 0 then
            lib.globals.add_money(Local_Feature["Money Value"].value)
        else
            if Local_Feature["Money Value"].value > lib.natives.NETWORK_GET_STRING_WALLET_BALANCE(lib.essentials.get_char_slot()) then
                lib.globals.remove_money(lib.natives.NETWORK_GET_STRING_WALLET_BALANCE(lib.essentials.get_char_slot()))
            else
                lib.globals.remove_money(Local_Feature["Money Value"].value)
            end
        end
        f.on = false
    end
end)
Local_Feature["Money Enable"]:set_str_data({"Loop", "Once"})

Local_Feature["Add 5k Chips"] = menu.add_feature("Add 5k Chips", "value_str", Local_Parents["Money Manager"], function(f)
    while f.on and f.value == 0 do
        lib.globals.chips_5k()
        system.wait()
    end
    if f.value == 1 then
        lib.globals.chips_5k()
        f.on = false
    end
end)
Local_Feature["Add 5k Chips"]:set_str_data({"Loop", "Once"})

Local_Parents["View Report Stats"] = menu.add_feature("View Report Stats", "parent", Local_Parents["Online"]).id

Local_Feature["Clear All Report"] = menu.add_feature("Clear All Report", "action", Local_Parents["View Report Stats"], function(f)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_GRIEFING"), 0, true)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_EXPLOITS"), 0, true)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_GAME_EXPLOITS"), 0, true)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_TC_ANNOYINGME"), 0, true)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_TC_HATE"), 0, true)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_VC_ANNOYINGME"), 0, true)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_VC_HATE"), 0, true)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_OFFENSIVE_LANGUAGE"), 0, true)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_OFFENSIVE_TAGPLATE"), 0, true)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_OFFENSIVE_UGC"), 0, true)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_BAD_CREW_NAME"), 0, true)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_BAD_CREW_MOTTO"), 0, true)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_BAD_CREW_STATUS"), 0, true)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_BAD_CREW_EMBLEM"), 0, true)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_FRIENDLY"), 0, true)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_HELPFUL"), 0, true)
end)

Local_Feature["Griefing or Disruptive Gameplay"] = menu.add_feature("Griefing or Disruptive Gameplay", "action_value_str", Local_Parents["View Report Stats"], function(f, pid)
    utils.to_clipboard(f.str_data[1])
    lua_notify("Copy to clipboard succeeded.", f.name)
end)
Local_Feature["Griefing or Disruptive Gameplay"]:set_str_data({""})

Local_Feature["Cheating or Modding"] = menu.add_feature("Cheating or Modding", "action_value_str", Local_Parents["View Report Stats"], function(f, pid)
    utils.to_clipboard(f.str_data[1])
    lua_notify("Copy to clipboard succeeded.", f.name)
end)
Local_Feature["Cheating or Modding"]:set_str_data({""})

Local_Feature["Glitching or Abusing Game Features"] = menu.add_feature("Glitching or Abusing Game Features", "action_value_str", Local_Parents["View Report Stats"], function(f, pid)
    utils.to_clipboard(f.str_data[1])
    lua_notify("Copy to clipboard succeeded.", f.name)
end)
Local_Feature["Glitching or Abusing Game Features"]:set_str_data({""})

Local_Feature["Text Chat: Annoying Me"] = menu.add_feature("Text Chat: Annoying Me", "action_value_str", Local_Parents["View Report Stats"], function(f, pid)
    utils.to_clipboard(f.str_data[1])
    lua_notify("Copy to clipboard succeeded.", f.name)
end)
Local_Feature["Text Chat: Annoying Me"]:set_str_data({""})

Local_Feature["Text Chat: Using Hate Speech"] = menu.add_feature("Text Chat: Using Hate Speech", "action_value_str", Local_Parents["View Report Stats"], function(f, pid)
    utils.to_clipboard(f.str_data[1])
    lua_notify("Copy to clipboard succeeded.", f.name)
end)
Local_Feature["Text Chat: Using Hate Speech"]:set_str_data({""})

Local_Feature["Voice Chat: Annoying Me"] = menu.add_feature("Voice Chat: Annoying Me", "action_value_str", Local_Parents["View Report Stats"], function(f, pid)
    utils.to_clipboard(f.str_data[1])
    lua_notify("Copy to clipboard succeeded.", f.name)
end)
Local_Feature["Voice Chat: Annoying Me"]:set_str_data({""})

Local_Feature["Voice Chat: Using Hate Speech"] = menu.add_feature("Voice Chat: Using Hate Speech", "action_value_str", Local_Parents["View Report Stats"], function(f, pid)
    utils.to_clipboard(f.str_data[1])
    lua_notify("Copy to clipboard succeeded.", f.name)
end)
Local_Feature["Voice Chat: Using Hate Speech"]:set_str_data({""})

Local_Feature["Offensive Language"] = menu.add_feature("Offensive Language", "action_value_str", Local_Parents["View Report Stats"], function(f, pid)
    utils.to_clipboard(f.str_data[1])
    lua_notify("Copy to clipboard succeeded.", f.name)
end)
Local_Feature["Offensive Language"]:set_str_data({""})

Local_Feature["Offensive Tagplate"] = menu.add_feature("Offensive Tagplate", "action_value_str", Local_Parents["View Report Stats"], function(f, pid)
    utils.to_clipboard(f.str_data[1])
    lua_notify("Copy to clipboard succeeded.", f.name)
end)
Local_Feature["Offensive Tagplate"]:set_str_data({""})

Local_Feature["Offensive Content"] = menu.add_feature("Offensive Content", "action_value_str", Local_Parents["View Report Stats"], function(f, pid)
    utils.to_clipboard(f.str_data[1])
    lua_notify("Copy to clipboard succeeded.", f.name)
end)
Local_Feature["Offensive Content"]:set_str_data({""})

Local_Feature["Bad Crew Name"] = menu.add_feature("Bad Crew Name", "action_value_str", Local_Parents["View Report Stats"], function(f, pid)
    utils.to_clipboard(f.str_data[1])
    lua_notify("Copy to clipboard succeeded.", f.name)
end)
Local_Feature["Bad Crew Name"]:set_str_data({""})

Local_Feature["Bad Crew Motto"] = menu.add_feature("Bad Crew Motto", "action_value_str", Local_Parents["View Report Stats"], function(f, pid)
    utils.to_clipboard(f.str_data[1])
    lua_notify("Copy to clipboard succeeded.", f.name)
end)
Local_Feature["Bad Crew Motto"]:set_str_data({""})

Local_Feature["Bad Crew Status"] = menu.add_feature("Bad Crew Status", "action_value_str", Local_Parents["View Report Stats"], function(f, pid)
    utils.to_clipboard(f.str_data[1])
    lua_notify("Copy to clipboard succeeded.", f.name)
end)
Local_Feature["Bad Crew Status"]:set_str_data({""})

Local_Feature["Bad Crew Emblem"] = menu.add_feature("Bad Crew Emblem", "action_value_str", Local_Parents["View Report Stats"], function(f, pid)
    utils.to_clipboard(f.str_data[1])
    lua_notify("Copy to clipboard succeeded.", f.name)
end)
Local_Feature["Bad Crew Emblem"]:set_str_data({""})

Local_Feature["Friendly"] = menu.add_feature("Friendly", "action_value_str", Local_Parents["View Report Stats"], function(f, pid)
    utils.to_clipboard(f.str_data[1])
    lua_notify("Copy to clipboard succeeded.", f.name)
end)
Local_Feature["Friendly"]:set_str_data({""})

Local_Feature["Helpful"] = menu.add_feature("Helpful", "action_value_str", Local_Parents["View Report Stats"], function(f, pid)
    utils.to_clipboard(f.str_data[1])
    lua_notify("Copy to clipboard succeeded.", f.name)
end)
Local_Feature["Helpful"]:set_str_data({""})

Local_Parents["ATM"] = menu.add_feature("ATM", "parent", Local_Parents["Online"]).id

Local_Feature["ATM Value"] = menu.add_feature("Value", "action_value_i", Local_Parents["ATM"], function(f)
    local input_stat, input_val = input.get("Value from " .. f.min .. " to " .. f.max, "", 10, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["ATM Value"].max = int_max
Local_Feature["ATM Value"].min = 1
Local_Feature["ATM Value"].mod = 1
Local_Feature["ATM Value"].value = 1

local other_char_slot
if lib.essentials.get_char_slot() == 0 then
    other_char_slot = 1
else
    other_char_slot = 0
end

Local_Feature["Transfer From"] = menu.add_feature("Transfer From", "autoaction_value_str", Local_Parents["ATM"], function(f)
end)
Local_Feature["Transfer From"]:set_str_data({"Wallet To Bank", "Bank To Wallet"})

Local_Feature["Transfer Money"] = menu.add_feature("Transfer", "action", Local_Parents["ATM"], function(f)
    if Local_Feature["Transfer From"].value == 0 then
        local wallet <const> = lib.natives.NETWORK_GET_STRING_WALLET_BALANCE(lib.essentials.get_char_slot())
        if wallet > 0 then
            if Local_Feature["ATM Value"].value > wallet then
                lib.essentials.atm(wallet, 0, lib.essentials.get_char_slot())
            else
                lib.essentials.atm(Local_Feature["ATM Value"].value, 0, lib.essentials.get_char_slot())
            end
        end
    else
        local my_bank <const> = lib.natives.NETWORK_GET_STRING_BANK_BALANCE()
        if my_bank > 0 then
            if Local_Feature["ATM Value"].value > my_bank then
                lib.essentials.atm(my_bank, 1, lib.essentials.get_char_slot())
            else
                lib.essentials.atm(Local_Feature["ATM Value"].value, 1, lib.essentials.get_char_slot())
            end
        end
    end
end)

Local_Parents["Player Camera"] = menu.add_feature("Player Camera", "parent", Local_Parents["Online"]).id

Local_Feature["Player Camera Enable"] = menu.add_feature("Enable", "toggle", Local_Parents["Player Camera"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            local bool, player_pos <const> = ped.get_ped_bone_coords(player.get_player_ped(pid), 0x60f2, v3(0, 0, 0))
            local cam_rot <const> = lib.natives.GET_FINAL_RENDERED_REMOTE_PLAYER_CAM_ROT(pid, 0)
            local cam_rot <const> = v3(cam_rot.x + -6, cam_rot.y, cam_rot.z + 6)
            local cam_pos <const> = lib.essentials.get_offset_from_position(player_pos, cam_rot, v3(0, Local_Feature["Player Line Length"].value * -1, 0))
            local scale <const> = Local_Feature["Player Camera Scale"].value

            if Local_Feature["Player Camera Style"].value == 0 then
                local before_cam_pos <const> = lib.essentials.get_offset_from_position(cam_pos, cam_rot, v3(0, Local_Feature["Player Camera Length"].value, 0))
                local cam_down_right <const> = lib.essentials.get_offset_from_position(before_cam_pos, cam_rot, v3(scale * 2, 0, scale * -1))
                local cam_down_left <const> = lib.essentials.get_offset_from_position(before_cam_pos, cam_rot, v3(scale * -1 * 2, 0, scale * -1))
                local cam_top_right <const> = lib.essentials.get_offset_from_position(before_cam_pos, cam_rot, v3(scale * 2, 0, scale))
                local cam_top_left <const> = lib.essentials.get_offset_from_position(before_cam_pos, cam_rot, v3(scale * -1 * 2, 0, scale))

                ui.draw_line(player_pos, cam_pos, 255, 255, 255, 255)

                ui.draw_line(cam_down_right, cam_down_left, 255, 255, 255, 255)
                ui.draw_line(cam_down_left, cam_top_left, 255, 255, 255, 255)
                ui.draw_line(cam_top_left, cam_top_right, 255, 255, 255, 255)
                ui.draw_line(cam_top_right, cam_down_right, 255, 255, 255, 255)

                ui.draw_line(cam_top_left, cam_down_right, 255, 255, 255, 255)
                ui.draw_line(cam_top_right, cam_down_left, 255, 255, 255, 255)

                ui.draw_line(cam_down_right, cam_pos, 255, 255, 255, 255)
                ui.draw_line(cam_down_left, cam_pos, 255, 255, 255, 255)
                ui.draw_line(cam_top_left, cam_pos, 255, 255, 255, 255)
                ui.draw_line(cam_top_right, cam_pos, 255, 255, 255, 255)
            else
                local scale <const> = scale * 2
                local before_cam_pos <const> = lib.essentials.get_offset_from_position(cam_pos, cam_rot, v3(0, Local_Feature["Player Camera Length"].value, 0))
                local cam_right <const> = lib.essentials.get_offset_from_position(before_cam_pos, cam_rot, v3(scale, 0, 0))
                local cam_left <const> = lib.essentials.get_offset_from_position(before_cam_pos, cam_rot, v3(scale * -1, 0, 0))
                local cam_top <const> = lib.essentials.get_offset_from_position(before_cam_pos, cam_rot, v3(0, 0, scale))
                local cam_down <const> = lib.essentials.get_offset_from_position(before_cam_pos, cam_rot, v3(0, 0, scale * -1))

                ui.draw_line(player_pos, cam_pos, 255, 255, 255, 255)

                ui.draw_line(cam_top, cam_down, 255, 255, 255, 255)
                ui.draw_line(cam_left, cam_right, 255, 255, 255, 255)

                ui.draw_line(cam_top, cam_pos, 255, 255, 255, 255)
                ui.draw_line(cam_down, cam_pos, 255, 255, 255, 255)
                ui.draw_line(cam_left, cam_pos, 255, 255, 255, 255)
                ui.draw_line(cam_right, cam_pos, 255, 255, 255, 255)

                ui.draw_line(cam_top, cam_right, 255, 255, 255, 255)
                ui.draw_line(cam_down, cam_left, 255, 255, 255, 255)
                ui.draw_line(cam_left, cam_top, 255, 255, 255, 255)
                ui.draw_line(cam_right, cam_down, 255, 255, 255, 255)
            end
        end
        system.wait()
    end
end)

Local_Feature["Player Camera Style"] = menu.add_feature("Style", "autoaction_value_str", Local_Parents["Player Camera"], function(f)
end)
Local_Feature["Player Camera Style"]:set_str_data({"v1", "v2"})

Local_Feature["Player Line Length"] = menu.add_feature("Line Length", "action_value_f", Local_Parents["Player Camera"], function(f)
    local input_stat, input_val = input.get("Line Length from " .. f.min .. " to " .. f.max, "", 10, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Player Line Length"].max = 5.00
Local_Feature["Player Line Length"].min = 0.50
Local_Feature["Player Line Length"].mod = 0.50
Local_Feature["Player Line Length"].value = 2.00

Local_Feature["Player Camera Length"] = menu.add_feature("Camera Length", "action_value_f", Local_Parents["Player Camera"], function(f)
    local input_stat, input_val = input.get("Camera Length from " .. f.min .. " to " .. f.max, "", 10, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Player Camera Length"].max = 2.00
Local_Feature["Player Camera Length"].min = 0.10
Local_Feature["Player Camera Length"].mod = 0.10
Local_Feature["Player Camera Length"].value = 0.50

Local_Feature["Player Camera Scale"] = menu.add_feature("Scale", "action_value_f", Local_Parents["Player Camera"], function(f)
    local input_stat, input_val = input.get("Scale from " .. f.min .. " to " .. f.max, "", 10, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Player Camera Scale"].max = 1.00
Local_Feature["Player Camera Scale"].min = 0.04
Local_Feature["Player Camera Scale"].mod = 0.02
Local_Feature["Player Camera Scale"].value = 0.8

Local_Parents["Player Aim Line"] = menu.add_feature("Player Aim Line", "parent", Local_Parents["Online"]).id

Local_Feature["Player Aim Line Enable"] = menu.add_feature("Enable", "toggle", Local_Parents["Player Aim Line"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            local ped_weapon <const> = lib.natives.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(player.get_player_ped(pid), false)
            local weapon_coords <const> = lib.natives.GET_ENTITY_BONE_POSTION(ped_weapon, entity.get_entity_bone_index_by_name(ped_weapon, "gun_muzzle"))
            local cam_rot <const> = lib.natives.GET_FINAL_RENDERED_REMOTE_PLAYER_CAM_ROT(pid, 0)
            local cam_pos <const> = lib.essentials.get_offset_from_position(weapon_coords, cam_rot, v3(0, Local_Feature["Player Aim Line Length"].value, 0))
            if ai.is_task_active(player.get_player_ped(pid), 4) then
                ui.draw_line(weapon_coords, cam_pos, 255, 0, 0, 255)
            end
        end
        system.wait()
    end
end)

Local_Feature["Player Aim Line Length"] = menu.add_feature("Line Length", "action_value_i", Local_Parents["Player Aim Line"], function(f)
    local input_stat, input_val = input.get("Line Length from " .. f.min .. " to " .. f.max, "", 10, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Player Aim Line Length"].max = 3000
Local_Feature["Player Aim Line Length"].min = 0
Local_Feature["Player Aim Line Length"].mod = 25
Local_Feature["Player Aim Line Length"].value = 1000

Local_Parents["Auto Accept"] = menu.add_feature("Auto Accept", "parent", Local_Parents["Online"]).id

local warnings <const> = {
    "NT_INV_BOOT",
    "NT_INV_CREATOR",
    "NT_INV_DIFFERENT_PROFILE",
    "NT_INV_FREE",
    "NT_INV_IN_PARTY",
    "NT_INV_MP_SAVE",
    "NT_INV_PARTY_INVITE_MP_SAVE",
    "NT_INV_PARTY_INVITE_MP",
    "NT_INV_PARTY_INVITE_SAVE",
    "NT_INV_PARTY_INVITE",
    "NT_INV_SP_SAVE",
    "NT_INV",
}

Local_Feature["Auto Accept Join Messages"] = menu.add_feature("Join Messages", "toggle", Local_Parents["Auto Accept"], function(f)
    while f.on do
        local message_hash <const> = lib.natives.GET_WARNING_SCREEN_MESSAGE_HASH()
        for _, message in pairs(warnings) do
            if message_hash == gameplay.get_hash_key(message) then
                system.wait(50)
                controls.set_control_normal(2, lib.table.input_type["Frontend Accept"], 1)
            end
        end
        system.wait()
    end
end)

Local_Feature["Auto Accept Transaction Errors"] = menu.add_feature("Transaction Errors", "toggle", Local_Parents["Auto Accept"], function(f)
    while f.on do
        local message_hash <const> = lib.natives.GET_WARNING_SCREEN_MESSAGE_HASH()
        if message_hash == gameplay.get_hash_key("CTALERT_F_4") then
            system.wait(50)
            controls.set_control_normal(2, lib.table.input_type["Frontend Accept"], 1)
        end
        system.wait()
    end
end)

Local_Parents["Transition Helper"] = menu.add_feature("Transition Helper", "parent", Local_Parents["Online"]).id

Local_Feature["Skip Swoop Down"] = menu.add_feature("Skip Swoop Down", "toggle", Local_Parents["Transition Helper"], function(f)
    while f.on do
        local state <const> = lib.natives.GET_PLAYER_SWITCH_STATE()
        if (state == 3
        or state == 6
        or state == 8
        or state == 9
        or state == 10
        or state == 12)
        and lib.globals.is_loading() then
            lib.natives.STOP_PLAYER_SWITCH()
            graphics.animpostfx_stop_all()
        end
        system.wait()
    end
end)

Local_Feature["Disable Spawn Animation"] = menu.add_feature("Disable Spawn Animation", "toggle", Local_Parents["Transition Helper"], function(f)
    while f.on do
        local state <const> = lib.natives.GET_PLAYER_SWITCH_STATE()
        if (state == 3
        or state == 6
        or state == 8
        or state == 9
        or state == 10
        or state == 12)
        and lib.globals.is_loading() and player.player_count() ~= 0 then
            system.wait(100)
            ped.clear_ped_tasks_immediately(player.player_ped())
        end
        system.wait()
    end
end)

Local_Feature["Fast Join"] = menu.add_feature("Fast Join", "toggle", Local_Parents["Transition Helper"], function(f)
    while f.on do
        if lib.globals.is_loading() and script.get_host_of_this_script() ~= player.player_id() and script.get_host_of_this_script() ~= -1 then
            lib.player.force_script_host()
        end
        system.wait()
    end
end)

--[[
SET_GHOST_ALPHA
RESET_GHOST_ALPHA
SET_LOCAL_PLAYER_AS_GHOST
SET_NETWORK_VEHICLE_AS_GHOST
]]

Local_Feature["Force Cloud Save"] = menu.add_feature("Force Cloud Save", "action", Local_Parents["Online"], function(f)
    lib.natives.STAT_SAVE(0, false, 3, false)
end)

Local_Feature["Disable Bandwidth Restrictions"] = menu.add_feature("Disable Bandwidth Restrictions", "toggle", Local_Parents["Online"], function(f)
    while f.on do
        for pid in lib.player.list(true) do
            lib.natives.NETWORK_DISABLE_VOICE_BANDWIDTH_RESTRICTION(pid)
        end
        system.wait()
    end
    if not f.on then
        for pid in lib.player.list(true) do
            lib.natives.NETWORK_ENABLE_VOICE_BANDWIDTH_RESTRICTION(pid)
        end
    end
end)

Local_Feature["Quit To Story Mode"] = menu.add_feature("Quit To Story Mode", "action", Local_Parents["Online"], function(f)
    lib.natives.NETWORK_BAIL(1, 1, 1)
end)

Local_Feature["Create Ghost Session"] = menu.add_feature("Create Ghost Session", "toggle", Local_Parents["Online"], function(f)
    if f.on then
        lib.natives.NETWORK_START_SOLO_TUTORIAL_SESSION()
    else
        lib.natives.NETWORK_END_TUTORIAL_SESSION()
    end
end)

Local_Feature["Join Full Session"] = menu.add_feature("Join Full Session", "toggle", Local_Parents["Online"], function(f)
    while f.on do
        lib.natives.NETWORK_SET_IN_SPECTATOR_MODE(true, player.player_id())
        system.wait(100)
    end
    if not f.on then
        lib.natives.NETWORK_SET_IN_SPECTATOR_MODE(false, player.player_id())
    end
end)

Local_Feature["R* Admin Hear All Player"] = menu.add_feature("R* Admin Hear All Player", "toggle", Local_Parents["Online"], function(f)
    while f.on do
        lib.natives.NETWORK_OVERRIDE_RECEIVE_RESTRICTIONS_ALL(true)
        system.wait(100)
    end
    if not f.on then
        lib.natives.NETWORK_OVERRIDE_RECEIVE_RESTRICTIONS_ALL(false)
    end
end)

Local_Parents["Detection"] = menu.add_feature("Detection", "parent", Local_Parents["Local Prents"]).id

Local_Parents["Modder Option"] = menu.add_feature("Modder Option", "parent", Local_Parents["Detection"]).id

local flag_modder_detection <const> = {}
local flag_modder_detection_all <const> = {"All"}
local modder_flag_count = 0
while player.get_modder_flag_text(1 << modder_flag_count) ~= "" do
    flag_modder_detection[#flag_modder_detection + 1] = player.get_modder_flag_text(1 << modder_flag_count)
    flag_modder_detection_all[#flag_modder_detection_all + 1] = player.get_modder_flag_text(1 << modder_flag_count)
    modder_flag_count = modder_flag_count + 1
end

Local_Feature["Detection Mark All Player"] = menu.add_feature("Mark All Player", "action_value_str", Local_Parents["Modder Option"], function(f)
    for pid in lib.player.list(false) do
        if f.value == 0 then
            for i = 1, #flag_modder_detection do
                player.set_player_as_modder(pid, player.add_modder_flag(flag_modder_detection[i]))
            end
        else
            player.set_player_as_modder(pid, 1 << f.value - 1)
        end
    end
end)
Local_Feature["Detection Mark All Player"]:set_str_data(flag_modder_detection_all)

Local_Feature["Detection Unmark All Player"] = menu.add_feature("Unmark All Player", "action_value_str", Local_Parents["Modder Option"], function(f)
    for pid in lib.player.list(false) do
        if f.value == 0 then
            for i = 1, #flag_modder_detection do
                player.unset_player_as_modder(pid, player.add_modder_flag(flag_modder_detection[i]))
            end
        else
            player.unset_player_as_modder(pid, 1 << f.value - 1)
        end
    end
end)
Local_Feature["Detection Unmark All Player"]:set_str_data(flag_modder_detection_all)

Local_Feature["Detection Whitelist Friend"] = menu.add_feature("Whitelist Friend", "toggle", Local_Parents["Modder Option"], function(f)
end)

Local_Parents["Spoof Account"] = menu.add_feature("Spoof Account", "parent", Local_Parents["Detection"]).id

Local_Feature["Detection Modded Name"] = menu.add_feature("Modded Name", "toggle", Local_Parents["Spoof Account"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if not lib.globals.is_loading() and can_player_be_modder(pid, "Modded Name") then
                if string.len(lib.player.get_player_name(pid)) < 6 or string.len(lib.player.get_player_name(pid)) > 16 or not string.find(lib.player.get_player_name(pid), "^[%.%-%w_]+$") then
                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Name", "Anarchy Modder Detection")
                    player.set_player_as_modder(pid, ModderFlags["Modded Name"])
                end
            end
        end
        system.wait(1000)
    end
end)

Local_Feature["Detection Modded SCID"] = menu.add_feature("Modded SCID", "toggle", Local_Parents["Spoof Account"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if not lib.globals.is_loading() and can_player_be_modder_2(pid, 1 << 0x02) then
                if player.get_player_scid(pid) < 100000 or player.get_player_scid(pid) > 250000000 then
                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded SCID", "Anarchy Modder Detection")
                    player.set_player_as_modder(pid, 1 << 0x02)
                end
            end
        end
        system.wait(1000)
    end
end)

Local_Feature["Detection Modded IP"] = menu.add_feature("Modded IP", "toggle", Local_Parents["Spoof Account"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if not lib.globals.is_loading() and lib.globals.get_spawn_state(pid) == 99 and can_player_be_modder(pid, "Modded IP") then
                local ip <const> = lib.player.get_player_ip(pid, 2)
                if ip ~= "relay" and ip ~= nil and (ip <= 0 or ip >= 4294967295 or ip == 1162167621 or ip == 16843009 or ip == 2130706433) then
                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded IP", "Anarchy Modder Detection")
                    player.set_player_as_modder(pid, 1 << 0x13)
                end
            end
        end
        system.wait(1000)
    end
end)

Local_Feature["Detection Modded Host Token"] = menu.add_feature("Modded Host Token", "toggle", Local_Parents["Spoof Account"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if not lib.globals.is_loading() and can_player_be_modder_2(pid, 1 << 0x0F) then
                if player.get_player_host_token(pid) < 100000 and player.get_player_host_token(pid) > -100000 then
                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Host Token", "Anarchy Modder Detection")
                    player.set_player_as_modder(pid, 1 << 0x0F)
                end
            end
        end
        system.wait(1000)
    end
end)

Local_Parents["Modded Stats"] = menu.add_feature("Modded Stats", "parent", Local_Parents["Detection"]).id

Local_Feature["Detection Modded Stats Kills"] = menu.add_feature("Kills", "toggle", Local_Parents["Modded Stats"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if not lib.globals.is_loading() and can_player_be_modder(pid, "Modded Stats") then
                if lib.globals.get_player_kills(pid) > 1000000 or lib.globals.get_player_kills(pid) < 0 then
                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Stats (Kills)", "Anarchy Modder Detection")
                    player.set_player_as_modder(pid, ModderFlags["Modded Stats"])
                end
            end
        end
        system.wait(1000)
    end
end)

Local_Feature["Detection Modded Stats Deaths"] = menu.add_feature("Deaths", "toggle", Local_Parents["Modded Stats"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if not lib.globals.is_loading() and can_player_be_modder(pid, "Modded Stats") then
                if lib.globals.get_player_deaths(pid) > 1000000 or lib.globals.get_player_deaths(pid) < 0 then
                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Stats (Deaths)", "Anarchy Modder Detection")
                    player.set_player_as_modder(pid, ModderFlags["Modded Stats"])
                end
            end
        end
        system.wait(1000)
    end
end)

Local_Feature["Detection Modded Stats K/D"] = menu.add_feature("K/D", "toggle", Local_Parents["Modded Stats"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if not lib.globals.is_loading() and can_player_be_modder(pid, "Modded Stats") then
                if lib.globals.get_player_kd(pid) > 100.00 or lib.globals.get_player_kd(pid) < 0 then
                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Stats (K/D)", "Anarchy Modder Detection")
                    player.set_player_as_modder(pid, ModderFlags["Modded Stats"])
                end
            end
        end
        system.wait(1000)
    end
end)

Local_Feature["Detection Modded Stats Rank"] = menu.add_feature("Rank", "toggle", Local_Parents["Modded Stats"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if not lib.globals.is_loading() and can_player_be_modder(pid, "Modded Stats") then
                if lib.globals.get_player_rank(pid) > 8000 or lib.globals.get_player_rank(pid) < 0 then
                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Stats (Rank)", "Anarchy Modder Detection")
                    player.set_player_as_modder(pid, ModderFlags["Modded Stats"])
                end
            end
        end
        system.wait(1000)
    end
end)

local Modded_Weapons <const> = {
    lib.table.weapon["Acid Package"],
    lib.table.weapon["Fertilizer Can"],
    lib.table.weapon["Fire Extinguisher"],
    lib.table.weapon["Hazardous Jerry Can"],
    lib.table.weapon["Invalid"],
    lib.table.weapon["Metal Detector"],
    lib.table.weapon["Railgun (SP)"],
    lib.table.weapon["RPG (Invalid)"],
    lib.table.weapon["Snowball"],
    lib.table.weapon["Stun Gun (Invalid)"],
    lib.table.weapon["Stun Gun (SP)"],
}

Local_Feature["Detection Modded Stats Favourite Weapon"] = menu.add_feature("Favourite Weapon", "toggle", Local_Parents["Modded Stats"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if not lib.globals.is_loading() and can_player_be_modder(pid, "Modded Stats") then
                local plyr_favourite_weapon <const> = lib.essentials.get_uint32(lib.globals.get_player_favourite_weapon_hash(player.player_id()))
                for i, hash in ipairs(Modded_Weapons) do
                    if gameplay.get_hash_key(hash) == plyr_favourite_weapon then
                        lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Stats (Favourite Weapon)", "Anarchy Modder Detection")
                        player.set_player_as_modder(pid, ModderFlags["Modded Stats"])
                    end
                end
            end
        end
        system.wait(1000)
    end
end)

Local_Feature["Detection Modded Stats Money"] = menu.add_feature("Money", "toggle", Local_Parents["Modded Stats"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if not lib.globals.is_loading() and lib.player.is_player_can_play(pid) and can_player_be_modder(pid, "Modded Stats") then
                local plyr_wallet <const> = lib.globals.get_player_wallet(pid)
                local plyr_bank <const> = lib.globals.get_player_bank(pid)
                if plyr_wallet ~= -plyr_bank and (plyr_wallet + plyr_bank > 2000000000 or plyr_wallet < 0 or plyr_bank < -2000000000) then
                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Stats (Money)", "Anarchy Modder Detection")
                    player.set_player_as_modder(pid, ModderFlags["Modded Stats"])
                end
            end
        end
        system.wait(1000)
    end
end)

Local_Parents["Network & Script Event"] = menu.add_feature("Network & Script Event", "parent", Local_Parents["Detection"]).id

Local_Feature["Detection Modded Script Event"] = menu.add_feature("Modded Script Event", "toggle", Local_Parents["Network & Script Event"], function(f)
    if f.on then
        Event_Hooks["Detection Modded Script Event"] = hook.register_script_event_hook(function(source, target, params, count)
            for i = 1, #params do
                params[i] = params[i] & 0xFFFFFFFF
            end
            if (params[1] > -10000 and params[1] < 10000) or params[1] == 0 or params[2] ~= source then
                if can_player_be_modder(pid, "Modded Script Event") then
                    lua_notify("Player: " .. lib.player.get_player_name(source) .. "\nReason: Modded Script Event", "Anarchy Modder Detection")
                    player.set_player_as_modder(source, ModderFlags["Modded Script Event"])
                end
            end
        end)
    end
    if not f.on then
        hook.remove_script_event_hook(Event_Hooks["Detection Modded Script Event"])
    end
end)

local Modded_Network_Event <const> = {
    lib.table.net_event["Request Map Pickup"],
    lib.table.net_event["Game Clock"],
    lib.table.net_event["Game Weather"],
    lib.table.net_event["Give Weapon"],
    lib.table.net_event["Remove Weapon"],
    lib.table.net_event["Remove All Weapons"],
    lib.table.net_event["Give Ped Scripted Task"],
    lib.table.net_event["Give Ped Sequence Task"],
    lib.table.net_event["Clear Ped Tasks"],
    lib.table.net_event["Start Ped Arrest"],
    lib.table.net_event["Start Ped Uncuff"],
    lib.table.net_event["Request Phone Explosion"],
    lib.table.net_event["Give Pickup Rewards"],
    lib.table.net_event["Check Exe Size"],
    lib.table.net_event["Check Code CRCS"],
    lib.table.net_event["Check Catalog CRC"],
}

Local_Feature["Detection Modded Network Event"] = menu.add_feature("Modded Network Event", "toggle", Local_Parents["Network & Script Event"], function(f)
    if f.on then
        Event_Hooks["Detection Modded Network Event"] = hook.register_net_event_hook(function(source, target, eventId)
            for i, modded_eventId in ipairs(Modded_Network_Event) do
                if modded_eventId == eventId and can_player_be_modder(source, "Modded Network Event") then
                    lua_notify("Player: " .. lib.player.get_player_name(source) .. "\nReason: Modded Network Event (" .. lib.essentials.get_name_by_value(lib.table.net_event, eventId) .. ")", "Anarchy Modder Detection")
                    player.set_player_as_modder(source, ModderFlags["Modded Network Event"])
                end
            end
        end)
    end
    if not f.on then
        hook.remove_script_event_hook(Event_Hooks["Detection Modded Network Event"])
    end
end)

Local_Feature["Detection Script Event Spam"] = menu.add_feature("Script Event Spam", "toggle", Local_Parents["Network & Script Event"], function(f)
    if f.on then
        for pid = 0, 31 do
            ScriptEventSpamCount[pid] = 0
        end
        Event_Hooks["Detection Script Event Spam"] = hook.register_script_event_hook(function(source, target, params, count)
            ScriptEventSpamCount[source] = ScriptEventSpamCount[source] + 1
        end)
    end
    while f.on do
        for pid in lib.player.list(false) do
            if ScriptEventSpamCount[pid] > 35 and can_player_be_modder_2(pid, 1 << 0x10) then
                lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Script Event Spam", "Anarchy Modder Detection")
                player.set_player_as_modder(pid, 1 << 0x10)
            end
            ScriptEventSpamCount[pid] = 0
        end
        system.wait(5000)
    end
    if not f.on then
        for pid = 0, 31 do
            ScriptEventSpamCount[pid] = 0
        end
        hook.remove_script_event_hook(Event_Hooks["Detection Script Event Spam"])
    end
end)

Local_Feature["Detection Network Event Spam"] = menu.add_feature("Network Event Spam", "toggle", Local_Parents["Network & Script Event"], function(f)
    for pid = 0, 31 do
        NetworkEventSpamCount[pid] = 0
    end
    Event_Hooks["Detection Network Event Spam"] = hook.register_net_event_hook(function(source, target, eventId)
        if eventId ~= lib.table.net_event["Scripted Game"]
        and eventId ~= lib.table.net_event["Entity Area Status"]
        and eventId ~= lib.table.net_event["Give Control"]
        and eventId ~= lib.table.net_event["Remote Script Info"]
        and eventId ~= lib.table.net_event["Remote Script Leave"] then
            NetworkEventSpamCount[source] = NetworkEventSpamCount[source] + 1
        end
    end)
    while f.on do
        for pid in lib.player.list(false) do
            if NetworkEventSpamCount[pid] > 50 and can_player_be_modder(pid, "Network Event Spam") then
                lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Network Event Spam", "Anarchy Modder Detection")
                player.set_player_as_modder(pid, ModderFlags["Network Event Spam"])
            end
            NetworkEventSpamCount[pid] = 0
        end
        system.wait(5000)
    end
    for pid = 0, 31 do
        NetworkEventSpamCount[pid] = 0
    end
    hook.remove_net_event_hook(Event_Hooks["Detection Network Event Spam"])
end)

Local_Parents["Modded Vehicle Modification"] = menu.add_feature("Modded Vehicle Modification", "parent", Local_Parents["Detection"]).id

Local_Feature["Detection Mods"] = menu.add_feature("Mods", "toggle", Local_Parents["Modded Vehicle Modification"], function(f)
    local player_veh_id <const> = {}
    local player_veh_modification <const> = {}
    local player_veh_neon <const> = {}
    local is_toggle_mod_on_1 <const> = {}
    local is_toggle_mod_on_2 <const> = {}
    local is_toggle_mod_on_3 <const> = {}
    local player_veh_wheel_type <const> = {}
    local player_veh_window_tint <const> = {}
    local player_veh_plate_type <const> = {}
    local player_veh_plate_text <const> = {}
    local player_veh_drift_tires <const> = {}
    local player_veh_can_burst <const> = {}
    while f.on do
        if not lib.globals.is_loading() then
            for pid in lib.player.list(false) do
                player_veh_id[pid] = nil
                local entity_owner <const> = network.get_entity_net_owner(player.get_player_vehicle(pid))
                if player.is_player_in_any_vehicle(pid)
                and lib.player.get_spectator_of_player(pid) == nil
                and entity_owner ~= player.player_id()
                and entity_owner ~= nil
                and player.is_player_valid(entity_owner)
                and not entity.is_entity_dead(player.get_player_ped(pid))
                and lib.player.is_player_can_play(pid)
                and not lib.player.is_player_in_interior(pid)
                and can_player_be_modder(pid, "Modded Vehicle Modification")
                then
                    player_veh_id[pid] = player.get_player_vehicle(pid)
                    for _, i in pairs(all_vehicle_mods) do
                        player_veh_modification[pid..i] = vehicle.get_vehicle_mod(player.get_player_vehicle(pid), i)
                    end
                    for _, i in pairs(performance_mods) do
                        player_veh_modification[pid..i] = vehicle.get_vehicle_mod(player.get_player_vehicle(pid), i)
                    end
                    for i = 0, 3 do
                        player_veh_neon[pid..i] = vehicle.is_vehicle_neon_light_enabled(player.get_player_vehicle(pid), i)
                    end
                    is_toggle_mod_on_1[pid] = vehicle.is_toggle_mod_on(player.get_player_vehicle(pid), lib.table.vehicle_mods["Xenon Headlights"])
                    is_toggle_mod_on_2[pid] = vehicle.is_toggle_mod_on(player.get_player_vehicle(pid), lib.table.vehicle_mods["Tire Smoke"])
                    is_toggle_mod_on_3[pid] = vehicle.is_toggle_mod_on(player.get_player_vehicle(pid), lib.table.vehicle_mods["Turbo"])
                    player_veh_wheel_type[pid] = vehicle.get_vehicle_wheel_type(player.get_player_vehicle(pid))
                    player_veh_window_tint[pid] = vehicle.get_vehicle_window_tint(player.get_player_vehicle(pid))
                    player_veh_plate_type[pid] = vehicle.get_vehicle_number_plate_index(player.get_player_vehicle(pid))
                    player_veh_plate_text[pid] = vehicle.get_vehicle_number_plate_text(player.get_player_vehicle(pid))
                    player_veh_drift_tires[pid] = vehicle.get_vehicle_drift_tires(player.get_player_vehicle(pid))
                    player_veh_can_burst[pid] = lib.natives.GET_VEHICLE_TYRES_CAN_BURST(player.get_player_vehicle(pid))
                end
            end
            system.wait(100)
            for pid in lib.player.list(false) do
                local entity_owner <const> = network.get_entity_net_owner(player.get_player_vehicle(pid))
                if player.is_player_in_any_vehicle(pid)
                and lib.player.get_spectator_of_player(pid) == nil
                and entity_owner ~= player.player_id()
                and entity_owner ~= nil
                and player.is_player_valid(entity_owner)
                and not entity.is_entity_dead(player.get_player_ped(pid))
                and lib.player.is_player_can_play(pid)
                and not lib.player.is_player_in_interior(pid)
                and can_player_be_modder(pid, "Modded Vehicle Modification")
                and player_veh_id[pid] == player.get_player_vehicle(pid)
                then
                    for _, i in pairs(all_vehicle_mods) do
                        if vehicle.get_vehicle_mod(player.get_player_vehicle(pid), i) ~= player_veh_modification[pid..i] and can_player_be_modder(pid, "Modded Vehicle Modification") then
                            lua_notify("Player: " .. lib.player.get_player_name(entity_owner) .. "\nReason: Modded Vehicle Modification (" .. lib.essentials.get_name_by_value(lib.table.vehicle_mods, i) .. ")", "Anarchy Modder Detection")
                            player.set_player_as_modder(entity_owner, ModderFlags["Modded Vehicle Modification"])
                        end
                    end
                    for _, i in pairs(performance_mods) do
                        if vehicle.get_vehicle_mod(player.get_player_vehicle(pid), i) ~= player_veh_modification[pid..i] and can_player_be_modder(pid, "Modded Vehicle Modification") then
                            lua_notify("Player: " .. lib.player.get_player_name(entity_owner) .. "\nReason: Modded Vehicle Modification (" .. lib.essentials.get_name_by_value(lib.table.vehicle_mods, i) .. ")", "Anarchy Modder Detection")
                            player.set_player_as_modder(entity_owner, ModderFlags["Modded Vehicle Modification"])
                        end
                    end
                    for i = 0, 3 do
                        if vehicle.is_vehicle_neon_light_enabled(player.get_player_vehicle(pid), i) ~= player_veh_neon[pid..i] and can_player_be_modder(pid, "Modded Vehicle Modification") then
                            lua_notify("Player: " .. lib.player.get_player_name(entity_owner) .. "\nReason: Modded Vehicle Modification (Neon)", "Anarchy Modder Detection")
                            player.set_player_as_modder(entity_owner, ModderFlags["Modded Vehicle Modification"])
                        end
                    end
                    if vehicle.is_toggle_mod_on(player.get_player_vehicle(pid), lib.table.vehicle_mods["Xenon Headlights"]) ~= is_toggle_mod_on_1[pid]
                    or vehicle.is_toggle_mod_on(player.get_player_vehicle(pid), lib.table.vehicle_mods["Tire Smoke"]) ~= is_toggle_mod_on_2[pid]
                    or vehicle.is_toggle_mod_on(player.get_player_vehicle(pid), lib.table.vehicle_mods["Turbo"]) ~= is_toggle_mod_on_3[pid]
                    or vehicle.get_vehicle_wheel_type(player.get_player_vehicle(pid)) ~= player_veh_wheel_type[pid]
                    or vehicle.get_vehicle_window_tint(player.get_player_vehicle(pid)) ~= player_veh_window_tint[pid]
                    or vehicle.get_vehicle_number_plate_index(player.get_player_vehicle(pid)) ~= player_veh_plate_type[pid]
                    or vehicle.get_vehicle_number_plate_text(player.get_player_vehicle(pid)) ~= player_veh_plate_text[pid]
                    or vehicle.get_vehicle_drift_tires(player.get_player_vehicle(pid)) ~= player_veh_drift_tires[pid]
                    or lib.natives.GET_VEHICLE_TYRES_CAN_BURST(player.get_player_vehicle(pid)) ~= player_veh_can_burst[pid]
                    and can_player_be_modder(pid, "Modded Vehicle Modification")
                    then
                        lua_notify("Player: " .. lib.player.get_player_name(entity_owner) .. "\nReason: Modded Vehicle Modification (Other)", "Anarchy Modder Detection")
                        player.set_player_as_modder(entity_owner, ModderFlags["Modded Vehicle Modification"])
                    end
                end
                player_veh_id[pid] = nil
            end
        end
        system.wait()
    end
end)

Local_Feature["Detection Colours"] = menu.add_feature("Colours", "toggle", Local_Parents["Modded Vehicle Modification"], function(f)
    if f.on then
        local player_veh_id <const> = {}
        local player_veh_wheel_colour <const> = {}
        local player_veh_headl_colour <const> = {}
        local player_veh_neon_color <const> = {}
        local player_veh_prim_colour <const> = {}
        local player_veh_sec_colour <const> = {}
        local player_veh_pearlecent_colour <const> = {}
        local player_veh_int_colour <const> = {}
        local player_veh_dash_colour <const> = {}
        while f.on do
            if not lib.globals.is_loading() then
                for pid in lib.player.list(false) do
                    player_veh_id[pid] = nil
                    local entity_owner = network.get_entity_net_owner(player.get_player_vehicle(pid))
                    if player.is_player_in_any_vehicle(pid)
                    and lib.player.get_spectator_of_player(pid) == nil
                    and entity_owner ~= player.player_id()
                    and entity_owner ~= nil
                    and player.is_player_valid(entity_owner)
                    and not entity.is_entity_dead(player.get_player_ped(pid))
                    and lib.player.is_player_can_play(pid)
                    and not lib.player.is_player_in_interior(pid)
                    and can_player_be_modder(pid, "Modded Vehicle Modification")
                    then
                        player_veh_id[pid] = player.get_player_vehicle(pid)
                        player_veh_wheel_colour[pid] = vehicle.get_vehicle_custom_wheel_colour(player.get_player_vehicle(pid))
                        player_veh_headl_colour[pid] = vehicle.get_vehicle_headlight_color(player.get_player_vehicle(pid))
                        player_veh_neon_color[pid] = vehicle.get_vehicle_neon_lights_color(player.get_player_vehicle(pid))
                        player_veh_prim_colour[pid] = vehicle.get_vehicle_custom_primary_colour(player.get_player_vehicle(pid))
                        player_veh_sec_colour[pid] = vehicle.get_vehicle_custom_secondary_colour(player.get_player_vehicle(pid))
                        player_veh_pearlecent_colour[pid] = vehicle.get_vehicle_pearlecent_color(player.get_player_vehicle(pid))
                        player_veh_int_colour[pid] = lib.natives.GET_VEHICLE_EXTRA_COLOUR_5(player.get_player_vehicle(pid))
                        player_veh_dash_colour[pid] = lib.natives.GET_VEHICLE_EXTRA_COLOUR_6(player.get_player_vehicle(pid))
                    end
                end
                system.wait(100)
                for pid in lib.player.list(false) do
                    local entity_owner <const> = network.get_entity_net_owner(player.get_player_vehicle(pid))
                    if player.is_player_in_any_vehicle(pid)
                    and lib.player.get_spectator_of_player(pid) == nil
                    and entity_owner ~= player.player_id()
                    and entity_owner ~= nil
                    and player.is_player_valid(entity_owner)
                    and not entity.is_entity_dead(player.get_player_ped(pid))
                    and lib.player.is_player_can_play(pid)
                    and not lib.player.is_player_in_interior(pid)
                    and can_player_be_modder(pid, "Modded Vehicle Modification")
                    and player_veh_id[pid] == player.get_player_vehicle(pid)
                    then
                        if (player_veh_wheel_colour[pid] ~= nil and vehicle.get_vehicle_custom_wheel_colour(player.get_player_vehicle(pid)) ~= player_veh_wheel_colour[pid])
                        or (player_veh_headl_colour[pid] ~= nil and vehicle.get_vehicle_headlight_color(player.get_player_vehicle(pid)) ~= player_veh_headl_colour[pid])
                        or (player_veh_neon_color[pid] ~= nil and vehicle.get_vehicle_neon_lights_color(player.get_player_vehicle(pid)) ~= player_veh_neon_color[pid])
                        or (player_veh_prim_colour[pid] ~= nil and vehicle.get_vehicle_custom_primary_colour(player.get_player_vehicle(pid)) ~= player_veh_prim_colour[pid])
                        or (player_veh_sec_colour[pid] ~= nil and vehicle.get_vehicle_custom_secondary_colour(player.get_player_vehicle(pid)) ~= player_veh_sec_colour[pid])
                        or (player_veh_pearlecent_colour[pid] ~= nil and vehicle.get_vehicle_pearlecent_color(player.get_player_vehicle(pid)) ~= player_veh_pearlecent_colour[pid])
                        or (player_veh_int_colour[pid] ~= nil and lib.natives.GET_VEHICLE_EXTRA_COLOUR_5(player.get_player_vehicle(pid)) ~= player_veh_int_colour[pid])
                        or (player_veh_dash_colour[pid] ~= nil and lib.natives.GET_VEHICLE_EXTRA_COLOUR_6(player.get_player_vehicle(pid)) ~= player_veh_dash_colour[pid])
                        then
                            lua_notify("Player: " .. lib.player.get_player_name(entity_owner) .. "\nReason: Modded Vehicle Modification (Colours)", "Anarchy Modder Detection")
                            player.set_player_as_modder(entity_owner, ModderFlags["Modded Vehicle Modification"])
                        end
                    end
                end
            end
            system.wait()
        end
    end
end)

Local_Feature["Detection Repair"] = menu.add_feature("Repair", "toggle", Local_Parents["Modded Vehicle Modification"], function(f)
    if f.on then
        local player_veh_id <const> = {}
        local player_veh_repair <const> = {}
        while f.on do
            if not lib.globals.is_loading() then
                for pid in lib.player.list(false) do
                    player_veh_id[pid] = nil
                    local entity_owner <const> = network.get_entity_net_owner(player.get_player_vehicle(pid))
                    if player.is_player_in_any_vehicle(pid)
                    and lib.player.get_spectator_of_player(pid) == nil
                    and entity_owner ~= player.player_id()
                    and entity_owner ~= nil
                    and player.is_player_valid(entity_owner)
                    and not entity.is_entity_dead(player.get_player_ped(pid))
                    and lib.player.is_player_can_play(pid)
                    and not lib.player.is_player_in_interior(pid)
                    and can_player_be_modder(pid, "Modded Vehicle Modification")
                    then
                        player_veh_id[pid] = player.get_player_vehicle(pid)
                        player_veh_repair[pid] = lib.natives.GET_VEHICLE_ENGINE_HEALTH(player.get_player_vehicle(pid))
                    end
                end
                system.wait(100)
                for pid in lib.player.list(false) do
                    local entity_owner <const> = network.get_entity_net_owner(player.get_player_vehicle(pid))
                    if player.is_player_in_any_vehicle(pid)
                    and lib.player.get_spectator_of_player(pid) == nil
                    and entity_owner ~= player.player_id()
                    and entity_owner ~= nil
                    and player.is_player_valid(entity_owner)
                    and not entity.is_entity_dead(player.get_player_ped(pid))
                    and lib.player.is_player_can_play(pid)
                    and not lib.player.is_player_in_interior(pid)
                    and can_player_be_modder(pid, "Modded Vehicle Modification")
                    and player_veh_id[pid] == player.get_player_vehicle(pid)
                    then
                        if lib.natives.GET_VEHICLE_ENGINE_HEALTH(player.get_player_vehicle(pid)) > player_veh_repair[pid] then
                            lua_notify("Player: " .. lib.player.get_player_name(entity_owner) .. "\nReason: Modded Vehicle Modification (Repair)", "Anarchy Modder Detection")
                            player.set_player_as_modder(entity_owner, ModderFlags["Modded Vehicle Modification"])
                        end
                    end
                end
            end
            system.wait()
        end
    end
end)

Local_Parents["Health & Armour"] = menu.add_feature("Health & Armour", "parent", Local_Parents["Detection"]).id

Local_Feature["Detection Modded Health"] = menu.add_feature("Modded Health", "toggle", Local_Parents["Health & Armour"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if not lib.globals.is_loading() and lib.player.is_player_can_play(pid) and can_player_be_modder(pid, "Modded Health") then
                local health <const> = player.get_player_health(pid)
                local max_health <const> = player.get_player_max_health(pid)
                if max_health ~= 2600.0 and max_health ~= 2500.0 and
                (health < 0 or health > 328 or max_health < 238 or max_health > 328 or health > max_health)
                or (health > 0 and not player.is_player_playing(pid) and ped.is_ped_ragdoll(player.get_player_ped(pid))) then
                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Health (" .. health .. "/" .. max_health .. ")", "Anarchy Modder Detection")
                    player.set_player_as_modder(pid, ModderFlags["Modded Health"])
                end
            end
        end
        system.wait(100)
    end
end)

Local_Feature["Detection Modded Armor"] = menu.add_feature("Modded Armor", "toggle", Local_Parents["Health & Armour"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if not lib.globals.is_loading() and lib.player.is_player_can_play(pid) and can_player_be_modder(pid, "Modded Armor") then
                local armour <const> = player.get_player_armour(pid)
                if armour < 0 or armour > 50 then
                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Armor (" .. armour .. ")", "Anarchy Modder Detection")
                    player.set_player_as_modder(pid, ModderFlags["Modded Armor"])
                end
            end
        end
        system.wait(100)
    end
end)

Local_Parents["Modded Explosion"] = menu.add_feature("Modded Explosion", "parent", Local_Parents["Detection"]).id

local Invalid_Source <const> = {}
Local_Feature["Detection Explosion Invalid"] = menu.add_feature("Invalid", "toggle", Local_Parents["Modded Explosion"], function(f)
    if f.on then
        Event_Hooks["Detection Explosion Invalid"] = hook.register_net_event_hook(function(source, target, eventId)
            if eventId == lib.table.net_event["Explosion"] then
                menu.create_thread(function()
                    for explo_name, explosion_types in pairs(lib.table.eExplosionTag) do
                        if lib.natives.IS_EXPLOSION_IN_SPHERE(explosion_types, 0.0, 0.0, 0.0, 30000.0) then
                            local explo_owner <const> = player.get_player_from_ped(lib.natives.GET_OWNER_OF_EXPLOSION_IN_SPHERE(explosion_types, 0.0, 0.0, 0.0, 30000.0))
                            table.insert(Invalid_Source, {source = source, timestamp = utils.time_ms()})

                            local Detection_Explosion_Invalid = false

                            local function modded_explosion(ExplosionTag, explosion_types, weapon_name, pid)
                                if explosion_types == lib.table.eExplosionTag[ExplosionTag] then
                                    if ped.get_current_ped_weapon(player.get_player_ped(pid)) ~= gameplay.get_hash_key(lib.table.weapon[weapon_name]) then
                                        Detection_Explosion_Invalid = true
                                    end
                                end
                            end
                            modded_explosion("Explosive Ammo (Shotgun)", explosion_types, "Pump Shotgun Mk II", source)
                            modded_explosion("Explosive Ammo", explosion_types, "Heavy Sniper Mk II", source)
                            modded_explosion("Up-n-Atomizer", explosion_types, "Up-n-Atomizer", source)
                            modded_explosion("Railgun (MP)", explosion_types, "Railgun (MP)", source)
                            modded_explosion("Railgun (SP)", explosion_types, "Railgun (SP)", source)

                            if explosion_types == lib.table.eExplosionTag["Mine Underwater"]
                            or explosion_types == lib.table.eExplosionTag["Steam"]
                            or explosion_types == lib.table.eExplosionTag["Flame"]
                            or explosion_types == lib.table.eExplosionTag["Water Hydrant"]
                            or explosion_types == lib.table.eExplosionTag["Gas Canister Flame"]
                            or explosion_types == lib.table.eExplosionTag["Flame 2"]
                            or explosion_types == lib.table.eExplosionTag["Extinguisher"]
                            or explosion_types == lib.table.eExplosionTag["Train"]
                            or explosion_types == lib.table.eExplosionTag["Spikes"]
                            or explosion_types == lib.table.eExplosionTag["BZ Gas Mk II"]
                            or explosion_types == lib.table.eExplosionTag["Flash Grenade"]
                            or explosion_types == lib.table.eExplosionTag["Stun Grenade"]
                            or explosion_types == lib.table.eExplosionTag["Kinetic Ram"]
                            or explosion_types == lib.table.eExplosionTag["Bullet"]
                            or explosion_types == lib.table.eExplosionTag["Torpedo (Underwater)"]
                            or explosion_types == lib.table.eExplosionTag["Bomb Water"]
                            or explosion_types == lib.table.eExplosionTag["Bomb Water (Secondary)"]
                            then
                                Detection_Explosion_Invalid = true
                            end

                            if (explosion_types == lib.table.eExplosionTag["Kinetic Mortar"]
                            or explosion_types == lib.table.eExplosionTag["Kinetic Vehicle Mine"]
                            or explosion_types == lib.table.eExplosionTag["EMP Vehicle Mine"]
                            or explosion_types == lib.table.eExplosionTag["Spike Vehicle Mine"]
                            or explosion_types == lib.table.eExplosionTag["Slick Vehicle Mine"]
                            or explosion_types == lib.table.eExplosionTag["Bombushka Cannon"]
                            or explosion_types == lib.table.eExplosionTag["Cluster Bomb (Secondary)"]
                            or explosion_types == lib.table.eExplosionTag["Hunter Barrage"]
                            or explosion_types == lib.table.eExplosionTag["Hunter Cannon"]
                            or explosion_types == lib.table.eExplosionTag["Rogue Cannon"]
                            or explosion_types == lib.table.eExplosionTag["Vakyrie Cannon"]
                            or explosion_types == lib.table.eExplosionTag["Plane Rocket"]
                            or explosion_types == lib.table.eExplosionTag["Vehicle Bullet"]
                            or explosion_types == lib.table.eExplosionTag["Balanced Cannons (F35)"]
                            or explosion_types == lib.table.eExplosionTag["Cluster Bomb"])
                            and not player.is_player_in_any_vehicle(source)
                            and player.get_player_coords(source).z ~= -50
                            then
                                Detection_Explosion_Invalid = true
                            end

                            local function modded_explosion_2(ExplosionTag, explosion_types, vehicle, vehicle2, pid)
                                if explosion_types == lib.table.eExplosionTag[ExplosionTag] then
                                    for i, ent in pairs(vehicle.get_all_vehicles()) do
                                        if (entity.get_entity_model_hash(ent) == gameplay.get_hash_key(vehicle))
                                        or (vehicle2 ~= nil and entity.get_entity_model_hash(ent) == gameplay.get_hash_key(vehicle2))
                                        then
                                            return
                                        end
                                    end
                                    Detection_Explosion_Invalid = true
                                end
                            end
                            modded_explosion_2("Submarine Big", explosion_types, "kosatka", nil, source)
                            modded_explosion_2("Blimp (Blue)", explosion_types, "BLIMP", "blimp3", source)
                            modded_explosion_2("Blimp (Red & Cyan)", explosion_types, "BLIMP2", nil, source)

                            if not lib.globals.is_using_orbital_cannon(source)
                            and explosion_types == lib.table.eExplosionTag["Orbital Cannon"]
                            then
                                Detection_Explosion_Invalid = true
                            end

                            if ((player.get_player_coords(source).z ~= -50 and not player.is_player_in_any_vehicle(source))
                            or (player.is_player_in_any_vehicle(source) and player.get_player_vehicle(source) ~= gameplay.get_hash_key("oppressor2")))
                            and explosion_types == lib.table.eExplosionTag["Oppressor Mk II Cannon"]
                            then
                                Detection_Explosion_Invalid = true
                            end

                            if ((player.get_player_coords(source).z ~= -50 and not player.is_player_in_any_vehicle(source))
                            or (player.is_player_in_any_vehicle(source)
                            and player.get_player_vehicle(source) ~= gameplay.get_hash_key("RHINO")
                            and player.get_player_vehicle(source) ~= gameplay.get_hash_key("khanjali")))
                            and explosion_types == lib.table.eExplosionTag["Tank Shell"]
                            then
                                Detection_Explosion_Invalid = true
                            end

                            if Detection_Explosion_Invalid
                            and lib.player.is_player_can_play(source)
                            and lib.essentials.verif_timestamp_for_table(Invalid_Source, source)
                            and can_player_be_modder(source, "Modded Explosion")
                            then
                                lua_notify("Player: " .. lib.player.get_player_name(source) .. "\nReason: Modded Explosion (Invalid: " .. explo_name .. ")", "Anarchy Modder Detection")
                                player.set_player_as_modder(source, ModderFlags["Modded Explosion"])
                            end
                        end
                        ::skip_invalid_explosion::
                    end
                end)
            end
        end)
    else
        hook.remove_net_event_hook(Event_Hooks["Detection Explosion Invalid"])
    end
end)

local Invalid_v2_Source <const> = {}
Local_Feature["Detection Explosion Invalid v2"] = menu.add_feature("Invalid v2", "toggle", Local_Parents["Modded Explosion"], function(f)
    if f.on then
        Event_Hooks["Detection Explosion Invalid v2"] = hook.register_net_event_hook(function(source, target, eventId)
            if eventId == lib.table.net_event["Explosion"] then
                menu.create_thread(function()
                    for explo_name, explosion_types in pairs(lib.table.eExplosionTag) do
                        if lib.natives.IS_EXPLOSION_IN_SPHERE(explosion_types, 0.0, 0.0, 0.0, 30000.0)
                        and explosion_types ~= lib.table.eExplosionTag["Car"]
                        and explosion_types ~= lib.table.eExplosionTag["Plane"]
                        and explosion_types ~= lib.table.eExplosionTag["Bike"]
                        and explosion_types ~= lib.table.eExplosionTag["Boat"]
                        and explosion_types ~= lib.table.eExplosionTag["Ship"]
                        and explosion_types ~= lib.table.eExplosionTag["Truck"]
                        then
                            local explo_owner <const> = player.get_player_from_ped(lib.natives.GET_OWNER_OF_EXPLOSION_IN_SPHERE(explosion_types, 0.0, 0.0, 0.0, 30000.0))
                            table.insert(Invalid_v2_Source, {source = source, timestamp = utils.time_ms()})
                            if explo_owner == -1
                            and not lib.entity.is_ped_using_any_vehicle(player.get_player_ped(source))
                            and lib.essentials.verif_timestamp_for_table(Invalid_v2_Source, source)
                            and can_player_be_modder(source, "Modded Explosion")
                            then
                                lua_notify("Player: " .. lib.player.get_player_name(source) .. "\nReason: Modded Explosion (Invalid v2)", "Anarchy Modder Detection")
                                player.set_player_as_modder(source, ModderFlags["Modded Explosion"])
                            end
                        end
                    end
                end)
            end
        end)
    else
        hook.remove_net_event_hook(Event_Hooks["Detection Explosion Invalid v2"])
    end
end)

local Blam_Source <const> = {}
Local_Feature["Detection Explosion Blaming"] = menu.add_feature("Blaming", "toggle", Local_Parents["Modded Explosion"], function(f)
    if f.on then
        Event_Hooks["Detection Explosion Blaming"] = hook.register_net_event_hook(function(source, target, eventId)
            if eventId == lib.table.net_event["Explosion"] then
                menu.create_thread(function()
                    for _, explosion_types in pairs(lib.table.eExplosionTag) do
                        if lib.natives.IS_EXPLOSION_IN_SPHERE(explosion_types, 0.0, 0.0, 0.0, 30000.0)
                        and explosion_types ~= lib.table.eExplosionTag["Car"]
                        and explosion_types ~= lib.table.eExplosionTag["Plane"]
                        and explosion_types ~= lib.table.eExplosionTag["Bike"]
                        and explosion_types ~= lib.table.eExplosionTag["Boat"]
                        and explosion_types ~= lib.table.eExplosionTag["Ship"]
                        and explosion_types ~= lib.table.eExplosionTag["Truck"]
                        then
                            local explo_owner <const> = player.get_player_from_ped(lib.natives.GET_OWNER_OF_EXPLOSION_IN_SPHERE(explosion_types, 0.0, 0.0, 0.0, 30000.0))
                            table.insert(Blam_Source, {source = source, timestamp = utils.time_ms()})
                            if source ~= explo_owner
                            and explo_owner ~= -1
                            and not lib.entity.is_ped_using_any_vehicle(player.get_player_ped(source))
                            and lib.essentials.verif_timestamp_for_table(Blam_Source, source)
                            and can_player_be_modder(source, "Modded Explosion")
                            then
                                lua_notify("Player: " .. lib.player.get_player_name(source) .. "\nReason: Modded Explosion (Blaming)", "Anarchy Modder Detection")
                                player.set_player_as_modder(source, ModderFlags["Modded Explosion"])
                            end
                        end
                    end
                end)
            end
        end)
    else
        hook.remove_net_event_hook(Event_Hooks["Detection Explosion Blaming"])
    end
end)

Local_Parents["Modded Movement"] = menu.add_feature("Modded Movement", "parent", Local_Parents["Detection"]).id

Local_Feature["Detection Movement Invalid"] = menu.add_feature("Invalid", "toggle", Local_Parents["Modded Movement"], function(f)
    if f.on then
        for pid = 0, 31 do
            Invalid_Movement_Ctr[pid] = 0
        end
    end
    while f.on do
        if not lib.globals.is_loading() then
            for pid in lib.player.list(false) do
                local speed_with_pos <const> = lib.entity.get_entity_speed_with_pos(player.get_player_ped(pid))
                local plyr_veh <const> = player.get_player_vehicle(pid)
                if not player.is_player_in_any_vehicle(pid)
                and not lib.player.is_player_in_interior(pid)
                and lib.player.is_player_can_play_soft(pid)
                and speed_with_pos > 5
                and entity.get_entity_speed(player.get_player_ped(pid)) == 0
                and entity.get_entity_velocity(player.get_player_ped(pid)) == v3(0.0, 0.0, 0.0)
                and lib.natives.GET_PED_PARACHUTE_STATE(player.get_player_ped(pid)) ~= 1
                and lib.natives.GET_PED_PARACHUTE_STATE(player.get_player_ped(pid)) ~= 2
                and can_player_be_modder(pid, "Modded Movement")
                then
                    Invalid_Movement_Ctr[pid] = Invalid_Movement_Ctr[pid] + 1
                    if Invalid_Movement_Ctr[pid] > 2 then
                        lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Movement (Invalid)", "Anarchy Modder Detection")
                        player.set_player_as_modder(pid, ModderFlags["Modded Movement"])
                    end
                else
                    Invalid_Movement_Ctr[pid] = 0
                end
            end
        end
        system.wait(100)
    end
    if not f.on then
        for pid = 0, 31 do
            Invalid_Movement_Ctr[pid] = 0
        end
    end
end)

Local_Feature["Detection Movement Ped Speed"] = menu.add_feature("Ped Speed", "toggle", Local_Parents["Modded Movement"], function(f)
    while f.on do
        if not lib.globals.is_loading() then
            for pid in lib.player.list(false) do
                local speed_with_pos <const> = lib.entity.get_entity_speed_with_pos(player.get_player_ped(pid))
                if not lib.player.is_player_in_interior(pid)
                and lib.player.is_player_can_play(pid)
                and speed_with_pos > 40
                and not lib.natives.IS_PED_ON_VEHICLE(player.get_player_ped(pid))
                and not lib.natives.IS_PED_JUMPING_OUT_OF_VEHICLE(player.get_player_ped(pid))
                and not lib.natives.IS_PED_FALLING(player.get_player_ped(pid))
                and not lib.natives.IS_PED_IN_PARACHUTE_FREE_FALL(player.get_player_ped(pid))
                and lib.natives.GET_PED_PARACHUTE_STATE(player.get_player_ped(pid)) ~= 1
                and lib.natives.GET_PED_PARACHUTE_STATE(player.get_player_ped(pid)) ~= 2
                and not ai.is_task_active(player.get_player_ped(pid), 422)
                and not player.is_player_in_any_vehicle(pid)
                and not ped.is_ped_ragdoll(player.get_player_ped(pid))
                and can_player_be_modder(pid, "Modded Movement")
                then
                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Movement (Ped Speed)", "Anarchy Modder Detection")
                    player.set_player_as_modder(pid, ModderFlags["Modded Movement"])
                end
            end
        end
        system.wait()
    end
end)

Local_Feature["Detection Movement Vehicle Speed"] = menu.add_feature("Vehicle Speed", "toggle", Local_Parents["Modded Movement"], function(f)
    if f.on then
        for pid = 0, 31 do
            Invalid_Vehicle_Speed_Ctr[pid] = 0
        end
    end
    while f.on do
        if not lib.globals.is_loading() then
            for pid in lib.player.list(false) do
                local plyr_veh <const> = player.get_player_vehicle(pid)
                local speed_with_pos <const> = lib.entity.get_entity_speed_with_pos(plyr_veh)
                local max_speed <const> = vehicle.get_vehicle_estimated_max_speed(plyr_veh)
                if not lib.player.is_player_in_interior(pid)
                and lib.player.is_player_can_play(pid)
                and not lib.entity.is_entity_in_interior(plyr_veh)
                and lib.player.is_player_driver(pid)
                and vehicle.get_vehicle_class(plyr_veh) ~= lib.table.eVehicleClass["Helicopters"]
                and vehicle.get_vehicle_class(plyr_veh) ~= lib.table.eVehicleClass["Planes"]
                and (speed_with_pos > 80 or max_speed > 60)
                and can_player_be_modder(pid, "Modded Movement")
                then
                    Invalid_Vehicle_Speed_Ctr[pid] = Invalid_Vehicle_Speed_Ctr[pid] + 1
                    if Invalid_Vehicle_Speed_Ctr[pid] > 2 then
                        local veh_owner <const> = network.get_entity_net_owner(plyr_veh)
                        lua_notify("Player: " .. lib.player.get_player_name(veh_owner) .. "\nReason: Modded Movement (Vehicle Speed)", "Anarchy Modder Detection")
                        player.set_player_as_modder(veh_owner, ModderFlags["Modded Movement"])
                    end
                else
                    Invalid_Vehicle_Speed_Ctr[pid] = 0
                end
            end
        end
        system.wait(100)
    end
    if not f.on then
        for pid = 0, 31 do
            Invalid_Vehicle_Speed_Ctr[pid] = 0
        end
    end
end)

Local_Parents["Invincible"] = menu.add_feature("Invincible", "parent", Local_Parents["Detection"]).id

local Task_Detecte_Invincible <const> = {3, 4, 8, 9, 56, 128, 129, 130, 131, 190, 286, 287, 289, 290, 291, 296, 298, 335, 342, 360, 383, 422, 425, 432}

Local_Feature["Detection Player Invincible"] = menu.add_feature("Player Invincible", "toggle", Local_Parents["Invincible"], function(f)
    if f.on then
        for pid = 0, 31 do
            Player_Invincible_Ctr[pid] = 0
        end
    end
    while f.on do
        for pid in lib.player.list(false) do
            local plyr_ped <const> = player.get_player_ped(pid)
            if not lib.globals.is_loading()
            and can_player_be_modder(pid, "Player Invincible")
            and not lib.player.is_player_in_interior(pid)
            and lib.player.is_player_can_play(pid)
            then
                for i = 1, #Task_Detecte_Invincible do
                    if lib.player.is_god(pid)
                    and (ai.is_task_active(plyr_ped, Task_Detecte_Invincible[i])
                    or ped.is_ped_ragdoll(plyr_ped)
                    or ped.is_ped_swimming(plyr_ped)
                    or ped.is_ped_swimming_underwater(plyr_ped)
                    or ped.is_ped_shooting(plyr_ped)
                    or lib.natives.IS_PED_SPRINTING(plyr_ped)
                    or player.is_player_free_aiming(pid))
                    then
                        if can_player_be_modder(pid, "Player Invincible") then
                            lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Player Invincible", "Anarchy Modder Detection")
                            player.set_player_as_modder(pid, ModderFlags["Player Invincible"])
                        end
                    end
                end
            end
            if not lib.globals.is_loading()
            and can_player_be_modder(pid, "Player Invincible")
            and not lib.player.is_player_in_interior(pid)
            and lib.player.is_player_can_play(pid)
            and (lib.entity.get_entity_speed_with_pos(plyr_ped) ~= 0 or lib.entity.get_entity_speed_with_pos_under_map(plyr_ped) ~= 0)
            and lib.player.is_god(pid)
            then
                Player_Invincible_Ctr[pid] = Player_Invincible_Ctr[pid] + 1
                if Player_Invincible_Ctr[pid] > 5 then
                    if can_player_be_modder(pid, "Player Invincible") then
                        lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Player Invincible", "Anarchy Modder Detection")
                        player.set_player_as_modder(pid, ModderFlags["Player Invincible"])
                    end
                end
            else
                Player_Invincible_Ctr[pid] = 0
            end
        end
        system.wait(100)
    end
    if not f.on then
        for pid = 0, 31 do
            Player_Invincible_Ctr[pid] = 0
        end
    end
end)

Local_Feature["Detection Vehicle Invincible"] = menu.add_feature("Vehicle Invincible", "toggle", Local_Parents["Invincible"], function(f)
    if f.on then
        for pid = 0, 31 do
            Vehicle_Invincible_Ctr[pid] = 0
        end
    end
    while f.on do
        for pid in lib.player.list(false) do
            local plyr_veh <const> = player.get_player_vehicle(pid)
            if not lib.globals.is_loading()
            and can_player_be_modder(pid, "Vehicle Invincible")
            and lib.player.is_player_driver(pid)
            and not lib.player.is_player_in_interior(pid)
            and not lib.entity.is_entity_in_interior(plyr_veh)
            and lib.player.is_player_can_play(pid)
            then
                for i = 1, #Task_Detecte_Invincible do
                    if ai.is_task_active(player.get_player_ped(pid), Task_Detecte_Invincible[i])
                    or entity.is_entity_in_water(plyr_veh)
                    or entity.get_entity_speed(player.get_player_vehicle(pid)) > 5 then
                        if lib.entity.is_god(plyr_veh) then
                            if can_player_be_modder(pid, "Vehicle Invincible") then
                                lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Vehicle Invincible", "Anarchy Modder Detection")
                                player.set_player_as_modder(pid, ModderFlags["Vehicle Invincible"])
                            end
                        end
                    end
                end
            end
            local speed_with_pos <const> = lib.entity.get_entity_speed_with_pos(plyr_veh)
            if not lib.globals.is_loading()
            and can_player_be_modder(pid, "Vehicle Invincible")
            and not lib.player.is_player_in_interior(pid)
            and lib.player.is_player_can_play(pid)
            and not lib.entity.is_entity_in_interior(plyr_veh)
            and lib.player.is_player_driver(pid)
            and speed_with_pos ~= 0
            and lib.entity.is_god(plyr_veh) then
                Vehicle_Invincible_Ctr[pid] = Vehicle_Invincible_Ctr[pid] + 1
                if Vehicle_Invincible_Ctr[pid] > 5 then
                    if can_player_be_modder(pid, "Vehicle Invincible") then
                        lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Vehicle Invincible", "Anarchy Modder Detection")
                        player.set_player_as_modder(pid, ModderFlags["Vehicle Invincible"])
                    end
                end
            else
                Vehicle_Invincible_Ctr[pid] = 0
            end
        end
        system.wait(100)
    end
    if not f.on then
        for pid = 0, 31 do
            Vehicle_Invincible_Ctr[pid] = 0
        end
    end
end)

Local_Parents["Flags"] = menu.add_feature("Flags", "parent", Local_Parents["Detection"]).id

Local_Feature["Cheater Flags"] = menu.add_feature("Cheater Flags", "toggle", Local_Parents["Flags"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if lib.natives.NETWORK_PLAYER_INDEX_IS_CHEATER(pid) and can_player_be_modder(pid, "Flags") then
                lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Cheater Flags", "Anarchy Modder Detection")
                player.set_player_as_modder(pid, ModderFlags["Flags"])
            end
        end
        system.wait(1000)
    end
end)

Local_Feature["Dev Flags"] = menu.add_feature("Dev Flags", "toggle", Local_Parents["Flags"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if lib.natives.NETWORK_PLAYER_IS_ROCKSTAR_DEV(pid) and can_player_be_modder(pid, "Flags") then
                lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Dev Flags", "Anarchy Modder Detection")
                player.set_player_as_modder(pid, ModderFlags["Flags"])
            end
        end
        system.wait(1000)
    end
end)

Local_Feature["Detection Modded Off The Radar"] = menu.add_feature("Modded Off The Radar", "toggle", Local_Parents["Detection"], function(f)
    if f.on then
        for pid = 0, 31 do
            IsOTRForExtended[pid] = 0
            IsOTRForExtendedCEO[pid] = 0
        end
    end
    while f.on do
        if not lib.globals.is_loading() then
            for pid in lib.player.list(false) do
                if lib.globals.is_player_otr(pid) and not lib.player.is_player_in_interior(pid) then
                    if not lib.globals.is_player_organization(pid) then
                        IsOTRForExtended[pid] = IsOTRForExtended[pid] + 1
                    else
                        IsOTRForExtended[pid] = 0
                    end
                    if lib.globals.is_player_organization(pid) then
                        IsOTRForExtendedCEO[pid] = IsOTRForExtendedCEO[pid] + 1
                    else
                        IsOTRForExtendedCEO[pid] = 0
                    end
                end
                if (IsOTRForExtended[pid] > 62 or IsOTRForExtendedCEO[pid] > 182) and can_player_be_modder(pid, "Modded Off The Radar") then
                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Off The Radar", "Anarchy Modder Detection")
                    player.set_player_as_modder(pid, ModderFlags["Modded Off The Radar"])
                end
            end
        end
        system.wait(1000)
    end
    if not f.on then
        for pid = 0, 31 do
            IsOTRForExtended[pid] = 0
            IsOTRForExtendedCEO[pid] = 0
        end
    end
end)

local script_exec <const> = {
    "am_destroy_veh",
    "debug",
    "freemode_creator",
    "fm_deathmatch_controler",
    "am_dead_drop",
    "am_distract_cops",
    "am_plane_takedown",
    "fm_mission_controller",
    "golf_mp",
    "tennis_network_mp",
    "range_modern_mp",
    "fm_race_controler"
}

Local_Feature["Modded Script Execution"] = menu.add_feature("Modded Script Execution", "toggle", Local_Parents["Detection"], function(f)
    while f.on do
        if not lib.globals.is_loading() then
            for i = 1, #script_exec do
                local pid <const> = lib.natives.NETWORK_GET_HOST_OF_SCRIPT(script_exec[i], -1, 0)
                if pid ~= -1 and pid ~= nil and can_player_be_modder(pid, "Modded Script Execution") then
                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Script Execution (" .. script_exec[i] .. ")", "Anarchy Modder Detection")
                    player.set_player_as_modder(pid, ModderFlags["Modded Script Execution"])
                end
            end
        end
        system.wait(100)
    end
end)

Local_Feature["Detection Admin"] = menu.add_feature("Admin", "toggle", Local_Parents["Detection"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if can_player_be_modder(pid, "Admin") then
                for _, admin in pairs(lib.table.admin) do
                    if player.get_player_name(pid) == admin then
                        lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Admin", "Anarchy Modder Detection")
                        player.set_player_as_modder(pid, ModderFlags["Admin"])
                    end
                end
            end
        end
        system.wait(100)
    end
end)

Local_Feature["Detection Modded Orbital Cannon"] = menu.add_feature("Modded Orbital Cannon", "toggle", Local_Parents["Detection"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if lib.globals.is_using_orbital_cannon(pid) and not ai.is_task_active(player.get_player_ped(pid), 135) and can_player_be_modder(pid, "Modded Orbital Cannon") then
                lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Orbital Cannon", "Anarchy Modder Detection")
                player.set_player_as_modder(pid, ModderFlags["Modded Orbital Cannon"])
            end
        end
        system.wait(100)
    end
end)

Local_Feature["Detection Modded Weapon"] = menu.add_feature("Modded Weapon", "toggle", Local_Parents["Detection"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if not lib.globals.is_loading() and can_player_be_modder(pid, "Modded Weapon") then
                for i, hash in ipairs(Modded_Weapons) do
                    local weapon_hash <const> = gameplay.get_hash_key(hash)
                    if weapon.has_ped_got_weapon(player.get_player_ped(pid), weapon_hash) then
                        lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Weapon (" .. lib.essentials.get_name_by_value(lib.table.weapon, hash) .. ")", "Anarchy Modder Detection")
                        player.set_player_as_modder(pid, ModderFlags["Modded Weapon"])
                    end
                end
            end
        end
        system.wait(100)
    end
end)

Local_Feature["Detection Modded Spectate"] = menu.add_feature("Modded Spectate", "toggle", Local_Parents["Detection"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if not lib.globals.is_loading() and can_player_be_modder(pid, "Modded Spectate") then
                if player.is_player_spectating(pid) and not lib.player.is_player_in_interior(pid) and not entity.is_entity_dead(player.get_player_ped(pid)) then
                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Spectate", "Anarchy Modder Detection")
                    player.set_player_as_modder(pid, ModderFlags["Modded Spectate"])
                end
            end
        end
        system.wait(100)
    end
end)

--[[
Local_Feature["Detection Unreleased Vehicle"] = menu.add_feature("Unreleased Vehicle", "toggle", Local_Parents["Detection"], function(f)
    while f.on do
        for i, ent in pairs(vehicle.get_all_vehicles()) do
            if lib.entity.is_script_entity(ent) then
                local ent_hash <const> = entity.get_entity_model_hash(ent)
                for i, hash in ipairs(Unreleased_Vehicles) do
                    if ent_hash == gameplay.get_hash_key(hash) then
                        local plyr_creator <const> = lib.entity.get_entity_creator(ent)
                        if not lib.globals.is_loading() and can_player_be_modder(plyr_creator, "Unreleased Vehicle") then
                            lua_notify("Player: " .. lib.player.get_player_name(plyr_creator) .. "\nReason: Unreleased Vehicle (" .. lib.entity.get_hash_name(ent_hash) .. ")", "Anarchy Modder Detection")
                            player.set_player_as_modder(plyr_creator, ModderFlags["Unreleased Vehicle"])
                        end
                    end
                end
            end
        end
        system.wait(100)
    end
end)
]]

Local_Feature["Detection Silent Aimbot"] = menu.add_feature("Silent Aimbot", "toggle", Local_Parents["Detection"], function(f)
    if f.on then
        for pid = 0, 31 do
            Silent_Aim[pid] = false
        end
        Event_Hooks["Detection Silent Aimbot"] = hook.register_net_event_hook(function(source, target, eventId)
            if eventId == lib.table.net_event["Special Fire Equipped Weapon"] then
                Silent_Aim[source] = true
            end
        end)
    end
    while f.on do
        for pid in lib.player.list(false) do
            if Silent_Aim[pid] then
                system.wait(500)
                if not entity.is_entity_dead(player.get_player_ped(pid)) and can_player_be_modder(pid, "Silent Aimbot") then
                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Silent Aimbot", "Anarchy Modder Detection")
                    player.set_player_as_modder(pid, ModderFlags["Silent Aimbot"])
                end
                Silent_Aim[pid] = false
            end
        end
        system.wait()
    end
    if not f.on then
        for pid = 0, 31 do
            Silent_Aim[pid] = false
        end
        hook.remove_script_event_hook(Event_Hooks["Detection Silent Aimbot"])
    end
end)

local Tracks <const> = {}
Local_Feature["Detection Super Jump"] = menu.add_feature("Super Jump", "toggle", Local_Parents["Detection"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if not lib.globals.is_loading() and can_player_be_modder_2(pid, 1 << 0x12) then
                if not player.is_player_in_any_vehicle(pid) and (not Tracks[pid] or utils.time_ms() > Tracks[pid][2]) then
                    if not Tracks[pid] or utils.time_ms() > Tracks[pid][2] + 1000 then
                        Tracks[pid] = {player.get_player_coords(pid), utils.time_ms() + 1000}
                    else
                        if player.get_player_coords(pid).z - Tracks[pid][1].z > 10 and ai.is_task_active(player.get_player_ped(pid), 422) then
                            lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Super Jump", "Anarchy Modder Detection")
                            player.set_player_as_modder(pid, 1 << 0x12)
                        end
                        Tracks[pid] = nil
                    end
                end
            end
        end
        system.wait()
    end
end)

Local_Feature["Detection Fast Join"] = menu.add_feature("Fast Join", "toggle", Local_Parents["Detection"], function(f)
    while f.on do
        local old_sh <const> = script.get_host_of_this_script()
        system.wait(100)
        local new_sh <const> = script.get_host_of_this_script()
        if not lib.globals.is_loading() and new_sh ~= old_sh and new_sh ~= -1 and new_sh ~= nil and old_sh ~= -1 and old_sh ~= nil and lib.globals.get_spawn_state(new_sh) == 0 and can_player_be_modder(new_sh, "Fast Join") then
            lua_notify("Player: " .. lib.player.get_player_name(new_sh) .. "\nReason: Fast Join", "Anarchy Modder Detection")
            player.set_player_as_modder(new_sh, ModderFlags["Fast Join"])
        end
    end
end)

Local_Parents["Protection"] = menu.add_feature("Protection", "parent", Local_Parents["Local Prents"]).id

Local_Parents["Auto Kick Detection"] = menu.add_feature("Auto Kick Detection", "parent", Local_Parents["Protection"]).id

Local_Feature["Enable Auto Kick Detection"] = menu.add_feature("Enable", "toggle", Local_Parents["Auto Kick Detection"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            for i = 1, #flag_modder_detection do
                if Local_Feature["Kick: " .. flag_modder_detection[i]].on and player.is_player_modder(pid, player.add_modder_flag(flag_modder_detection[i])) then
                    if Local_Feature["Notify Auto Kick Detection"].on then
                        lua_notify(lib.player.get_player_name(pid) .. " is kick from the session.", f.name)
                    end
                    lib.player.smart_kick_player(pid)
                end
            end
        end
        system.wait(100)
    end
end)

Local_Feature["Notify Auto Kick Detection"] = menu.add_feature("Notify", "toggle", Local_Parents["Auto Kick Detection"], function(f)
end)

Local_Feature["Whitelist Friend Auto Kick Detection"] = menu.add_feature("Whitelist Friend", "toggle", Local_Parents["Auto Kick Detection"], function(f)
end)

Local_Parents["Detection Settings"] = menu.add_feature("Detection Settings", "parent", Local_Parents["Auto Kick Detection"]).id

Local_Feature["All Detection Auto Kick"] = menu.add_feature("All Detection", "action_value_str", Local_Parents["Detection Settings"], function(f)
    for i = 1, #flag_modder_detection do
        if f.value == 0 then
            Local_Feature["Kick: " .. flag_modder_detection[i]].on = true
        elseif f.value == 1 then
            Local_Feature["Kick: " .. flag_modder_detection[i]].on = false
        end
    end
end)
Local_Feature["All Detection Auto Kick"]:set_str_data({"Enable", "Disable"})

for _, key in ipairs(lib.essentials.sort_table_alphabetically("right", flag_modder_detection)) do
    Local_Feature["Kick: " .. key.right] = menu.add_feature("Kick: " .. key.right, "toggle", Local_Parents["Detection Settings"], function(f)
    end)
end

Local_Parents["Auto Kick Network Event"] = menu.add_feature("Auto Kick Network Event", "parent", Local_Parents["Protection"]).id

Local_Feature["Enable Auto Kick Detection"] = menu.add_feature("Enable", "toggle", Local_Parents["Auto Kick Network Event"], function(f)
    if f.on then
        Event_Hooks["Auto Kick Network Event"] = hook.register_net_event_hook(function(source, target, eventId)
            if Local_Feature["Kick: " .. lib.essentials.get_name_by_value(lib.table.net_event, eventId)].on
            and (not Local_Feature["Whitelist Friend Auto Kick Network Event"].on or not player.is_player_friend(pid))
            then
                if Local_Feature["Notify Auto Kick Network Event"].on then
                    lua_notify(lib.player.get_player_name(source) .. " is kick from the session.", f.name)
                end
                lib.player.smart_kick_player(source)
            end
        end)
    end
    if not f.on then
        hook.remove_script_event_hook(Event_Hooks["Auto Kick Network Event"])
    end
end)

Local_Feature["Notify Auto Kick Network Event"] = menu.add_feature("Notify", "toggle", Local_Parents["Auto Kick Network Event"], function(f)
end)

Local_Feature["Whitelist Friend Auto Kick Network Event"] = menu.add_feature("Whitelist Friend", "toggle", Local_Parents["Auto Kick Network Event"], function(f)
end)

Local_Parents["Network Event Settings"] = menu.add_feature("Network Event Settings", "parent", Local_Parents["Auto Kick Network Event"]).id

Local_Feature["All Network Event Auto Kick"] = menu.add_feature("All Network Event", "action_value_str", Local_Parents["Network Event Settings"], function(f)
    for name, i in pairs(lib.table.net_event) do
        if f.value == 0 then
            Local_Feature["Kick: " .. lib.essentials.get_name_by_value(lib.table.net_event, i)].on = true
        elseif f.value == 1 then
            Local_Feature["Kick: " .. lib.essentials.get_name_by_value(lib.table.net_event, i)].on = false
        end
    end
end)
Local_Feature["All Network Event Auto Kick"]:set_str_data({"Enable", "Disable"})

for _, key in ipairs(lib.essentials.sort_table_alphabetically("left", lib.table.net_event)) do
    Local_Feature["Kick: " .. key.left] = menu.add_feature("Kick: " .. key.left, "toggle", Local_Parents["Network Event Settings"], function(f)
    end)
end

Local_Parents["Auto Ghost Players"] = menu.add_feature("Auto Ghost Players", "parent", Local_Parents["Protection"]).id

Local_Feature["Armed"] = menu.add_feature("Armed", "toggle", Local_Parents["Auto Ghost Players"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            local ped <const> = player.get_player_ped(pid)
            if lib.natives.IS_PED_ARMED(ped, 7) or ai.is_task_active(ped, 199) or ai.is_task_active(ped, 128) then
                lib.natives.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
            else
                lib.natives.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
            end
        end
        system.wait(100)
    end
end)

Local_Feature["Using Drone"] = menu.add_feature("Using Drone", "toggle", Local_Parents["Auto Ghost Players"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if lib.globals.is_flying_drone(pid) then
                lib.natives.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
            else
                lib.natives.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
            end
        end
        system.wait(100)
    end
end)

Local_Feature["Using RC Tank"] = menu.add_feature("Using RC Tank", "toggle", Local_Parents["Auto Ghost Players"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if lib.globals.is_in_rc_tank(pid) then
                lib.natives.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
            else
                lib.natives.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
            end
        end
        system.wait(100)
    end
end)

Local_Feature["Using RC Bandito"] = menu.add_feature("Using RC Bandito", "toggle", Local_Parents["Auto Ghost Players"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if lib.globals.is_in_rc_bandito(pid) then
                lib.natives.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
            else
                lib.natives.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
            end
        end
        system.wait(100)
    end
end)

Local_Feature["Using Guided Missile"] = menu.add_feature("Using Guided Missile", "toggle", Local_Parents["Auto Ghost Players"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if lib.globals.is_using_guided_missile(pid) then
                lib.natives.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
            else
                lib.natives.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
            end
        end
        system.wait(100)
    end
end)

Local_Feature["Using Orbital Cannon"] = menu.add_feature("Using Orbital Cannon", "toggle", Local_Parents["Auto Ghost Players"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if lib.globals.is_using_orbital_cannon(pid) then
                lib.natives.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
            else
                lib.natives.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
            end
        end
        system.wait(100)
    end
end)

Local_Feature["Block Transaction Error"] = menu.add_feature("Block Transaction Error", "toggle", Local_Parents["Protection"], function(f)
end)

Local_Feature["Block Sync For (Seconds)"] = menu.add_feature("Block Sync For (Seconds)", "value_i", Local_Parents["Protection"], function(f)
    local log_2take1, Treated_Line, pids
    if f.on then
        log_2take1 = io.open(Log_File, "r")
        log_2take1:seek("end")
        Treated_Line = {}
        Listeners["Crash Detection"] = event.add_event_listener("modder", function(modder)
            if string.find(player.get_modder_flag_text(modder.flag):lower(), "crash") and not Anarchy_Timeout[modder.player] then
                lib.player.block_sync(modder.player, Local_Feature["Block Sync For (Seconds)"].value * 1000)
                lua_notify("Sync blocked for " .. Local_Feature["Block Sync For (Seconds)"].value .. " seconds for " .. lib.player.get_player_name(modder.player) .. ".", "Anarchy Modder Detection")
            end
        end)
    end
    while f.on do
        local line = log_2take1:read("*line")
        if line and not Treated_Line[line] and line:find("Crash Protection") then
            pids = nil
            for pid in lib.player.list(false) do
                if line:find(lib.player.get_player_name(pid)) then
                    pids = pid
                end
            end
            if pids and not Anarchy_Timeout[pids] then
                lib.player.block_sync(pids, Local_Feature["Block Sync For (Seconds)"].value * 1000)
                lua_notify("Sync blocked for " .. Local_Feature["Block Sync For (Seconds)"].value .. " seconds for " .. lib.player.get_player_name(pids) .. ".", "Anarchy Modder Detection")
            end
            Treated_Line[line] = true
        end
        system.wait()
    end
    if not f.on then
        log_2take1:close()
        event.remove_event_listener("modder", Listeners["Crash Detection"])
    end
end)
Local_Feature["Block Sync For (Seconds)"].max = 30
Local_Feature["Block Sync For (Seconds)"].min = 1
Local_Feature["Block Sync For (Seconds)"].mod = 1
Local_Feature["Block Sync For (Seconds)"].value = 5

Local_Feature["Block Taylor Swift Crash"] = menu.add_feature("Block Taylor Swift Crash", "value_str", Local_Parents["Protection"], function(f)
    while f.on do
        for pid in lib.player.list(false) do
            if ped.get_current_ped_weapon(player.get_player_ped(pid)) == 0 then
                menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".block.block_net_cunts").on = true
                local time <const> = utils.time_ms() + 1000
                while time > utils.time_ms() do
                    if ped.get_current_ped_weapon(player.get_player_ped(pid)) == 966099553 then
                        lua_notify("Blocking Taylor Swift Crash by " .. lib.player.get_player_name(pid), "Crash Protection")
                        if f.value == 0 and can_player_be_modder(pid, "Taylor Swift Crash") then
                            lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Taylor Swift Crash", "Anarchy Modder Detection")
                            player.set_player_as_modder(pid, ProtectionFlags["Taylor Swift Crash"])
                        end
                        goto Skip_Taylor_Swift
                    end
                    if ped.get_current_ped_weapon(player.get_player_ped(pid)) ~= 966099553 and ped.get_current_ped_weapon(player.get_player_ped(pid)) ~= 0 then
                        menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".block.block_net_cunts").on = false
                    end
                    system.wait()
                end
                menu.get_feature_by_hierarchy_key("online.online_players.player_" .. pid .. ".block.block_net_cunts").on = false
            end
            ::Skip_Taylor_Swift::
        end
        system.wait()
    end
end)
Local_Feature["Block Taylor Swift Crash"]:set_str_data({"Block & Notify", "Block"})

Local_Feature["Block Crash"] = menu.add_feature("Block Crash", "value_str", Local_Parents["Protection"], function(f)
    while f.on do
        if not lib.globals.is_loading() then
            local crash_hunter_count = 0
            local crash_chernobog_count = 0
            for i, ent in pairs(vehicle.get_all_vehicles()) do
                if entity.get_entity_model_hash(ent) == gameplay.get_hash_key("hunter") then
                    crash_hunter_count = crash_hunter_count + 1
                    if crash_hunter_count > 3 then
                        local pid
                        if lib.entity.is_script_entity(ent) then
                            pid = lib.entity.get_entity_creator(ent)
                        else
                            pid = network.get_entity_net_owner(ent)
                        end
                        if pid ~= nil and pid ~= player.player_id() then
                            if f.value == 0 and can_player_be_modder_2(pid, 1 << 0x0D) then
                                lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Net Sync Crash (Hunter)", "Anarchy Modder Detection")
                                player.set_player_as_modder(pid, 1 << 0x0D)
                            end
                            lib.player.block_sync(pid, 10000)
                            entity.freeze_entity(ent, true)
                            entity.set_entity_as_no_longer_needed(ent)
                            entity.set_entity_coords_no_offset(ent, v3(8000, 8000, -1000))
                        end
                    end
                end
                if entity.get_entity_model_hash(ent) == gameplay.get_hash_key("chernobog") then
                    crash_chernobog_count = crash_chernobog_count + 1
                    if crash_chernobog_count > 3 then
                        local pid
                        if lib.entity.is_script_entity(ent) then
                            pid = lib.entity.get_entity_creator(ent)
                        else
                            pid = network.get_entity_net_owner(ent)
                        end
                        if pid ~= nil and pid ~= player.player_id() then
                            if f.value == 0 and can_player_be_modder_2(pid, 1 << 0x0D) then
                                lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Net Sync Crash (Chernobog)", "Anarchy Modder Detection")
                                player.set_player_as_modder(pid, 1 << 0x0D)
                            end
                            lib.player.block_sync(pid, 10000)
                            entity.freeze_entity(ent, true)
                            entity.set_entity_as_no_longer_needed(ent)
                            entity.set_entity_coords_no_offset(ent, v3(8000, 8000, -1000))
                        end
                    end
                end
            end
        end
        system.wait()
    end
end)
Local_Feature["Block Crash"]:set_str_data({"Block & Notify", "Block"})

local lag_entity <const> = {
    "jetmax",
    "longfin",
    "marquis",
    "patrolboat",
    "Predator",
    "squalo",
    "toro",
    "toro2",
    "tug",
}

Local_Feature["Block Lag"] = menu.add_feature("Block Lag", "value_str", Local_Parents["Protection"], function(f)
    while f.on do
        if not lib.globals.is_loading() then
            local lag_entity_count <const> = {}
            for i = 1, #lag_entity do
                lag_entity_count[lag_entity[i]] = 0
            end
            for i, ent in pairs(vehicle.get_all_vehicles()) do
                for i = 1, #lag_entity do
                    if entity.get_entity_model_hash(ent) == gameplay.get_hash_key(lag_entity[i]) and network.get_entity_net_owner(ent) ~= player.player_id() then
                        lag_entity_count[lag_entity[i]] = lag_entity_count[lag_entity[i]] + 1
                        if lag_entity_count[lag_entity[i]] > 3 then
                            local pid
                            if lib.entity.is_script_entity(ent) then
                                pid = lib.entity.get_entity_creator(ent)
                            else
                                pid = network.get_entity_net_owner(ent)
                            end
                            if pid ~= nil and pid ~= player.player_id() then
                                if f.value == 0 and can_player_be_modder(pid, "Lag Player") then
                                    lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Lag Player", "Anarchy Modder Detection")
                                    player.set_player_as_modder(pid, ProtectionFlags["Lag Player"])
                                end
                                lib.player.block_sync(pid, 10000)
                                entity.freeze_entity(ent, true)
                                entity.set_entity_as_no_longer_needed(ent)
                                entity.set_entity_coords_no_offset(ent, v3(8000, 8000, -1000))
                            end
                        end
                    end
                end
            end
        end
        system.wait()
    end
end)
Local_Feature["Block Lag"]:set_str_data({"Block & Notify", "Block"})

Local_Feature["Block Modded Carjacking"] = menu.add_feature("Block Modded Carjacking", "value_str", Local_Parents["Protection"], function(f)
    while f.on do
        local jacker <const> = lib.natives.GET_PEDS_JACKER(player.player_ped())
        local plyrowner <const> = network.get_entity_net_owner(jacker)
        if lib.player.is_player_driver(player.player_id()) and lib.natives.IS_PED_BEING_JACKED(player.player_ped()) then
            ped.set_ped_into_vehicle(player.player_ped(), player.player_vehicle(), -1)
            if f.value == 0 and can_player_be_modder(plyrowner, "Modded Carjacking") and not lib.globals.is_loading() and lib.entity.is_script_entity(jacker) and not ped.is_ped_a_player(jacker) then
                lua_notify("Player: " .. lib.player.get_player_name(plyrowner) .. "\nReason: Modded Carjacking", "Anarchy Modder Detection")
                player.set_player_as_modder(plyrowner, ProtectionFlags["Modded Carjacking"])
            end
        end
        system.wait()
    end
end)
Local_Feature["Block Modded Carjacking"]:set_str_data({"Block & Notify", "Block"})

Local_Parents["Modded Entity"] = menu.add_feature("Modded Entity", "parent", Local_Parents["Protection"]).id

local modded_entity_detection <const> = {}
Local_Feature["Modded Vehicle"] = menu.add_feature("Vehicle", "value_str", Local_Parents["Modded Entity"], function(f)
    while f.on do
        if not lib.globals.is_loading() and not lib.player.is_player_in_interior(player.player_id()) then
            local exclude_vehicle_hashes <const> = {
                "seasparrow2",
            }
            for i, ent in pairs(vehicle.get_all_vehicles()) do
                if lib.entity.is_script_entity(ent) then
                    for i = 1, #exclude_vehicle_hashes do
                        if entity.get_entity_model_hash(ent) == gameplay.get_hash_key(exclude_vehicle_hashes[i]) then
                            goto skip_modded_vehicle
                        end
                    end
                    local pid <const> = lib.entity.get_entity_creator(ent)
                    if f.value == 0 or f.value == 1 then
                        lib.entity.delete_entity_locally(ent)
                    end
                    local isEntityAlreadyInTable = false
                    for _, data in ipairs(modded_entity_detection) do
                        if data.entity == ent then
                            isEntityAlreadyInTable = true
                        end
                    end
                    if not isEntityAlreadyInTable then
                        if player.is_player_valid(pid) and pid ~= player.player_id() then
                            modded_entity_detection[#modded_entity_detection + 1] = {entity = ent, player_id = pid}
                        end
                    end
                    if (f.value == 0 or f.value == 2) and can_player_be_modder(pid, "Modded Entity") then
                        lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Entity (Vehicle: " .. lib.entity.get_hash_name(entity.get_entity_model_hash(ent)) .. ")", "Anarchy Modder Detection")
                        player.set_player_as_modder(pid, ProtectionFlags["Modded Entity"])
                    end
                end
                ::skip_modded_vehicle::
            end
        end
        system.wait(100)
    end
end)
Local_Feature["Modded Vehicle"]:set_str_data({"Block & Notify", "Block", "Notify"})

Local_Feature["Modded Ped"] = menu.add_feature("Ped", "value_str", Local_Parents["Modded Entity"], function(f)
    while f.on do
        if not lib.globals.is_loading() and not lib.player.is_player_in_interior(player.player_id()) then
            for i, ent in pairs(ped.get_all_peds()) do
                if lib.entity.is_script_entity(ent) then
                    local pid <const> = lib.entity.get_entity_creator(ent)
                    if f.value == 0 or f.value == 1 then
                        lib.entity.delete_entity_locally(ent)
                    end
                    local isEntityAlreadyInTable = false
                    for _, data in ipairs(modded_entity_detection) do
                        if data.entity == ent then
                            isEntityAlreadyInTable = true
                        end
                    end
                    if not isEntityAlreadyInTable then
                        if player.is_player_valid(pid) and pid ~= player.player_id() then
                            modded_entity_detection[#modded_entity_detection + 1] = {entity = ent, player_id = pid}
                        end
                    end
                    if (f.value == 0 or f.value == 2) and can_player_be_modder(pid, "Modded Entity") then
                        lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Entity (Ped: " .. lib.entity.get_hash_name(entity.get_entity_model_hash(ent)) .. ")", "Anarchy Modder Detection")
                        player.set_player_as_modder(pid, ProtectionFlags["Modded Entity"])
                    end
                end
            end
        end
        system.wait(100)
    end
end)
Local_Feature["Modded Ped"]:set_str_data({"Block & Notify", "Block", "Notify"})

Local_Feature["Modded Object"] = menu.add_feature("Object", "value_str", Local_Parents["Modded Entity"], function(f)
    while f.on do
        if not lib.globals.is_loading() and not lib.player.is_player_in_interior(player.player_id()) then
            local exclude_object_hashes <const> = {
                "w_battle_airmissile_01",
                "w_ex_vehiclemissile_2",
                "w_lr_rpg_rocket",
                "w_smug_airmissile_01b",
                "w_smug_bomb_04",
                "w_ex_vehiclemissile_4",
                "w_smug_bomb_03",
                "w_ex_vehiclemissile_3",
                "w_smug_airmissile_02",
                "w_smug_bomb_02",
                "w_smug_bomb_01",
                "w_lr_homing_rocket",
                "w_lr_firework_rocket",
                "prop_ld_keypad_01b",
                "reh_prop_reh_bag_weed_01a",
                "reh_prop_reh_lantern_pk_01b",
                "h4_prop_h4_ante_on_01a",
                "reh_prop_reh_lantern_pk_01a",
                "reh_prop_reh_lantern_pk_01b",
                "reh_prop_reh_lantern_pk_01c",
                "tr_prop_tr_usb_drive_02a",
            }
            local all_weapon_hashes <const> = weapon.get_all_weapon_hashes()
            for i = 1, #all_weapon_hashes do
                exclude_object_hashes[#exclude_object_hashes + 1] = all_weapon_hashes[i]
            end
            for i, ent in pairs(object.get_all_objects()) do
                if lib.entity.is_script_entity(ent) then
                    for i = 1, #exclude_object_hashes do
                        if entity.get_entity_model_hash(ent) == gameplay.get_hash_key(exclude_object_hashes[i]) then
                            goto skip_modded_object
                        end
                    end
                    local pid <const> = lib.entity.get_entity_creator(ent)
                    if f.value == 0 or f.value == 1 then
                        lib.entity.delete_entity_locally(ent)
                    end
                    local isEntityAlreadyInTable = false
                    for _, data in ipairs(modded_entity_detection) do
                        if data.entity == ent then
                            isEntityAlreadyInTable = true
                        end
                    end
                    if not isEntityAlreadyInTable then
                        if player.is_player_valid(pid) and pid ~= player.player_id() then
                            modded_entity_detection[#modded_entity_detection + 1] = {entity = ent, player_id = pid}
                        end
                    end
                    if (f.value == 0 or f.value == 2) and can_player_be_modder(pid, "Modded Entity") then
                        lua_notify("Player: " .. lib.player.get_player_name(pid) .. "\nReason: Modded Entity (Object: " .. lib.entity.get_hash_name(entity.get_entity_model_hash(ent)) .. ")", "Anarchy Modder Detection")
                        player.set_player_as_modder(pid, ProtectionFlags["Modded Entity"])
                    end
                end
                ::skip_modded_object::
            end
        end
        system.wait(100)
    end
end)
Local_Feature["Modded Object"]:set_str_data({"Block & Notify", "Block", "Notify"})

Local_Feature["Show Entity With ESP"] = menu.add_feature("Show Entity With ESP", "toggle", Local_Parents["Modded Entity"], function(f)
    while f.on do
        for i, data in ipairs(modded_entity_detection) do
            if not player.is_player_valid(data.player_id) then
                table.remove(modded_entity_detection, i)
            end
            if lib.natives.DOES_ENTITY_EXIST(data.entity) then
                local status, pos <const> = graphics.project_3d_coord(lib.entity.get_center_position(data.entity))
                if status then
                    pos.x = scriptdraw.pos_pixel_to_rel_x(pos.x)
                    pos.y = scriptdraw.pos_pixel_to_rel_y(pos.y)
                    lib.entity.draw_line_box(data.entity, 255, 0, 0, 255)
                    ui.draw_line(player.get_player_coords(data.player_id), entity.get_entity_coords(data.entity), 255, 0, 0, 255)
                    scriptdraw.draw_text(lib.entity.get_hash_name(entity.get_entity_model_hash(data.entity)) .. " created by " .. lib.player.get_player_name(data.player_id), pos, v2(0.0, 0.0), 0.5, lib.essentials.get_rgb(255, 0, 0, 255), 1 << 0, nil)
                end
            end
        end
        system.wait()
    end
end)

Local_Feature["Block Blame"] = menu.add_feature("Block Blame", "toggle", Local_Parents["Protection"], function(f)
    while f.on do
        lib.natives.NETWORK_SET_FRIENDLY_FIRE_OPTION(false)
        system.wait(1000)
    end
    if not f.on then
        lib.natives.NETWORK_SET_FRIENDLY_FIRE_OPTION(true)
    end
end)

Local_Feature["Stop Infinite Phone Ringing"] = menu.add_feature("Stop Infinite Phone Ringing", "action", Local_Parents["Protection"], function(f)
    lib.natives.STOP_PED_RINGTONE(player.player_ped())
end)

Local_Feature["Stop All Sounds"] = menu.add_feature("Stop All Sounds", "action", Local_Parents["Protection"], function(f)
    lib.essentials.stop_sound()
end)

Local_Parents["Host Only"] = menu.add_feature("Host Only", "parent", Local_Parents["Protection"]).id

Local_Feature["Block Script Host Migration"] = menu.add_feature("Block Script Host Migration", "toggle", Local_Parents["Host Only"], function(f)
    while f.on do
        if not lib.globals.is_loading() and network.network_is_host() then
            lib.natives.NETWORK_PREVENT_SCRIPT_HOST_MIGRATION()
        end
        system.wait()
    end
end)

Local_Feature["Hide Session"] = menu.add_feature("Hide Session", "toggle", Local_Parents["Host Only"], function(f)
    while f.on do
        if not lib.globals.is_loading() and network.network_is_host() and lib.natives.NETWORK_SESSION_IS_VISIBLE() then
            lib.natives.NETWORK_SESSION_MARK_VISIBLE(false)
        end
        system.wait(1000)
    end
    if not f.on then
        if not lib.globals.is_loading() and network.network_is_host() and not lib.natives.NETWORK_SESSION_IS_VISIBLE() then
            lib.natives.NETWORK_SESSION_MARK_VISIBLE(true)
        end
    end
end)

Local_Parents["Entity Manager"] = menu.add_feature("Entity Manager", "parent", Local_Parents["Local Prents"]).id

Local_Parents["All"] = menu.add_feature("All", "parent", Local_Parents["Entity Manager"]).id

Local_Feature["Deleted All Entities"] = menu.add_feature("Deleted All Entities", "action", Local_Parents["All"], function(f)
    if not lib.globals.is_loading() then
        local all_ent <const> = {
            ped.get_all_peds(),
            vehicle.get_all_vehicles(),
            object.get_all_objects(),
            object.get_all_pickups()
        }
        for i, ent in pairs(all_ent) do
            for i, ent in pairs(ent) do
                lib.entity.delete_entity_thread(ent)
            end
        end
        lua_notify("All entities are deleted.", f.name)
    else
        lua_notify_alert("You can't do it in story mode or in a loading screen.", f.name)
    end
end)

Local_Feature["All Name ESP"] = menu.add_feature("Name ESP", "toggle", Local_Parents["All"], function(f)
    if f.on then
        Local_Feature["Peds Name ESP"].on = true
        Local_Feature["Vehicles Name ESP"].on = true
        Local_Feature["Objects Name ESP"].on = true
        Local_Feature["Pickups Name ESP"].on = true
    end
    while f.on do
        if not Local_Feature["Peds Name ESP"].on or not Local_Feature["Vehicles Name ESP"].on or not Local_Feature["Objects Name ESP"].on or not Local_Feature["Pickups Name ESP"].on then
            Local_Feature["All Name ESP"].on = false
        end
        system.wait()
    end
    if not Local_Feature["All Name ESP"].on and Local_Feature["Peds Name ESP"].on and Local_Feature["Vehicles Name ESP"].on and Local_Feature["Objects Name ESP"].on and Local_Feature["Pickups Name ESP"].on then
        Local_Feature["Peds Name ESP"].on = false
        Local_Feature["Vehicles Name ESP"].on = false
        Local_Feature["Objects Name ESP"].on = false
        Local_Feature["Pickups Name ESP"].on = false
    end
end)

Local_Feature["All Box ESP"] = menu.add_feature("Box ESP", "toggle", Local_Parents["All"], function(f)
    if f.on then
        Local_Feature["Peds Box ESP"].on = true
        Local_Feature["Vehicles Box ESP"].on = true
        Local_Feature["Objects Box ESP"].on = true
        Local_Feature["Pickups Box ESP"].on = true
    end
    while f.on do
        if not Local_Feature["Peds Box ESP"].on or not Local_Feature["Vehicles Box ESP"].on or not Local_Feature["Objects Box ESP"].on or not Local_Feature["Pickups Box ESP"].on then
            Local_Feature["All Box ESP"].on = false
        end
        system.wait()
    end
    if not Local_Feature["All Box ESP"].on and Local_Feature["Peds Box ESP"].on and Local_Feature["Vehicles Box ESP"].on and Local_Feature["Objects Box ESP"].on and Local_Feature["Pickups Box ESP"].on then
        Local_Feature["Peds Box ESP"].on = false
        Local_Feature["Vehicles Box ESP"].on = false
        Local_Feature["Objects Box ESP"].on = false
        Local_Feature["Pickups Box ESP"].on = false
    end
end)

Local_Feature["All Line ESP"] = menu.add_feature("Line ESP", "toggle", Local_Parents["All"], function(f)
    if f.on then
        Local_Feature["Peds Line ESP"].on = true
        Local_Feature["Vehicles Line ESP"].on = true
        Local_Feature["Objects Line ESP"].on = true
        Local_Feature["Pickups Line ESP"].on = true
    end
    while f.on do
        if not Local_Feature["Peds Line ESP"].on or not Local_Feature["Vehicles Line ESP"].on or not Local_Feature["Objects Line ESP"].on or not Local_Feature["Pickups Line ESP"].on then
            Local_Feature["All Line ESP"].on = false
        end
        system.wait()
    end
    if not Local_Feature["All Line ESP"].on and Local_Feature["Peds Line ESP"].on and Local_Feature["Vehicles Line ESP"].on and Local_Feature["Objects Line ESP"].on and Local_Feature["Pickups Line ESP"].on then
        Local_Feature["Peds Line ESP"].on = false
        Local_Feature["Vehicles Line ESP"].on = false
        Local_Feature["Objects Line ESP"].on = false
        Local_Feature["Pickups Line ESP"].on = false
    end
end)

Local_Feature["Show Invisible Entities"] = menu.add_feature("Show Invisible Entities", "toggle", Local_Parents["All"], function(f)
    if f.on then
        Local_Feature["Show Invisible Ped"].on = true
        Local_Feature["Show Invisible Vehicle"].on = true
        Local_Feature["Show Invisible Object"].on = true
        Local_Feature["Show Invisible Pickup"].on = true
    end
    while f.on do
        if not Local_Feature["Show Invisible Ped"].on or not Local_Feature["Show Invisible Vehicle"].on or not Local_Feature["Show Invisible Object"].on or not Local_Feature["Show Invisible Pickup"].on then
            Local_Feature["Show Invisible Entities"].on = false
        end
        system.wait()
    end
    if not Local_Feature["Show Invisible Entities"].on and Local_Feature["Show Invisible Ped"].on and Local_Feature["Show Invisible Vehicle"].on and Local_Feature["Show Invisible Object"].on and Local_Feature["Show Invisible Pickup"].on then
        Local_Feature["Show Invisible Ped"].on = false
        Local_Feature["Show Invisible Vehicle"].on = false
        Local_Feature["Show Invisible Object"].on = false
        Local_Feature["Show Invisible Pickup"].on = false
    end
end)

Local_Parents["Peds"] = menu.add_feature("Peds", "parent", Local_Parents["Entity Manager"]).id

Local_Feature["Deleted Peds"] = menu.add_feature("Deleted Peds", "action", Local_Parents["Peds"], function(f)
    if not lib.globals.is_loading() then
        for i, ent in pairs(ped.get_all_peds()) do
            lib.entity.delete_entity_thread(ent)
        end
        lua_notify("All peds are deleted.", f.name)
    else
        lua_notify_alert("You can't do it in story mode or in a loading screen.", f.name)
    end
end)

Local_Feature["Peds Name ESP"] = menu.add_feature("Name ESP", "toggle", Local_Parents["Peds"], function(f)
    if Local_Feature["Peds Name ESP"].on and Local_Feature["Vehicles Name ESP"].on and Local_Feature["Objects Name ESP"].on and Local_Feature["Pickups Name ESP"].on then
        Local_Feature["All Name ESP"].on = true
    end
    while f.on do
        for i, ent in pairs(ped.get_all_peds()) do
            local status, pos <const> = graphics.project_3d_coord(lib.entity.get_center_position(ent))
            if status then
                pos.x = scriptdraw.pos_pixel_to_rel_x(pos.x)
                pos.y = scriptdraw.pos_pixel_to_rel_y(pos.y)
                scriptdraw.draw_text(lib.entity.get_hash_name(entity.get_entity_model_hash(ent)), pos, v2(0.0, 0.0), 0.5, lib.essentials.get_rgb(255, 255, 255, 255), 1 << 0, nil)
            end
        end
        system.wait()
    end
end)

Local_Feature["Peds Box ESP"] = menu.add_feature("Box ESP", "toggle", Local_Parents["Peds"], function(f)
    if Local_Feature["Peds Box ESP"].on and Local_Feature["Vehicles Box ESP"].on and Local_Feature["Objects Box ESP"].on and Local_Feature["Pickups Box ESP"].on then
        Local_Feature["All Box ESP"].on = true
    end
    while f.on do
        for i, ent in pairs(ped.get_all_peds()) do
            lib.entity.draw_line_box(ent, 255, 255, 255, 255)
        end
        system.wait()
    end
end)

Local_Feature["Peds Line ESP"] = menu.add_feature("Line ESP", "toggle", Local_Parents["Peds"], function(f)
    if Local_Feature["Peds Line ESP"].on and Local_Feature["Vehicles Line ESP"].on and Local_Feature["Objects Line ESP"].on and Local_Feature["Pickups Line ESP"].on then
        Local_Feature["All Line ESP"].on = true
    end
    while f.on do
        for i, ent in pairs(ped.get_all_peds()) do
            ui.draw_line(lib.entity.get_center_position(ent), player.get_player_coords(player.player_id()), 255, 255, 255, 255)
        end
        system.wait()
    end
end)

Local_Feature["Show Invisible Ped"] = menu.add_feature("Show Invisible Ped", "toggle", Local_Parents["Peds"], function(f)
    if Local_Feature["Show Invisible Ped"].on and Local_Feature["Show Invisible Vehicle"].on and Local_Feature["Show Invisible Object"].on and Local_Feature["Show Invisible Pickup"].on then
        Local_Feature["Show Invisible Entities"].on = true
    end
    while f.on do
        for i, ent in pairs(ped.get_all_peds()) do
            lib.natives.SET_ENTITY_LOCALLY_VISIBLE(ent)
        end
        system.wait(25)
    end
end)

Local_Feature["Friendly AI"] = menu.add_feature("Friendly AI", "toggle", Local_Parents["Peds"], function(f)
    while f.on do
        lib.natives.SET_PED_RESET_FLAG(player.player_ped(), 124, true)
        system.wait()
    end
end)

Local_Feature["Kill Ped You Touch"] = menu.add_feature("Kill Ped You Touch", "toggle", Local_Parents["Peds"], function(f)
    while f.on do
        for i, ent in pairs(ped.get_all_peds()) do
            if not ped.is_ped_a_player(ent) and not lib.natives.IS_PED_SITTING_IN_ANY_VEHICLE(ent) and lib.natives.IS_ENTITY_TOUCHING_ENTITY(player.player_ped(), ent) and not entity.is_entity_dead(ent) then
                network.request_control_of_entity(ent)
                ped.set_ped_health(ent, 0)
            end
        end
        system.wait()
    end
end)

Local_Feature["Cold Friendly Ped"] = menu.add_feature("Cold Friendly Ped", "toggle", Local_Parents["Peds"], function(f)
    while f.on do
        for i, ent in pairs(ped.get_all_peds()) do
            local rel1 <const> = lib.natives.GET_RELATIONSHIP_BETWEEN_PEDS(player.player_ped(), ent)
            local rel2 <const> = lib.natives.GET_RELATIONSHIP_BETWEEN_PEDS(ent, player.player_ped())
            if ped.is_ped_a_player(ent) then
                lib.natives.DISABLE_PED_HEATSCALE_OVERRIDE(ent)
            else
                if not entity.is_entity_dead(ent) and (lib.natives.IS_PED_IN_COMBAT(ent, player.player_ped()) or rel1 == 4 or rel1 == 5 or rel2 == 4 or rel2 == 5) then
                    lib.natives.DISABLE_PED_HEATSCALE_OVERRIDE(ent)
                else
                    lib.natives.SET_PED_HEATSCALE_OVERRIDE(ent, 0)
                end
            end
        end
        system.wait(100)
    end
    if not f.on then
        for i, ent in pairs(ped.get_all_peds()) do
            lib.natives.DISABLE_PED_HEATSCALE_OVERRIDE(ent)
        end
    end
end)

Local_Feature["Mute Ped"] = menu.add_feature("Mute Ped", "toggle", Local_Parents["Peds"], function(f)
    while f.on do
        for i, ent in pairs(ped.get_all_peds()) do
            if not ped.is_ped_a_player(ent) then
                lib.natives.STOP_PED_SPEAKING(ent, true)
            end
        end
        system.wait(10)
    end
end)

Local_Feature["Ped No Damage"] = menu.add_feature("Ped No Damage", "toggle", Local_Parents["Peds"], function(f)
    while f.on do
        lib.natives.SET_AI_WEAPON_DAMAGE_MODIFIER(0)
        lib.natives.SET_AI_MELEE_WEAPON_DAMAGE_MODIFIER(0)
        system.wait(100)
    end
    if not f.on then
        lib.natives.RESET_AI_WEAPON_DAMAGE_MODIFIER()
        lib.natives.RESET_AI_MELEE_WEAPON_DAMAGE_MODIFIER()
    end
end)

Local_Feature["Kill Jacked Ped"] = menu.add_feature("Kill Jacked Ped", "toggle", Local_Parents["Peds"], function(f)
    while f.on do
        if lib.natives.IS_PED_JACKING(player.player_ped()) then
            if not entity.is_entity_dead(lib.natives.GET_JACK_TARGET(player.player_ped())) then
                network.request_control_of_entity(lib.natives.GET_JACK_TARGET(player.player_ped()))
                system.wait(100)
                ped.set_ped_health(lib.natives.GET_JACK_TARGET(player.player_ped()), 0)
            end
        end
        system.wait()
    end
end)

Local_Feature["Kill Hostile Ped"] = menu.add_feature("Kill Hostile Ped", "toggle", Local_Parents["Peds"], function(f)
    while f.on do
        for i, ent in pairs(ped.get_all_peds()) do
            local rel1 <const> = lib.natives.GET_RELATIONSHIP_BETWEEN_PEDS(player.player_ped(), ent)
            local rel2 <const> = lib.natives.GET_RELATIONSHIP_BETWEEN_PEDS(ent, player.player_ped())
            if not ped.is_ped_a_player(ent) and not entity.is_entity_dead(ent) and (lib.natives.IS_PED_IN_COMBAT(ent, player.player_ped()) or rel1 == 4 or rel1 == 5 or rel2 == 4 or rel2 == 5) then
                network.request_control_of_entity(ent)
                ped.set_ped_health(ent, 0)
            end
        end
        system.wait()
    end
end)

Local_Feature["City War"] = menu.add_feature("City War", "toggle", Local_Parents["Peds"], function(f)
    while f.on do
        lib.natives.SET_RIOT_MODE_ENABLED(true)
        system.wait(100)
    end
    if not f.on then
        lib.natives.SET_RIOT_MODE_ENABLED(false)
    end
end)

Local_Feature["Fill Ped Population"] = menu.add_feature("Fill Ped Population", "toggle", Local_Parents["Peds"], function(f)
    while f.on do
        lib.natives.INSTANTLY_FILL_PED_POPULATION()
        system.wait()
    end
end)

Local_Parents["Vehicles"] = menu.add_feature("Vehicles", "parent", Local_Parents["Entity Manager"]).id

Local_Feature["Deleted Vehicles"] = menu.add_feature("Deleted Vehicles", "action", Local_Parents["Vehicles"], function(f)
    if not lib.globals.is_loading() then
        for i, ent in pairs(vehicle.get_all_vehicles()) do
            lib.entity.delete_entity_thread(ent)
        end
        lua_notify("All vehicles are deleted.", f.name)
    else
        lua_notify_alert("You can't do it in story mode or in a loading screen.", f.name)
    end
end)

Local_Feature["Vehicles Name ESP"] = menu.add_feature("Name ESP", "toggle", Local_Parents["Vehicles"], function(f)
    if Local_Feature["Peds Name ESP"].on and Local_Feature["Vehicles Name ESP"].on and Local_Feature["Objects Name ESP"].on and Local_Feature["Pickups Name ESP"].on then
        Local_Feature["All Name ESP"].on = true
    end
    local model_names <const> = {}
    for value, _ in pairs(lib.table.vehicle_models) do
        local vehicle_models_hash <const> = gameplay.get_hash_key(value)
        model_names[vehicle_models_hash] = value
    end
    while f.on do
        for i, ent in pairs(vehicle.get_all_vehicles()) do
            local status, pos <const> = graphics.project_3d_coord(lib.entity.get_center_position(ent))
            if status then
                pos.x = scriptdraw.pos_pixel_to_rel_x(pos.x)
                pos.y = scriptdraw.pos_pixel_to_rel_y(pos.y)
                scriptdraw.draw_text(lib.entity.get_hash_name(entity.get_entity_model_hash(ent)), pos, v2(0.0, 0.0), 0.5, lib.essentials.get_rgb(255, 255, 255, 255), 1 << 0, nil)
            end
        end
        system.wait()
    end
end)

Local_Feature["Vehicles Box ESP"] = menu.add_feature("Box ESP", "toggle", Local_Parents["Vehicles"], function(f)
    if Local_Feature["Peds Box ESP"].on and Local_Feature["Vehicles Box ESP"].on and Local_Feature["Objects Box ESP"].on and Local_Feature["Pickups Box ESP"].on then
        Local_Feature["All Box ESP"].on = true
    end
    while f.on do
        for i, ent in pairs(vehicle.get_all_vehicles()) do
            lib.entity.draw_line_box(ent, 255, 255, 255, 255)
        end
        system.wait()
    end
end)

Local_Feature["Vehicles Line ESP"] = menu.add_feature("Line ESP", "toggle", Local_Parents["Vehicles"], function(f)
    if Local_Feature["Peds Line ESP"].on and Local_Feature["Vehicles Line ESP"].on and Local_Feature["Objects Line ESP"].on and Local_Feature["Pickups Line ESP"].on then
        Local_Feature["All Line ESP"].on = true
    end
    while f.on do
        for i, ent in pairs(vehicle.get_all_vehicles()) do
            ui.draw_line(lib.entity.get_center_position(ent), player.get_player_coords(player.player_id()), 255, 255, 255, 255)
        end
        system.wait()
    end
end)

Local_Feature["Show Invisible Vehicle"] = menu.add_feature("Show Invisible Vehicle", "toggle", Local_Parents["Vehicles"], function(f)
    if Local_Feature["Show Invisible Ped"].on and Local_Feature["Show Invisible Vehicle"].on and Local_Feature["Show Invisible Object"].on and Local_Feature["Show Invisible Pickup"].on then
        Local_Feature["Show Invisible Entities"].on = true
    end
    while f.on do
        for i, ent in pairs(vehicle.get_all_vehicles()) do
            lib.natives.SET_ENTITY_LOCALLY_VISIBLE(ent)
        end
        system.wait(25)
    end
end)

Local_Feature["Disable Distant Vehicles"] = menu.add_feature("Disable Distant Vehicles", "toggle", Local_Parents["Vehicles"], function(f)
    while f.on do
        lib.natives.DISABLE_VEHICLE_DISTANTLIGHTS(true)
        system.wait(100)
    end
    lib.natives.DISABLE_VEHICLE_DISTANTLIGHTS(false)
end)

Local_Feature["Fill Vehicle Population"] = menu.add_feature("Fill Vehicle Population", "toggle", Local_Parents["Vehicles"], function(f)
    while f.on do
        lib.natives.INSTANTLY_FILL_VEHICLE_POPULATION()
        system.wait()
    end
end)

Local_Feature["Vehicle Potato Mode"] = menu.add_feature("Potato Mode", "toggle", Local_Parents["Vehicles"], function(f)
    while f.on do
        for i, ent in pairs(vehicle.get_all_vehicles()) do
            lib.natives.SET_VEHICLE_LOD_MULTIPLIER(ent, 0.0)
        end
        system.wait(100)
    end
    if not f.on then
        for i, ent in pairs(vehicle.get_all_vehicles()) do
            lib.natives.SET_VEHICLE_LOD_MULTIPLIER(ent, 1.0)
        end
    end
end)

Local_Parents["Objects"] = menu.add_feature("Objects", "parent", Local_Parents["Entity Manager"]).id

Local_Feature["Deleted Objects"] = menu.add_feature("Deleted Objects", "action", Local_Parents["Objects"], function(f)
    if not lib.globals.is_loading() then
        for i, ent in pairs(object.get_all_objects()) do
            lib.entity.delete_entity_thread(ent)
        end
        lua_notify("All objects are deleted.", f.name)
    else
        lua_notify_alert("You can't do it in story mode or in a loading screen.", f.name)
    end
end)

Local_Feature["Objects Name ESP"] = menu.add_feature("Name ESP", "toggle", Local_Parents["Objects"], function(f)
    if Local_Feature["Peds Name ESP"].on and Local_Feature["Vehicles Name ESP"].on and Local_Feature["Objects Name ESP"].on and Local_Feature["Pickups Name ESP"].on then
        Local_Feature["All Name ESP"].on = true
    end
    while f.on do
        for i, ent in pairs(object.get_all_objects()) do
            local status, pos <const> = graphics.project_3d_coord(lib.entity.get_center_position(ent))
            if status then
                pos.x = scriptdraw.pos_pixel_to_rel_x(pos.x)
                pos.y = scriptdraw.pos_pixel_to_rel_y(pos.y)
                scriptdraw.draw_text(lib.entity.get_hash_name(entity.get_entity_model_hash(ent)), pos, v2(0.0, 0.0), 0.5, lib.essentials.get_rgb(255, 255, 255, 255), 1 << 0, nil)
            end
        end
        system.wait()
    end
end)

Local_Feature["Objects Box ESP"] = menu.add_feature("Box ESP", "toggle", Local_Parents["Objects"], function(f)
    if Local_Feature["Peds Box ESP"].on and Local_Feature["Vehicles Box ESP"].on and Local_Feature["Objects Box ESP"].on and Local_Feature["Pickups Box ESP"].on then
        Local_Feature["All Box ESP"].on = true
    end
    while f.on do
        for i, ent in pairs(object.get_all_objects()) do
            lib.entity.draw_line_box(ent, 255, 255, 255, 255)
        end
        system.wait()
    end
end)

Local_Feature["Objects Line ESP"] = menu.add_feature("Line ESP", "toggle", Local_Parents["Objects"], function(f)
    if Local_Feature["Peds Line ESP"].on and Local_Feature["Vehicles Line ESP"].on and Local_Feature["Objects Line ESP"].on and Local_Feature["Pickups Line ESP"].on then
        Local_Feature["All Line ESP"].on = true
    end
    while f.on do
        for i, ent in pairs(object.get_all_objects()) do
            ui.draw_line(lib.entity.get_center_position(ent), player.get_player_coords(player.player_id()), 255, 255, 255, 255)
        end
        system.wait()
    end
end)

Local_Feature["Show Invisible Object"] = menu.add_feature("Show Invisible Object", "toggle", Local_Parents["Objects"], function(f)
    if Local_Feature["Show Invisible Ped"].on and Local_Feature["Show Invisible Vehicle"].on and Local_Feature["Show Invisible Object"].on and Local_Feature["Show Invisible Pickup"].on then
        Local_Feature["Show Invisible Entities"].on = true
    end
    while f.on do
        for i, ent in pairs(object.get_all_objects()) do
            lib.natives.SET_ENTITY_LOCALLY_VISIBLE(ent)
        end
        system.wait(25)
    end
end)

Local_Parents["Pickups"] = menu.add_feature("Pickups", "parent", Local_Parents["Entity Manager"]).id

Local_Feature["Deleted Pickups"] = menu.add_feature("Deleted Pickups", "action", Local_Parents["Pickups"], function(f)
    if not lib.globals.is_loading() then
        for i, ent in pairs(object.get_all_pickups()) do
            lib.entity.delete_entity_thread(ent)
        end
        lua_notify("All pickups are deleted.", f.name)
    else
        lua_notify_alert("You can't do it in story mode or in a loading screen.", f.name)
    end
end)

Local_Feature["Pickups Name ESP"] = menu.add_feature("Name ESP", "toggle", Local_Parents["Pickups"], function(f)
    if Local_Feature["Peds Name ESP"].on and Local_Feature["Vehicles Name ESP"].on and Local_Feature["Objects Name ESP"].on and Local_Feature["Pickups Name ESP"].on then
        Local_Feature["All Name ESP"].on = true
    end
    while f.on do
        for i, ent in pairs(object.get_all_pickups()) do
            local status, pos <const> = graphics.project_3d_coord(lib.entity.get_center_position(ent))
            if status then
                pos.x = scriptdraw.pos_pixel_to_rel_x(pos.x)
                pos.y = scriptdraw.pos_pixel_to_rel_y(pos.y)
                scriptdraw.draw_text(lib.entity.get_hash_name(entity.get_entity_model_hash(ent)), pos, v2(0.0, 0.0), 0.5, lib.essentials.get_rgb(255, 255, 255, 255), 1 << 0, nil)
            end
        end
        system.wait()
    end
end)

Local_Feature["Pickups Box ESP"] = menu.add_feature("Box ESP", "toggle", Local_Parents["Pickups"], function(f)
    if Local_Feature["Peds Box ESP"].on and Local_Feature["Vehicles Box ESP"].on and Local_Feature["Objects Box ESP"].on and Local_Feature["Pickups Box ESP"].on then
        Local_Feature["All Box ESP"].on = true
    end
    while f.on do
        for i, ent in pairs(object.get_all_pickups()) do
            lib.entity.draw_line_box(ent, 255, 255, 255, 255)
        end
        system.wait()
    end
end)

Local_Feature["Pickups Line ESP"] = menu.add_feature("Line ESP", "toggle", Local_Parents["Pickups"], function(f)
    if Local_Feature["Peds Line ESP"].on and Local_Feature["Vehicles Line ESP"].on and Local_Feature["Objects Line ESP"].on and Local_Feature["Pickups Line ESP"].on then
        Local_Feature["All Line ESP"].on = true
    end
    while f.on do
        for i, ent in pairs(object.get_all_pickups()) do
            ui.draw_line(lib.entity.get_center_position(ent), player.get_player_coords(player.player_id()), 255, 255, 255, 255)
        end
        system.wait()
    end
end)

Local_Feature["Show Invisible Pickup"] = menu.add_feature("Show Invisible Pickup", "toggle", Local_Parents["Pickups"], function(f)
    if Local_Feature["Show Invisible Ped"].on and Local_Feature["Show Invisible Vehicle"].on and Local_Feature["Show Invisible Object"].on and Local_Feature["Show Invisible Pickup"].on then
        Local_Feature["Show Invisible Entities"].on = true
    end
    while f.on do
        for i, ent in pairs(object.get_all_pickups()) do
            lib.natives.SET_ENTITY_LOCALLY_VISIBLE(ent)
        end
        system.wait(25)
    end
end)

Local_Parents["Weather & Time"] = menu.add_feature("Weather & Time", "parent", Local_Parents["Local Prents"]).id

Local_Feature["Local Time"] = menu.add_feature("Local Time", "toggle", Local_Parents["Weather & Time"], function(f)
    while f.on do
        time.set_clock_time(tonumber(os.date("*t").hour), tonumber(os.date("*t").min), tonumber(os.date("*t").sec))
        system.wait()
    end
    if not f.on then
        menu.get_feature_by_hierarchy_key("local.weather_and_time.clear_time_override").on = true
    end
end)

Local_Feature["Hour"] = menu.add_feature("Hour", "value_i", Local_Parents["Weather & Time"], function(f)
    while f.on do
        time.set_clock_time(f.value, time.get_clock_minutes(), time.get_clock_seconds())
        system.wait()
    end
    if not f.on then
        menu.get_feature_by_hierarchy_key("local.weather_and_time.clear_time_override").on = true
    end
end)
Local_Feature["Hour"].max = 23
Local_Feature["Hour"].min = 0
Local_Feature["Hour"].mod = 1
Local_Feature["Hour"].value = 0

Local_Feature["Minute"] = menu.add_feature("Minute", "value_i", Local_Parents["Weather & Time"], function(f)
    while f.on do
        time.set_clock_time(time.get_clock_hours(), f.value, time.get_clock_seconds())
        system.wait()
    end
    if not f.on then
        menu.get_feature_by_hierarchy_key("local.weather_and_time.clear_time_override").on = true
    end
end)
Local_Feature["Minute"].max = 55
Local_Feature["Minute"].min = 0
Local_Feature["Minute"].mod = 5
Local_Feature["Minute"].value = 0

Local_Feature["Second"] = menu.add_feature("Second", "value_i", Local_Parents["Weather & Time"], function(f)
    while f.on do
        time.set_clock_time(time.get_clock_hours(), time.get_clock_minutes(), f.value)
        system.wait()
    end
    if not f.on then
        menu.get_feature_by_hierarchy_key("local.weather_and_time.clear_time_override").on = true
    end
end)
Local_Feature["Second"].max = 55
Local_Feature["Second"].min = 0
Local_Feature["Second"].mod = 5
Local_Feature["Second"].value = 0

Local_Feature["Weather"] = menu.add_feature("Weather", "value_str", Local_Parents["Weather & Time"], function(f)
    local weather
    while f.on do
        weather = f.str_data[f.value + 1]
        if weather == "Extra Sunny" then
            weather = "ExtraSunny"
        end
        lib.natives.SET_OVERRIDE_WEATHER(weather)
        system.wait()
    end
    if not f.on then
        lib.natives.CLEAR_OVERRIDE_WEATHER()
    end
end)
Local_Feature["Weather"]:set_str_data({"Extra Sunny", "Clear", "Clouds", "Smog", "Foggy", "Overcast", "Rain", "Thunder", "Clearing", "Neutral", "Snow", "Blizzard", "Snowlight", "Xmas", "Halloween"})

Local_Feature["Clouds"] = menu.add_feature("Clouds", "value_str", Local_Parents["Weather & Time"], function(f)
    while f.on do
        gameplay.load_cloud_hat(f.str_data[f.value + 1], 0.0)
        lib.natives.SET_CLOUDS_ALPHA(255.0)
        system.wait()
    end
end)
Local_Feature["Clouds"]:set_str_data({"Altostratus", "Cirrus", "Cirrocumulus", "Clear 01", "Cloudy 01", "Contrails", "Horizon", "Horizonband1", "Horizonband2", "Horizonband3", "Horsey", "Nimbus", "Puffs", "Rain", "Snowy 01", "Stormy 01", "Stratoscumulus", "Stripey", "Shower", "Wispy"})

Local_Feature["Waves Intensity"] = menu.add_feature("Waves Intensity", "action_value_str", Local_Parents["Weather & Time"], function(f)
    if f.value == 0 then
        local input_stat, input_val <const> = input.get("Waves Intensity from 0 to 1000", "", 4, 3)
        if input_stat == 1 then
            return HANDLER_CONTINUE
        end
        if input_stat == 2 then
            lua_notify_alert("Input canceled.", f.name)
            return HANDLER_POP
        end
        water.set_waves_intensity(tonumber(input_val))
    elseif f.value == 1 then
        water.reset_waves_intensity()
    end
end):set_str_data({"Set", "Reset"})

Local_Feature["Wind Speed"] = menu.add_feature("Wind Speed", "value_f", Local_Parents["Weather & Time"], function(f)
    while f.on do
        lib.natives.SET_WIND(f.value)
        lib.natives.SET_WIND_SPEED(f.value)
        system.wait()
    end
    if not f.on then
        lib.natives.SET_WIND(-1)
        lib.natives.SET_WIND_SPEED(-1)
    end
end)
Local_Feature["Wind Speed"].max = 10.00
Local_Feature["Wind Speed"].min = 0.00
Local_Feature["Wind Speed"].mod = 0.10
Local_Feature["Wind Speed"].value = 0.00

Local_Feature["Rain Level"] = menu.add_feature("Rain Level", "value_f", Local_Parents["Weather & Time"], function(f)
    while f.on do
        lib.natives.SET_RAIN(f.value)
        system.wait()
    end
    if not f.on then
        lib.natives.SET_RAIN(-1)
    end
end)
Local_Feature["Rain Level"].max = 10.00
Local_Feature["Rain Level"].min = 0.00
Local_Feature["Rain Level"].mod = 0.10
Local_Feature["Rain Level"].value = 0.00

Local_Feature["Snow Level"] = menu.add_feature("Snow Level", "value_f", Local_Parents["Weather & Time"], function(f)
    while f.on do
        lib.natives.SET_SNOW(f.value)
        system.wait()
    end
    if not f.on then
        lib.natives.SET_SNOW(-1)
    end
end)
Local_Feature["Snow Level"].max = 1.00
Local_Feature["Snow Level"].min = 0.00
Local_Feature["Snow Level"].mod = 0.05
Local_Feature["Snow Level"].value = 0.00

Local_Feature["Lightning Flash"] = menu.add_feature("Lightning Flash", "action", Local_Parents["Weather & Time"], function(f)
    lib.natives.FORCE_LIGHTNING_FLASH()
end)

Local_Feature["Blackout"] = menu.add_feature("Blackout", "value_str", Local_Parents["Weather & Time"], function(f)
    while f.on do
        if f.value == 0 then
            lib.natives.SET_ARTIFICIAL_VEHICLE_LIGHTS_STATE(true)
        else
            lib.natives.SET_ARTIFICIAL_VEHICLE_LIGHTS_STATE(false)
        end
        gameplay.set_blackout(true)
        system.wait()
    end
    if not f.on then
        lib.natives.SET_ARTIFICIAL_VEHICLE_LIGHTS_STATE(true)
        gameplay.set_blackout(false)
    end
end)
Local_Feature["Blackout"]:set_str_data({"Normal", "Ignore Vehicle"})

Local_Parents["Spawn"] = menu.add_feature("Spawn", "parent", Local_Parents["Local Prents"]).id

Local_Parents["Spawn Vehicle"] = menu.add_feature("Vehicle", "parent", Local_Parents["Spawn"]).id

Local_Parents["Spawn Vehicle List"] = menu.add_feature("List", "parent", Local_Parents["Spawn Vehicle"]).id

for _, eVehicleClass in ipairs(lib.essentials.sort_table_alphabetically("left", lib.table.eVehicleClass)) do
    Local_Parents[eVehicleClass.right] = menu.add_feature(eVehicleClass.left, "parent", Local_Parents["Spawn Vehicle List"]).id
    for _, vehicle_name_x_model in ipairs(lib.essentials.sort_table_alphabetically("right", vehicle_name_x_model)) do
        local vehicle_models_hash <const> = gameplay.get_hash_key(vehicle_name_x_model.left)
        if eVehicleClass.right == lib.natives.GET_VEHICLE_CLASS_FROM_NAME(vehicle_models_hash) then
            Local_Feature[vehicle_models_hash] = menu.add_feature(vehicle_name_x_model.right, "action", Local_Parents[eVehicleClass.right], function(f)
                local pos, velocity, ent_pos
                if player.is_player_in_any_vehicle(player.player_id()) then
                    velocity = entity.get_entity_velocity(player.player_vehicle())
                    ent_pos = player.player_vehicle()
                else
                    velocity = entity.get_entity_velocity(player.player_ped())
                    ent_pos = player.player_ped()
                end
                if Local_Feature["Spawn In Front"].on then
                    pos = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent_pos, 0.0, lib.entity.get_hash_offset_dimension(vehicle_models_hash), 0.0)
                else
                    pos = entity.get_entity_coords(ent_pos)
                end
                if Local_Feature["Delete Current Vehicle"].on and lib.player.is_player_driver(player.player_id()) then
                    entity.delete_entity(player.player_vehicle())
                end
                local spawn_vehicle <const> = lib.entity.spawn_entity(vehicle_models_hash, pos, player.get_player_heading(player.player_id()), true, Local_Feature["Spawn Invincible"].on, Local_Feature["Spawn Invisible"].on ~= true, false, true, Local_Feature["Spawn Not Networked"].on ~= true)
                local previous_spawn <const> = spawn_vehicle
                vehicle.set_vehicle_on_ground_properly(spawn_vehicle)
                if Local_Feature["Spawn In Vehicle"].on then
                    ped.set_ped_into_vehicle(player.player_ped(), spawn_vehicle, -1)
                end
                if Local_Feature["Keep Velocity"].on then
                    entity.set_entity_velocity(spawn_vehicle, velocity)
                end
            end)
        end
    end
end

Local_Feature["Tunings"] = menu.add_feature("Tunings", "value_str", Local_Parents["Spawn Vehicle"], function(f)
end)
Local_Feature["Tunings"]:set_str_data({"Maxed", "", "", ""})

Local_Feature["Spawn Aircraft In The Air"] = menu.add_feature("Spawn Aircraft In The Air", "toggle", Local_Parents["Spawn Vehicle"], function(f)
end)

Local_Feature["Modify License Plate"] = menu.add_feature("Modify License Plate", "toggle", Local_Parents["Spawn Vehicle"], function(f)
end)

Local_Feature["Spawn In Front"] = menu.add_feature("Spawn In Front", "toggle", Local_Parents["Spawn Vehicle"], function(f)
end)

Local_Feature["Spawn In Vehicle"] = menu.add_feature("Spawn In Vehicle", "toggle", Local_Parents["Spawn Vehicle"], function(f)
end)

Local_Feature["Spawn Invincible"] = menu.add_feature("Spawn Invincible", "toggle", Local_Parents["Spawn Vehicle"], function(f)
end)

Local_Feature["Spawn Invisible"] = menu.add_feature("Spawn Invisible", "toggle", Local_Parents["Spawn Vehicle"], function(f)
end)

Local_Feature["Spawn Not Networked"] = menu.add_feature("Spawn Not Networked", "toggle", Local_Parents["Spawn Vehicle"], function(f)
end)

Local_Feature["Keep Velocity"] = menu.add_feature("Keep Velocity", "toggle", Local_Parents["Spawn Vehicle"], function(f)
end)

Local_Feature["Delete Current Vehicle"] = menu.add_feature("Delete Current Vehicle", "toggle", Local_Parents["Spawn Vehicle"], function(f)
end)

Local_Parents["Spawn Custom"] = menu.add_feature("Custom", "parent", Local_Parents["Spawn"]).id

Local_Feature["Entity Spam Amount"] = menu.add_feature("Entity Spam Amount", "action_value_i", Local_Parents["Spawn Custom"], function(f)
    local input_stat, input_val = input.get("Entity Spam Amount from " .. f.min .. " to " .. f.max, "", 3, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Entity Spam Amount"].max = 120
Local_Feature["Entity Spam Amount"].min = 1
Local_Feature["Entity Spam Amount"].mod = 1
Local_Feature["Entity Spam Amount"].value = 1

Local_Feature["Entity Spam Delay"] = menu.add_feature("Entity Spam Delay", "action_value_i", Local_Parents["Spawn Custom"], function(f)
    local input_stat, input_val = input.get("Entity Spam Delay from " .. f.min .. " to " .. f.max, "", 5, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Entity Spam Delay"].max = 10000
Local_Feature["Entity Spam Delay"].min = -1
Local_Feature["Entity Spam Delay"].mod = 1
Local_Feature["Entity Spam Delay"].value = 0

local All_Spawn_Input_Val = {}

function spawn_entity(input_val, feature)
    local input_val_1 <const> = input_val
    if input_val == "" then
        lua_notify_alert("Input is not a valid entity.", feature.name)
        return
    end
    if math.type(math.tointeger(input_val)) == nil then
        input_val = gameplay.get_hash_key(tostring(input_val))
    end
    input_val_tointeger = math.tointeger(input_val)
    if not streaming.is_model_valid(input_val_tointeger) then
        lua_notify_alert("(" .. input_val_1 .. ") is not a valid entity.", feature.name)
        return
    end
    for i = 1, Local_Feature["Entity Spam Amount"].value do
        local model_dimension
        if Local_Feature["Spawn Entity Add Model Dimension"].on then
            model_dimension = lib.entity.get_hash_offset_dimension(input_val_tointeger)
        else
            model_dimension = 0
        end
        local SpawnEntityPos <const> = lib.natives.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player.player_ped(), Local_Feature["Spawn Entity Position X Axis"].value, Local_Feature["Spawn Entity Position Y Axis"].value + model_dimension, Local_Feature["Spawn Entity Position Z Axis"].value)
        local Spawn_Input_Val, entity_type
        if feature.value == 0 then
            Spawn_Input_Val, entity_type = lib.entity.spawn_entity(input_val_tointeger, SpawnEntityPos, 0, true, false, true, false, true, Local_Feature["Spawn Entity Not Networked"].on == false)
            All_Spawn_Input_Val[#All_Spawn_Input_Val + 1] = Spawn_Input_Val
        elseif feature.value == 1 then
            Spawn_Input_Val = lib.entity.spawn_world_object(input_val_tointeger, SpawnEntityPos, 0, true, false, true, false, true, false, true)
            All_Spawn_Input_Val[#All_Spawn_Input_Val + 1] = Spawn_Input_Val
            entity_type = 4
        end
        if not lib.natives.DOES_ENTITY_EXIST(Spawn_Input_Val) then
            lua_notify_alert("Entity has not spawned in the area.", feature.name)
            return
        else
            if Local_Feature["Spawn Entity Add Player Rotation"].on then
                lib.natives.SET_ENTITY_ROTATION(Spawn_Input_Val, v3(Local_Feature["Spawn Entity Rotation X Axis"].value, Local_Feature["Spawn Entity Rotation Y Axis"].value, player.get_player_heading(player.player_id()) + Local_Feature["Spawn Entity Rotation Z Axis"].value))
            else
                lib.natives.SET_ENTITY_ROTATION(Spawn_Input_Val, v3(Local_Feature["Spawn Entity Rotation X Axis"].value, Local_Feature["Spawn Entity Rotation Y Axis"].value, Local_Feature["Spawn Entity Rotation Z Axis"].value))
            end
            if Local_Feature["Spawn Entity Belongs To You Forever"].on then
                lib.entity.entity_owner_can_migrate(Spawn_Input_Val, false)
            end
            if Local_Feature["Spawn Entity Invincible"].on then
                entity.set_entity_god_mode(Spawn_Input_Val, true)
            end
            if Local_Feature["Spawn Entity Freeze"].on then
                entity.freeze_entity(Spawn_Input_Val, true)
            end
            if Local_Feature["Spawn Entity No Collision"].on then
                entity.set_entity_collision(Spawn_Input_Val, false, true)
            end
            if Local_Feature["Set Spawn Entity"].value == 0 and Local_Feature["Set Spawn Entity"].on then
                entity.set_entity_visible(Spawn_Input_Val, false)
            end
            if Local_Feature["Set Spawn Entity"].value == 1 and Local_Feature["Set Spawn Entity"].on then
                lib.natives.NETWORK_FADE_IN_ENTITY(Spawn_Input_Val, true, true)
            end
        end
        if Local_Feature["Entity Spam Delay"].value ~= -1 then
            system.wait(Local_Feature["Entity Spam Delay"].value)
        end
    end
    if entity_type == 1 then
        lua_notify("Successfully spawned ped (" .. input_val_1 .. ")", feature.name)
    elseif entity_type == 2 then
        lua_notify("Successfully spawned vehicle (" .. input_val_1 .. ")", feature.name)
    elseif entity_type == 3 then
        lua_notify("Successfully spawned object (" .. input_val_1 .. ")", feature.name)
    elseif entity_type == 4 then
        lua_notify("Successfully spawned world object (" .. input_val_1 .. ")", feature.name)
    end
end

Local_Feature["Spawn"] = menu.add_feature("Spawn", "action_value_str", Local_Parents["Spawn Custom"], function(f)
    local input_stat, input_val <const> = input.get("Enter Hash Model", "", 100, 0)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    spawn_entity(input_val, f)
end)
Local_Feature["Spawn"]:set_str_data({"Ped | Vehicle | Object", "World Object"})

Local_Feature["Spawn From Clipboard"] = menu.add_feature("Spawn From Clipboard", "action_value_str", Local_Parents["Spawn Custom"], function(f)
    spawn_entity(utils.from_clipboard(), f)
end)
Local_Feature["Spawn From Clipboard"]:set_str_data({"Ped | Vehicle | Object", "World Object"})

Local_Feature["Delete Spawned Entity"] = menu.add_feature("Delete Spawned Entity", "action", Local_Parents["Spawn Custom"], function(f)
    for i, ent in ipairs(All_Spawn_Input_Val) do
        lib.entity.delete_entity_thread(ent)
    end
    All_Spawn_Input_Val = {}
end)

Local_Parents["Position Axis"] = menu.add_feature("Position Axis", "parent", Local_Parents["Spawn Custom"]).id

Local_Feature["Spawn Entity Position X Axis"] = menu.add_feature("X Axis", "action_value_f", Local_Parents["Position Axis"], function(f)
    local input_stat, input_val = input.get("X Axis from " .. f.min .. " to " .. f.max, "", 7, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Spawn Entity Position X Axis"].max = 1000.00
Local_Feature["Spawn Entity Position X Axis"].min = -1000.00
Local_Feature["Spawn Entity Position X Axis"].mod = 1.00
Local_Feature["Spawn Entity Position X Axis"].value = 0.00

Local_Feature["Spawn Entity Position Y Axis"] = menu.add_feature("Y Axis", "action_value_f", Local_Parents["Position Axis"], function(f)
    local input_stat, input_val = input.get("Y Axis from " .. f.min .. " to " .. f.max, "", 7, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Spawn Entity Position Y Axis"].max = 1000.00
Local_Feature["Spawn Entity Position Y Axis"].min = -1000.00
Local_Feature["Spawn Entity Position Y Axis"].mod = 1.00
Local_Feature["Spawn Entity Position Y Axis"].value = 5.00

Local_Feature["Spawn Entity Position Z Axis"] = menu.add_feature("Z Axis", "action_value_f", Local_Parents["Position Axis"], function(f)
    local input_stat, input_val = input.get("Z Axis from " .. f.min .. " to " .. f.max, "", 7, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Spawn Entity Position Z Axis"].max = 1000.00
Local_Feature["Spawn Entity Position Z Axis"].min = -1000.00
Local_Feature["Spawn Entity Position Z Axis"].mod = 1.00
Local_Feature["Spawn Entity Position Z Axis"].value = 0.00

Local_Feature["Spawn Entity Add Model Dimension"] = menu.add_feature("Add Model Dimension", "toggle", Local_Parents["Position Axis"], function(f)
end)

Local_Parents["Rotation Axis"] = menu.add_feature("Rotation Axis", "parent", Local_Parents["Spawn Custom"]).id

Local_Feature["Spawn Entity Rotation X Axis"] = menu.add_feature("X Axis", "action_value_f", Local_Parents["Rotation Axis"], function(f)
    local input_stat, input_val = input.get("X Axis from " .. f.min .. " to " .. f.max, "", 6, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Spawn Entity Rotation X Axis"].max = 360.00
Local_Feature["Spawn Entity Rotation X Axis"].min = 0.00
Local_Feature["Spawn Entity Rotation X Axis"].mod = 1.00
Local_Feature["Spawn Entity Rotation X Axis"].value = 0.00

Local_Feature["Spawn Entity Rotation Y Axis"] = menu.add_feature("Y Axis", "action_value_f", Local_Parents["Rotation Axis"], function(f)
    local input_stat, input_val = input.get("Y Axis from " .. f.min .. " to " .. f.max, "", 6, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Spawn Entity Rotation Y Axis"].max = 360.00
Local_Feature["Spawn Entity Rotation Y Axis"].min = 0.00
Local_Feature["Spawn Entity Rotation Y Axis"].mod = 1.00
Local_Feature["Spawn Entity Rotation Y Axis"].value = 0.00

Local_Feature["Spawn Entity Rotation Z Axis"] = menu.add_feature("Z Axis", "action_value_f", Local_Parents["Rotation Axis"], function(f)
    local input_stat, input_val = input.get("Z Axis from " .. f.min .. " to " .. f.max, "", 6, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Spawn Entity Rotation Z Axis"].max = 360.00
Local_Feature["Spawn Entity Rotation Z Axis"].min = 0.00
Local_Feature["Spawn Entity Rotation Z Axis"].mod = 1.00
Local_Feature["Spawn Entity Rotation Z Axis"].value = 0.00

Local_Feature["Spawn Entity Add Player Rotation"] = menu.add_feature("Add Player Rotation", "toggle", Local_Parents["Rotation Axis"], function(f)
end)

Local_Feature["Spawn Entity Belongs To You Forever"] = menu.add_feature("Belongs To You Forever", "toggle", Local_Parents["Spawn Custom"], function(f)
end)

Local_Feature["Spawn Entity Invincible"] = menu.add_feature("Invincible", "toggle", Local_Parents["Spawn Custom"], function(f)
end)

Local_Feature["Spawn Entity Freeze"] = menu.add_feature("Freeze", "toggle", Local_Parents["Spawn Custom"], function(f)
end)

Local_Feature["Spawn Entity No Collision"] = menu.add_feature("No Collision", "toggle", Local_Parents["Spawn Custom"], function(f)
end)

Local_Feature["Spawn Entity Not Networked"] = menu.add_feature("Not Networked", "toggle", Local_Parents["Spawn Custom"], function(f)
end)

Local_Feature["Set Spawn Entity"] = menu.add_feature("Set", "value_str", Local_Parents["Spawn Custom"], function(f)
end)
Local_Feature["Set Spawn Entity"]:set_str_data({"Invisible", "Spawn Fade In"})

Local_Parents["Misc"] = menu.add_feature("Misc", "parent", Local_Parents["Local Prents"]).id

local Simple_Encryption_Path <const> = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Simple Encryption", "Encrypted")
local Encrypted_Path <const> = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Simple Encryption", "Encrypted")
local Original_Path <const> = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Simple Encryption", "Original")
local Scripts_Path <const> = utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Simple Encryption", "Scripts")

Local_Parents["Simple Encryption"] = menu.add_feature("Simple Encryption", "parent", Local_Parents["Misc"], function(f)
    if not utils.dir_exists(Simple_Encryption_Path) or not utils.dir_exists(Encrypted_Path) or not utils.dir_exists(Original_Path) or not utils.dir_exists(Scripts_Path) then
        utils.make_dir(Encrypted_Path)
        utils.make_dir(Original_Path)
        utils.make_dir(Scripts_Path)
        lua_notify("Everything is set up correctly.", f.name)
    end
end).id

function simple_encrypt(name, c)
    io._encrypt(utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Simple Encryption\\Scripts", name))
    if Local_Feature["Delete Original Lua"].on then
        io.remove(utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Simple Encryption\\Scripts", name))
    else
        io.rename(utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Simple Encryption\\Scripts", name), utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Simple Encryption\\Original", name))
    end
    if c then
        io.rename(utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Simple Encryption\\Scripts", string.gsub(name, ".luac", "") .. ".e.luac"), utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Simple Encryption\\Encrypted", name))
    else
        io.rename(utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Simple Encryption\\Scripts", string.gsub(name, ".lua", "") .. ".e.lua"), utils.get_appdata_path("PopstarDevs\\2Take1Menu\\Simple Encryption\\Encrypted", name))
    end
end

Local_Feature["How It Works"] = menu.add_feature("How It Works", "action", Local_Parents["Simple Encryption"], function(f)
    lua_notify("You can put lua here " .. Jaune .. "2Take1Menu\\Simple Encryption\\Scripts" .. BleuClair .. " and then choose what to encrypt underneath.", f.name)
end)

Local_Feature["Delete Original Lua"] = menu.add_feature("Delete Original Lua", "toggle", Local_Parents["Simple Encryption"], function(f) end)

local All_Encrypt_Files, All_Encrypt_Files_C

menu.add_feature("Encrypt Every Lua", "action", Local_Parents["Simple Encryption"], function(f)
    All_Encrypt_Files = utils.get_all_files_in_directory(Scripts_Path, "lua")
    All_Encrypt_Files_C = utils.get_all_files_in_directory(Scripts_Path, "luac")
    if #All_Encrypt_Files == 0 and #All_Encrypt_Files_C == 0 then
        lua_notify_alert("There is no lua", f.name)
        return
    end
    for i = 1, #All_Encrypt_Files do
        simple_encrypt(All_Encrypt_Files[i], false)
    end
    for i = 1, #All_Encrypt_Files_C do
        simple_encrypt(All_Encrypt_Files_C[i], true)
    end
end)

menu.create_thread(function()
    while true do
        All_Encrypt_Files_2 = utils.get_all_files_in_directory(Scripts_Path, "lua")
        All_Encrypt_Files_2_C = utils.get_all_files_in_directory(Scripts_Path, "luac")
        if tostring(All_Encrypt_Files) ~= tostring(All_Encrypt_Files_2) or tostring(All_Encrypt_Files_C) ~= tostring(All_Encrypt_Files_2_C) then
            --local lua_children = menu.get_feature_by_hierarchy_key("local.script_features._ff00ffff_anarchy.misc.simple_encryption").children
            local lua_children <const> = menu.get_feature_by_hierarchy_key("local._ff00ffff_anarchy.misc.simple_encryption").children
            if lua_children ~= nil then
                for i = 4, #lua_children do
                    menu.delete_feature(lua_children[i].id)
                end
            end
            All_Encrypt_Files = utils.get_all_files_in_directory(Scripts_Path, "lua")
            All_Encrypt_Files_C = utils.get_all_files_in_directory(Scripts_Path, "luac")
            for i = 1, #All_Encrypt_Files do
                menu.add_feature(All_Encrypt_Files[i], "action_value_str", Local_Parents["Simple Encryption"], function(f)
                    simple_encrypt(All_Encrypt_Files[i], false)
                end):set_str_data({"Click To Encrypt"})
            end
            for i = 1, #All_Encrypt_Files_C do
                menu.add_feature(All_Encrypt_Files_C[i], "action_value_str", Local_Parents["Simple Encryption"], function(f)
                    simple_encrypt(All_Encrypt_Files_C[i], true)
                end):set_str_data({"Click To Encrypt"})
            end
        end
        system.wait(100)
    end
end)

Local_Parents["Camera"] = menu.add_feature("Camera", "parent", Local_Parents["Misc"]).id

Local_Feature["Disable First-Person View"] = menu.add_feature("Disable First-Person View", "toggle", Local_Parents["Camera"], function(f)
    while f.on do
        lib.natives.DISABLE_ON_FOOT_FIRST_PERSON_VIEW_THIS_UPDATE()
        system.wait()
    end
end)

Local_Feature["Force View Mode"] = menu.add_feature("Force View Mode", "value_str", Local_Parents["Camera"], function(f)
    while f.on do
        if f.value == 0 then
            lib.natives.SET_FOLLOW_PED_CAM_VIEW_MODE(4)
        else
            lib.natives.SET_FOLLOW_PED_CAM_VIEW_MODE(0)
        end
        system.wait()
    end
end)
Local_Feature["Force View Mode"]:set_str_data({"First Person", "Third Person"})

Local_Feature["Lock View Mode"] = menu.add_feature("Lock View Mode", "toggle", Local_Parents["Camera"], function(f)
    while f.on do
        lib.natives.DISABLE_CAMERA_VIEW_MODE_CYCLE(player.player_id())
        system.wait()
    end
end)

Local_Feature["Disable Aim Cam"] = menu.add_feature("Disable Aim Cam", "toggle", Local_Parents["Camera"], function(f)
    while f.on do
        lib.natives.DISABLE_AIM_CAM_THIS_UPDATE()
        system.wait()
    end
end)

Local_Feature["Camera Distance"] = menu.add_feature("Camera Distance", "value_f", Local_Parents["Camera"], function(f)
    while f.on do
        lib.natives.SET_THIRD_PERSON_CAM_ORBIT_DISTANCE_LIMITS_THIS_UPDATE(0.0, Local_Feature["Camera Distance"].value)
        lib.natives.SET_FIRST_PERSON_AIM_CAM_ZOOM_FACTOR_LIMITS_THIS_UPDATE(0.0, Local_Feature["Camera Distance"].value)
        system.wait()
    end
end)
Local_Feature["Camera Distance"].max = 10000.00
Local_Feature["Camera Distance"].min = 0.00
Local_Feature["Camera Distance"].mod = 0.50
Local_Feature["Camera Distance"].value = 10.00

Local_Feature["Unrestrict Snip Camera"] = menu.add_feature("Unrestrict Snip Camera", "toggle", Local_Parents["Camera"], function(f)
    while f.on do
        lib.natives.SET_FIRST_PERSON_AIM_CAM_RELATIVE_PITCH_LIMITS_THIS_UPDATE(-90.0, 90.0)
        system.wait()
    end
end)

Local_Feature["Unrestrict Gameplay Camera"] = menu.add_feature("Unrestrict Gameplay Camera", "toggle", Local_Parents["Camera"], function(f)
    while f.on do
        lib.natives.SET_THIRD_PERSON_CAM_RELATIVE_PITCH_LIMITS_THIS_UPDATE(-90.0, 90.0)
        system.wait()
    end
end)

Local_Parents["Disable"] = menu.add_feature("Disable", "parent", Local_Parents["Misc"]).id

Local_Feature["Disable Game Recording"] = menu.add_feature("Disable Game Recording", "toggle", Local_Parents["Disable"], function(f)
    while f.on do
        lib.natives.REPLAY_PREVENT_RECORDING_THIS_FRAME()
        system.wait()
    end
end)

Local_Feature["Disable Stunt jumps"] = menu.add_feature("Disable Stunt jumps", "toggle", Local_Parents["Disable"], function(f)
    while f.on do
        lib.natives.SET_STUNT_JUMPS_CAN_TRIGGER(false)
        system.wait(100)
    end
    if not f.on then
        lib.natives.SET_STUNT_JUMPS_CAN_TRIGGER(true)
    end
end)

Local_Feature["Disable Shark Card Store"] = menu.add_feature("Disable Shark Card Store", "toggle", Local_Parents["Disable"], function(f)
    while f.on do
        lib.natives.SET_STORE_ENABLED(false)
        system.wait()
    end
    if not f.on then
        lib.natives.SET_STORE_ENABLED(true)
    end
end)

Local_Feature["Disable Decals"] = menu.add_feature("Disable Decals", "toggle", Local_Parents["Disable"], function(f)
    while f.on do
        lib.natives.SET_DISABLE_DECAL_RENDERING_THIS_FRAME()
        system.wait()
    end
end)

Local_Feature["Disables Footstep Sounds"] = menu.add_feature("Disables Footstep Sounds", "toggle", Local_Parents["Disable"], function(f)
    while f.on do
        for i, ent in pairs(ped.get_all_peds()) do
            lib.natives.SET_PED_FOOTSTEPS_EVENTS_ENABLED(ent, false)
        end
        system.wait()
    end
    if not f.on then
        for i, ent in pairs(ped.get_all_peds()) do
            lib.natives.SET_PED_FOOTSTEPS_EVENTS_ENABLED(ent, true)
        end
    end
end)

Local_Feature["Disable Ambient Sounds"] = menu.add_feature("Disable Ambient Sounds", "toggle", Local_Parents["Disable"], function(f)
    while f.on do
        lib.natives.START_AUDIO_SCENE("CHARACTER_CHANGE_IN_SKY_SCENE")
        system.wait()
    end
    if not f.on then
        lib.natives.STOP_AUDIO_SCENES()
    end
end)

Local_Feature["Disable Gameplay Sound"] = menu.add_feature("Disable Gameplay Sound", "toggle", Local_Parents["Disable"], function(f)
    while f.on do
        lib.natives.START_AUDIO_SCENE("FADE_OUT_WORLD_250MS_SCENE")
        system.wait()
    end
    if not f.on then
        lib.natives.STOP_AUDIO_SCENES()
    end
end)

Local_Feature["Disable Distant Sirens"] = menu.add_feature("Disable Distant Sirens", "toggle", Local_Parents["Disable"], function(f)
    lib.natives.DISTANT_COP_CAR_SIRENS(f.on == false)
end)

Local_Feature["Disable Trees"] = menu.add_feature("Disable Trees", "toggle", Local_Parents["Disable"], function(f)
    while f.on do
        lib.natives.GRASSBATCH_ENABLE_FLATTENING_IN_SPHERE(player.get_player_coords(player.player_id()), 1000.0, 0.0, 0.0, 0.0)
        system.wait()
    end
    if not f.on then
        lib.natives.GRASSBATCH_DISABLE_FLATTENING()
    end
end)

Local_Feature["Disable Vehicle Audio"] = menu.add_feature("Disable Vehicle Audio", "toggle", Local_Parents["Disable"], function(f)
    while f.on do
        for i, ent in pairs(vehicle.get_all_vehicles()) do
            lib.natives.FORCE_USE_AUDIO_GAME_OBJECT(ent, "")
        end
        system.wait()
    end
end)

Local_Feature["Disable Ped Speech"] = menu.add_feature("Disable Ped Speech", "toggle", Local_Parents["Disable"], function(f)
    while f.on do
        for i, ent in pairs(ped.get_all_peds()) do
            if lib.natives.IS_ANY_SPEECH_PLAYING(ent) then
                lib.natives.STOP_CURRENT_PLAYING_SPEECH(ent)
            end
        end
        system.wait()
    end
end)

Local_Feature["Disable Rendering"] = menu.add_feature("Disable Rendering", "toggle", Local_Parents["Disable"], function(f)
    while f.on do
        lib.natives.SET_FOCUS_POS_AND_VEL(v3(-8292, -4596, 14358), 0.0, 0.0, 0.0)
        lib.natives.REQUEST_COLLISION_AT_COORD(player.get_player_coords(player.player_id()))
        lib.natives.OVERRIDE_LODSCALE_THIS_FRAME(0.0)
        lib.natives.SET_RENDER_HD_ONLY(true)
        system.wait()
    end
    if not f.on then
        lib.natives.CLEAR_FOCUS()
        lib.natives.OVERRIDE_LODSCALE_THIS_FRAME(1.0)
        lib.natives.SET_RENDER_HD_ONLY(false)
    end
end)

Local_Feature["Disable Conversation"] = menu.add_feature("Disable Conversation", "toggle", Local_Parents["Disable"], function(f)
    while f.on do
        if lib.natives.IS_SCRIPTED_CONVERSATION_ONGOING() then
            lib.natives.SKIP_TO_NEXT_SCRIPTED_CONVERSATION_LINE()
        end
        system.wait()
    end
end)

Local_Feature["Disable Help Text"] = menu.add_feature("Disable Help Text", "toggle", Local_Parents["Disable"], function(f)
    while f.on do
        lib.natives.HIDE_HELP_TEXT_THIS_FRAME()
        system.wait()
    end
end)

Local_Feature["Disable Prologue"] = menu.add_feature("Disable Prologue", "action", Local_Parents["Disable"], function(f)
    lib.natives.SET_PROFILE_SETTING_PROLOGUE_COMPLETE()
end)

menu.add_feature("Disable Notif Above Minimap", "action", Local_Parents["Disable"], function(f)
    for i = 0, 10000 do
        lib.natives.THEFEED_REMOVE_ITEM(i)
    end
end)

Local_Parents["TV Player"] = menu.add_feature("TV Player", "parent", Local_Parents["Misc"]).id

Local_Feature["TV Player Display"] = menu.add_feature("Display", "value_str", Local_Parents["TV Player"], function(f)
    local str_date = f.str_data[f.value + 1]
    lib.natives.SET_TV_CHANNEL(0)
    lib.natives.SET_TV_CHANNEL_PLAYLIST(0, f.str_data[f.value + 1], true)
    while f.on do
        if str_date ~= f.str_data[f.value + 1] then
            str_date = f.str_data[f.value + 1]
            lib.natives.SET_TV_CHANNEL(0)
            lib.natives.SET_TV_CHANNEL_PLAYLIST(0, f.str_data[f.value + 1], true)
        end
        lib.natives.DRAW_TV_CHANNEL(Local_Feature["TV Player Pos x"].value, Local_Feature["TV Player Pos y"].value, Local_Feature["TV Player Scale"].value, Local_Feature["TV Player Scale"].value, Local_Feature["TV Player Rotation"].value, 255, 255, 255, 255)
        system.wait()
    end
end)
:set_str_data({"ABS_AG_SPON_PL_0", "ABS_CC_PL_0", "ABS_DM_PL_0", "ABS_NM_PL", "ABS_SPON_PL_0", "LOOP_APOC_BMBL", "LOOP_CONS_BMBL", "LOOP_SCIFI_BMBL", "PL_CINEMA_ACTION", "PL_DIX_GEO_FUNHOUSE", "PL_LES1_FAME_OR_SHAME", "PL_LO_CNT", "PL_LO_RS_CUTSCENE", "PL_MP_CCTV", "PL_MP_WEAZEL", "PL_SOL_GEO_FUNHOUSE", "PL_SP_INV_EXP", "PL_SP_INV", "PL_SP_PLSH1_INTRO", "PL_SP_WORKOUT", "PL_STD_CNT", "PL_STD_WZL", "PL_TBM_GEO_FUNHOUSE", "PL_TOU_GEO_FUNHOUSE", "PL_WEB_FOS", "PL_WEB_HOWITZER", "PL_WEB_KFLF", "PL_WEB_LR1", "PL_WEB_PRB2", "PL_WEB_RANGERS"})

Local_Feature["TV Player Pos x"] = menu.add_feature("Pos x", "action_value_f", Local_Parents["TV Player"], function(f)
    local input_stat, input_val = input.get("Pos x from " .. f.min .. " to " .. f.max, "", 5, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["TV Player Pos x"].max = 1.00
Local_Feature["TV Player Pos x"].min = 0.00
Local_Feature["TV Player Pos x"].mod = 0.05
Local_Feature["TV Player Pos x"].value = 0.50

Local_Feature["TV Player Pos y"] = menu.add_feature("Pos y", "action_value_f", Local_Parents["TV Player"], function(f)
    local input_stat, input_val = input.get("Pos y from " .. f.min .. " to " .. f.max, "", 5, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["TV Player Pos y"].max = 1.00
Local_Feature["TV Player Pos y"].min = 0.00
Local_Feature["TV Player Pos y"].mod = 0.05
Local_Feature["TV Player Pos y"].value = 0.50

Local_Feature["TV Player Scale"] = menu.add_feature("Scale", "action_value_f", Local_Parents["TV Player"], function(f)
    local input_stat, input_val = input.get("Scale from " .. string.format("%.2f", f.min) .. " to " .. f.max, "", 5, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["TV Player Scale"].max = 1.00
Local_Feature["TV Player Scale"].min = 0.05
Local_Feature["TV Player Scale"].mod = 0.05
Local_Feature["TV Player Scale"].value = 0.50

Local_Feature["TV Player Rotation"] = menu.add_feature("Rotation", "action_value_f", Local_Parents["TV Player"], function(f)
    local input_stat, input_val = input.get("Rotation from " .. f.min .. " to " .. f.max, "", 6, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["TV Player Rotation"].max = 355.00
Local_Feature["TV Player Rotation"].min = 0.00
Local_Feature["TV Player Rotation"].mod = 5.00
Local_Feature["TV Player Rotation"].value = 0.00

Local_Parents["Fake Money Modifier"] = menu.add_feature("Fake Money Modifier", "parent", Local_Parents["Misc"]).id

Local_Feature["Display Current Balance"] = menu.add_feature("Display Current Balance", "toggle", Local_Parents["Fake Money Modifier"], function(f)
    while f.on do
        lib.natives.SET_MULTIPLAYER_WALLET_CASH()
        lib.natives.SET_MULTIPLAYER_BANK_CASH()
        system.wait()
    end
    lib.natives.REMOVE_MULTIPLAYER_WALLET_CASH()
    lib.natives.REMOVE_MULTIPLAYER_BANK_CASH()
end)

Local_Feature["Wallet Money Loop"] = menu.add_feature("Wallet Money Loop", "value_str", Local_Parents["Fake Money Modifier"], function(f)
    while f.on do
        system.wait(100)
        if f.value == 0 then
            lib.natives.CHANGE_FAKE_MP_CASH(100000, 0)
        elseif f.value == 1 then
            lib.natives.CHANGE_FAKE_MP_CASH(250000, 0)
        elseif f.value == 2 then
            lib.natives.CHANGE_FAKE_MP_CASH(500000, 0)
        elseif f.value == 3 then
            lib.natives.CHANGE_FAKE_MP_CASH(750000, 0)
        elseif f.value == 4 then
            lib.natives.CHANGE_FAKE_MP_CASH(1000000, 0)
        elseif f.value == 5 then
            lib.natives.CHANGE_FAKE_MP_CASH(int_max, 0)
        elseif f.value == 6 then
            lib.natives.CHANGE_FAKE_MP_CASH(math.random(1, int_max), 0)
        end
    end
end)
Local_Feature["Wallet Money Loop"]:set_str_data({"$100k", "$250k", "$500k", "$750k", "$1000k", int_max, "Random"})

Local_Feature["Bank Money Loop"] = menu.add_feature("Bank Money Loop", "value_str", Local_Parents["Fake Money Modifier"], function(f)
    while f.on do
        system.wait(100)
        if f.value == 0 then
            lib.natives.CHANGE_FAKE_MP_CASH(0, 100000)
        elseif f.value == 1 then
            lib.natives.CHANGE_FAKE_MP_CASH(0, 250000)
        elseif f.value == 2 then
            lib.natives.CHANGE_FAKE_MP_CASH(0, 500000)
        elseif f.value == 3 then
            lib.natives.CHANGE_FAKE_MP_CASH(0, 750000)
        elseif f.value == 4 then
            lib.natives.CHANGE_FAKE_MP_CASH(0, 1000000)
        elseif f.value == 5 then
            lib.natives.CHANGE_FAKE_MP_CASH(0, int_max)
        elseif f.value == 6 then
            lib.natives.CHANGE_FAKE_MP_CASH(0, math.random(1, int_max))
        end
    end
end)
Local_Feature["Bank Money Loop"]:set_str_data({"$100k", "$250k", "$500k", "$750k", "$1000k", int_max, "Random"})

menu.add_feature("Change Wallet", "action", Local_Parents["Fake Money Modifier"], function(f)
    local input_stat, input_val <const> = input.get("", "", 999, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    lib.natives.CHANGE_FAKE_MP_CASH(math.tointeger(input_val), 0)
end)

menu.add_feature("Change Bank", "action", Local_Parents["Fake Money Modifier"], function(f)
    local input_stat, input_val <const> = input.get("", "", 999, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    lib.natives.CHANGE_FAKE_MP_CASH(0, math.tointeger(input_val))
end)

Local_Parents["HUD"] = menu.add_feature("HUD", "parent", Local_Parents["Misc"]).id

for name, id in pairs(lib.table.hud) do
    Local_Feature[name] = menu.add_feature(name, "value_str", Local_Parents["HUD"], function(f)
        while f.on do
            if f.value == 0 then
                ui.show_hud_component_this_frame(id)
            else
                ui.hide_hud_component_this_frame(id)
            end
            system.wait()
        end
    end)
    Local_Feature[name]:set_str_data({"Show", "Hide"})
end

Local_Feature["Radar"] = menu.add_feature("Radar", "value_str", Local_Parents["HUD"], function(f)
    while f.on do
        if f.value == 0 then
            lib.natives.DISPLAY_RADAR(true)
        else
            lib.natives.DISPLAY_RADAR(false)
        end
        system.wait()
    end
    if not f.on then
        if lib.natives.IS_MINIMAP_RENDERING() then
            lib.natives.DISPLAY_RADAR(true)
        else
            lib.natives.DISPLAY_RADAR(false)
        end
    end
end)
Local_Feature["Radar"]:set_str_data({"Show", "Hide"})

Local_Parents["World Grid"] = menu.add_feature("World Grid", "parent", Local_Parents["Misc"]).id

Local_Feature["Grid Enable"] = menu.add_feature("Enable", "toggle", Local_Parents["World Grid"], function(f)
    while f.on do
        lib.natives.TERRAINGRID_ACTIVATE(true)
        lib.natives.TERRAINGRID_SET_PARAMS(player.get_player_coords(player.player_id()), 0.0, Local_Feature["Grid Number"].value, 0.0, Local_Feature["Grid Size"].value, Local_Feature["Grid Size"].value, 0.0, Local_Feature["Grid Scale"].value, Local_Feature["Grid Intensity"].value, 0.0, 0.0)
        lib.natives.TERRAINGRID_SET_COLOURS(255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255)
        system.wait()
    end
    if not f.on then
        lib.natives.TERRAINGRID_ACTIVATE(false)
    end
end)

Local_Feature["Grid Number"] = menu.add_feature("Number", "action_value_f", Local_Parents["World Grid"], function(f)
    local input_stat, input_val = input.get("Number from " .. f.min .. " to " .. f.max, "", 7, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Grid Number"].max = 1000.00
Local_Feature["Grid Number"].min = 1.00
Local_Feature["Grid Number"].mod = 1.00
Local_Feature["Grid Number"].value = 1.00

Local_Feature["Grid Size"] = menu.add_feature("Size", "action_value_f", Local_Parents["World Grid"], function(f)
    local input_stat, input_val = input.get("Size from " .. f.min .. " to " .. f.max, "", 8, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Grid Size"].max = 30000.00
Local_Feature["Grid Size"].min = 0.00
Local_Feature["Grid Size"].mod = 1.00
Local_Feature["Grid Size"].value = 100.00

Local_Feature["Grid Scale"] = menu.add_feature("Scale", "action_value_f", Local_Parents["World Grid"], function(f)
    local input_stat, input_val = input.get("Scale from " .. f.min .. " to " .. f.max, "", 8, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Grid Scale"].max = 30000.00
Local_Feature["Grid Scale"].min = 1.00
Local_Feature["Grid Scale"].mod = 1.00
Local_Feature["Grid Scale"].value = 100.00

Local_Feature["Grid Intensity"] = menu.add_feature("Intensity", "action_value_f", Local_Parents["World Grid"], function(f)
    local input_stat, input_val = input.get("Intensity from " .. f.min .. " to " .. f.max, "", 7, 5)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Grid Intensity"].max = 1000.00
Local_Feature["Grid Intensity"].min = 0.00
Local_Feature["Grid Intensity"].mod = 1.00
Local_Feature["Grid Intensity"].value = 100.00

Local_Parents["Visual Editor"] = menu.add_feature("Visual Editor", "parent", Local_Parents["Misc"]).id

local keyframe_saves <const> = {}

local function formatString(str)
    local parts <const> = {}
    for part in str:gmatch("[^_]+") do
        table.insert(parts, part:sub(1, 1):upper() .. part:sub(2))
    end
    return table.concat(parts, " ")
end

local originalFeatureNames <const> = {}

local updatedTimecycle <const> = {}
for oldName, featureList in pairs(lib.table.timecycle) do
    local updatedName <const> = formatString(oldName)
    local updatedFeatureList <const> = {}
    for _, featureName in ipairs(featureList) do
        local updatedFeatureName <const> = formatString(featureName)
        table.insert(updatedFeatureList, updatedFeatureName)
        originalFeatureNames[updatedFeatureName] = featureName
    end
    updatedTimecycle[updatedName] = updatedFeatureList
end
lib.table.timecycle = updatedTimecycle

local folderOrder = {
    "Blur",
    "Bokeh",
    "Chrom_Aberration",
    "Cloud",
    "Depth_Of_Field",
    "Direction",
    "Fog",
    "HH",
    "Lens",
    "Level_Of_Detail",
    "Light",
    "Moon",
    "Nvidia",
    "Particle",
    "Ped_Light",
    "PostFX",
    "Reflection",
    "Screen_Space_Ambient_Occlusion",
    "Shadow",
    "Sky",
    "Sprite",
    "Sun",
    "Water",
    "Other"
}

local updatedFolderOrder <const> = {}
for _, folderName in ipairs(folderOrder) do
    local updatedName <const> = formatString(folderName)
    table.insert(updatedFolderOrder, updatedName)
end
local folderOrder <const> = updatedFolderOrder

Local_Feature["Visual Editor Reset"] = menu.add_feature("Reset", "action", Local_Parents["Visual Editor"], function(f)
    for _, folderName in ipairs(folderOrder) do
        local featureList <const> = lib.table.timecycle[folderName]
        for _, updatedFeatureName in ipairs(featureList) do
            Local_Feature[updatedFeatureName].on = false
            Local_Feature[updatedFeatureName].value = 0.00
        end
    end
end)

Local_Feature["Enhance Graphics"] = menu.add_feature("Enhance Graphics", "action", Local_Parents["Visual Editor"], function(f)
    Local_Feature["Environmental Blur Size"].value = 10.00
    Local_Feature["Environmental Blur Size"].on = true
    Local_Feature["Fog Density"].value = 2.00
    Local_Feature["Fog Density"].on = true
    Local_Feature["Fog Haze Density"].value = 1.00
    Local_Feature["Fog Haze Density"].on = true
    Local_Feature["Fog Horizon Tint Scale"].value = 1.00
    Local_Feature["Fog Horizon Tint Scale"].on = true
    Local_Feature["Fog Moon Col B"].value = 2.00
    Local_Feature["Fog Moon Col B"].on = true
    Local_Feature["Fog Volume Light Range"].value = 1000.00
    Local_Feature["Fog Volume Light Range"].on = true
    Local_Feature["Fog Volume Light Size"].value = 1.00
    Local_Feature["Fog Volume Light Size"].on = true
    Local_Feature["Sky Moon Disc Size"].value = 10.00
    Local_Feature["Sky Moon Disc Size"].on = true
    Local_Feature["Sky Moon Iten"].value = 25.00
    Local_Feature["Sky Moon Iten"].on = true
    Local_Feature["Postfx Desaturation"].value = 1.50
    Local_Feature["Postfx Desaturation"].on = true
    Local_Feature["Reflection Hdr Mult"].value = 5.00
    Local_Feature["Reflection Hdr Mult"].on = true
    Local_Feature["Reflection Tweak Directional"].value = 5.00
    Local_Feature["Reflection Tweak Directional"].on = true
    Local_Feature["Ssao Type"].value = 10.00
    Local_Feature["Ssao Type"].on = true
    Local_Feature["Dir Shadow Cascade0 Scale"].value = 5.00
    Local_Feature["Dir Shadow Cascade0 Scale"].on = true
    Local_Feature["Dir Shadow Distance Multiplier"].value = 10.00
    Local_Feature["Dir Shadow Distance Multiplier"].on = true
    Local_Feature["Sky Stars Iten"].value = 5.00
    Local_Feature["Sky Stars Iten"].on = true
    Local_Feature["Sky Sun Mie Intensity Mult"].value = 25.00
    Local_Feature["Sky Sun Mie Intensity Mult"].on = true
    Local_Feature["Wind Speed Mult"].value = 5.00
    Local_Feature["Wind Speed Mult"].on = true
end)

for _, folderName in ipairs(folderOrder) do
    Local_Parents[folderName] = menu.add_feature(folderName, "parent", Local_Parents["Visual Editor"]).id
    local featureList <const> = lib.table.timecycle[folderName]
    for _, updatedFeatureName in ipairs(featureList) do
        local originalFeatureName <const> = originalFeatureNames[updatedFeatureName]
        for _, weather in pairs(lib.table.weather) do
            for frame = 0, 12 do
                local hash <const> = gameplay.get_hash_key(weather)
                local value <const> = timecycle.get_timecycle_keyframe_var(hash, 1, frame, originalFeatureName)
                keyframe_saves[hash] = keyframe_saves[hash] or {}
                keyframe_saves[hash][frame] = keyframe_saves[hash][frame] or {}
                keyframe_saves[hash][frame][originalFeatureName] = value
            end
        end
        Local_Feature[updatedFeatureName] = menu.add_feature(updatedFeatureName, "value_f", Local_Parents[folderName], function(f)
            while f.on do
                for _, weather in pairs(lib.table.weather) do
                    for frame = 0, 12 do
                        for region = 1, 2 do
                            local hash <const> = gameplay.get_hash_key(weather)
                            timecycle.set_timecycle_keyframe_var(hash, region, frame, originalFeatureName, string.format("%.1f", f.value))
                        end
                    end
                end
                system.wait()
            end
            if not f.on then
                for _, weather in pairs(lib.table.weather) do
                    for frame = 0, 12 do
                        for region = 1, 2 do
                            local hash <const> = gameplay.get_hash_key(weather)
                            timecycle.set_timecycle_keyframe_var(hash, region, frame, originalFeatureName, keyframe_saves[hash][frame][originalFeatureName])
                        end
                    end
                end
            end
        end)
        Local_Feature[updatedFeatureName].max = 1000.00
        Local_Feature[updatedFeatureName].min = -1000.00
        Local_Feature[updatedFeatureName].mod = 1.00
        Local_Feature[updatedFeatureName].value = 0.00
    end
end

Local_Parents["World State"] = menu.add_feature("World State", "parent", Local_Parents["Misc"]).id

Local_Feature["Story Mode"] = menu.add_feature("Story Mode", "action", Local_Parents["World State"], function(f)
    lib.natives.ON_ENTER_SP()
end)

Local_Feature["Online"] = menu.add_feature("Online", "action", Local_Parents["World State"], function(f)
    lib.natives.ON_ENTER_MP()
end)

Local_Parents["Minimap"] = menu.add_feature("Minimap", "parent", Local_Parents["Misc"]).id

Local_Feature["Set Minimap"] = menu.add_feature("Set Minimap", "value_str", Local_Parents["Minimap"], function(f)
    while f.on do
        if f.value == 0 then
            lib.natives.SET_MINIMAP_IN_PROLOGUE(true)
            lib.natives.SET_USE_ISLAND_MAP(false)
        else
            lib.natives.SET_MINIMAP_IN_PROLOGUE(false)
            lib.natives.SET_USE_ISLAND_MAP(true)
        end
        system.wait()
    end
    if not f.on then
        lib.natives.SET_MINIMAP_IN_PROLOGUE(false)
        lib.natives.SET_USE_ISLAND_MAP(false)
    end
end)
Local_Feature["Set Minimap"]:set_str_data({"North Yankton", "Cayo Perico"})

Local_Feature["Reveal Entire SP Map"] = menu.add_feature("Reveal Entire SP Map", "toggle", Local_Parents["Minimap"], function(f)
    while f.on do
        lib.natives.SET_MINIMAP_HIDE_FOW(true)
        system.wait()
    end
    if not f.on then
        lib.natives.SET_MINIMAP_HIDE_FOW(false)
    end
end)

Local_Parents["Teleport"] = menu.add_feature("Teleport", "parent", Local_Parents["Misc"]).id

Local_Feature["Teleport To Waypoint"] = menu.add_feature("Teleport To Waypoint", "toggle", Local_Parents["Teleport"], function(f)
    while f.on do
        if lib.natives.IS_WAYPOINT_ACTIVE() then
            local waypoint <const> = ui.get_waypoint_coord()
            ui.set_waypoint_off()
            entity.set_entity_coords_no_offset(player.player_ped(), v3(waypoint.x, waypoint.y, lib.essentials.get_ground_z(waypoint) + 0.7))
        end
        system.wait()
    end
end)

Local_Feature["Teleport To Random Pos"] = menu.add_feature("Teleport To Random Pos", "action", Local_Parents["Teleport"], function(f)
    local pos, ground_z
    repeat
        repeat
            pos = v2(math.random(-4000, 4500), math.random(-4000, 8000))
            entity.set_entity_coords_no_offset(player.player_ped(), v3(pos.x, pos.y, -5))
            system.wait()
        until not entity.is_entity_in_water(player.player_ped())
        entity.set_entity_coords_no_offset(player.player_ped(), v3(pos.x, pos.y, 50))
        ground_z, status = lib.essentials.get_ground_z(pos)
    until status
    entity.set_entity_coords_no_offset(player.player_ped(), v3(pos.x, pos.y, ground_z + 0.7))
end)

local TugTable <const> = {
    twoCarTugDeleteTable = {},
    twoCarTugDeleteTableNames = {"none"},
}

Local_Parents["Entity Tugs"] = menu.add_feature("Entity Tugs", "parent", Local_Parents["Misc"]).id

function addTugFeature(featName, parent, mainEntity, tuggedEntity, twoEntityCheck)
    Local_Feature[featName] = menu.add_feature(featName, "value_i", parent, function(f)
        local stuffTable <const> = {}
        stuffTable["twoEntity"] = twoEntityCheck
        if tuggedEntity then
            while f.on do
                stuffTable["range"] = v3(f.value, f.value, f.value)
                if stuffTable["twoEntity"] then
                    stuffTable["originalOffset"] = entity.get_entity_coords(mainEntity) - entity.get_entity_coords(tuggedEntity)
                end
                if (stuffTable["originalOffset"].x > stuffTable["range"].x or stuffTable["originalOffset"].y > stuffTable["range"].y or stuffTable["originalOffset"].z > stuffTable["range"].z) or (stuffTable["originalOffset"].x < -stuffTable["range"].x or stuffTable["originalOffset"].y < -stuffTable["range"].y or stuffTable["originalOffset"].z < -stuffTable["range"].z) then
                    stuffTable["offset"] = stuffTable["originalOffset"]
                    if Local_Feature["Strong Tug"].on then
                        for i = 140, 1.5, -0.5 do
                            if (stuffTable["originalOffset"].x > (stuffTable["range"].x * i) or stuffTable["originalOffset"].y > (stuffTable["range"].y * i) or stuffTable["originalOffset"].z > (stuffTable["range"].z) * i) or (stuffTable["originalOffset"].x < (-stuffTable["range"].x * i) or stuffTable["originalOffset"].y < (-stuffTable["range"].y * i) or stuffTable["originalOffset"].z < (-stuffTable["range"].z * i)) then
                                stuffTable["offset"].x = stuffTable["offset"].x * i
                                stuffTable["offset"].y = stuffTable["offset"].y * i
                                stuffTable["offset"].z = stuffTable["offset"].z * i
                                break
                            end
                        end
                    end
                    while not network.has_control_of_entity(tuggedEntity) do
                        network.request_control_of_entity(tuggedEntity)
                        system.wait()
                    end
                    entity.set_entity_max_speed(tuggedEntity, 45000)
                    entity.set_entity_velocity(tuggedEntity, stuffTable["offset"])
                end
                system.wait()
            end
        end
    end)
    Local_Feature[featName].min = -10
    Local_Feature[featName].max = 100
    Local_Feature[featName].mod = 1
    Local_Feature[featName].value = 5
    return Local_Feature[featName]
end

function entityCheck(entityID)
    local entityName
    if entity.is_entity_a_ped(entityID) then
        entityName = entity.get_entity_model_hash(entityID)
    elseif entity.is_entity_a_vehicle(entityID) then
        entityName = vehicle.get_vehicle_model(entityID)
    else
        lua_notify_alert("Entity isn't a ped or a vehicle.", "Set Entity Tug")
        return "HANDLER_POP"
    end
    return entityName
end

function getEntity(message, modderCheck)
    local Key <const> = MenuKey()
    Key:push_vk(0x58)
    while Key:is_down() do
        system.wait()
    end
    while not Key:is_down() do
        system.wait()
    end
    local setEntity = player.get_entity_player_is_aiming_at(player.player_id())
    if modderCheck and ped.is_ped_a_player(setEntity) then
        for pid in lib.player.list(true) do
            if player.is_player_valid(pid) and player.get_player_ped(pid) == setEntity and player.is_player_modder(pid, -1) then
                if message then
                    lua_notify_alert(message, "Set Entity Tug")
                end
                return "HANDLER_POP"
            end
        end
    end
    if entity.is_entity_a_ped(setEntity) and ped.is_ped_in_any_vehicle(setEntity) then
        setEntity = ped.get_vehicle_ped_is_using(setEntity)
    end
    if setEntity == 0 or (entity.is_entity_a_ped(setEntity) and entity.is_entity_dead(setEntity)) or entity.is_entity_an_object(setEntity) then
        lua_notify_alert("You probably got a dead ped, nothing or an object.", "Set Entity Tug")
        return "HANDLER_POP"
    end
    return setEntity
end

function addEntityTug(entityTable)
    local entityNames <const> = {}
    for i = 1, 2 do
        entityNames[i] = entityCheck(entityTable[i])
        if entityNames[i] == "HANDLER_POP" then
            return HANDLER_POP
        end
    end
    local feat <const> = addTugFeature(entityNames[1] .. " - " .. entityNames[2], Local_Parents["Entity Tugs"], entityTable[1], entityTable[2], true)
    feat.on = true
    TugTable.twoCarTugDeleteTable[#TugTable.twoCarTugDeleteTable + 1] = feat.id
    TugTable.twoCarTugDeleteTableNames[#TugTable.twoCarTugDeleteTableNames + 1] = entityNames[1] .. " - " .. entityNames[2]
    Local_Feature["Delete Tugs"]:set_str_data(TugTable.twoCarTugDeleteTableNames)
    lua_notify("Added Entity Tug.", "Set Entity Tug")
end

Local_Feature["Set Entity Tug"] = menu.add_feature("Set Entity Tug", "action", Local_Parents["Entity Tugs"], function(f)
    lua_notify("Press X while aiming at first entity.", "Set Entity Tug")
    local entityTable <const> = {}
    for i = 1, 2 do
        if i == 2 then
            entityTable[i] = getEntity("Second entity can't be a modder.", true)
        else
            entityTable[i] = getEntity("", false)
        end
        if entityTable[i] == "HANDLER_POP" then
            return HANDLER_POP
        end
        if i == 1 then
            lua_notify("Press X while aiming at second entity to Tug.", "Set Entity Tug")
        end
        if entityTable[2] == entityTable[1] then
            lua_notify_alert("Second entity cant be the same as the first one.", "Set Entity Tug")
            return HANDLER_POP
        end
        if i == 2 then
            if ped.is_ped_a_player(entityTable[2]) then
                lua_notify_alert("Second entity cant be a player ped.", "Set Entity Tug")
                return HANDLER_POP
            end
        end
        system.wait()
    end
    addEntityTug(entityTable)
end)

Local_Feature["Strong Tug"] = menu.add_feature("Strong Tug", "toggle", Local_Parents["Entity Tugs"], function(f)
end)

Local_Feature["Delete Tugs"] = menu.add_feature("Delete Tugs", "action_value_str", Local_Parents["Entity Tugs"], function(f)
    if f.value ~= 0 then
        menu.delete_feature(TugTable.twoCarTugDeleteTable[f.value])
        table.remove(TugTable.twoCarTugDeleteTable, f.value)
        table.remove(TugTable.twoCarTugDeleteTableNames, f.value + 1)
        Local_Feature["Delete Tugs"]:set_str_data(TugTable.twoCarTugDeleteTableNames)
    end
end)
Local_Feature["Delete Tugs"]:set_str_data(TugTable.twoCarTugDeleteTableNames)


Local_Feature["Set Shadow Distance"] = menu.add_feature("Set Shadow Distance", "value_f", Local_Parents["Misc"], function(f)
    while f.on do
        lib.natives.CASCADE_SHADOWS_SET_CASCADE_BOUNDS_SCALE(f.value)
        system.wait()
    end
end)
Local_Feature["Set Shadow Distance"].max = 10.00
Local_Feature["Set Shadow Distance"].min = 0.00
Local_Feature["Set Shadow Distance"].mod = 0.10
Local_Feature["Set Shadow Distance"].value = 0.00

Local_Feature["Render HD Only"] = menu.add_feature("Render HD Only", "toggle", Local_Parents["Misc"], function(f)
    while f.on do
        lib.natives.SET_RENDER_HD_ONLY(true)
        system.wait()
    end
    lib.natives.SET_RENDER_HD_ONLY(false)
end)

Local_Feature["Deleted Population"] = menu.add_feature("Deleted Population", "toggle", Local_Parents["Misc"], function(f)
    local pop_multiplier_id <const> = lib.natives.ADD_POP_MULTIPLIER_SPHERE(0.0, 0.0, 0.0, 20000.0, 0.0, 0.0, false, true)
    while f.on do
        lib.natives.CLEAR_AREA(0.0, 0.0, 0.0, 20000.0, true, false, false, true)
        system.wait()
    end
    lib.natives.REMOVE_POP_MULTIPLIER_SPHERE(pop_multiplier_id, false)
end)

Local_Feature["Potato Mode"] = menu.add_feature("Potato Mode", "toggle", Local_Parents["Misc"], function(f)
    while f.on do
        lib.natives.SET_FOCUS_POS_AND_VEL(v3(-8292, -4596, 14358), 0.0, 0.0, 0.0)
        lib.natives.REQUEST_COLLISION_AT_COORD(player.get_player_coords(player.player_id()))
        system.wait()
    end
    if not f.on then
        lib.natives.CLEAR_FOCUS()
    end
end)

Local_Feature["Set Time Scale"] = menu.add_feature("Set Time Scale", "value_f", Local_Parents["Misc"], function(f)
    while f.on do
        lib.natives.SET_TIME_SCALE(f.value)
        system.wait()
    end
end)
Local_Feature["Set Time Scale"].max = 1.00
Local_Feature["Set Time Scale"].min = 0.00
Local_Feature["Set Time Scale"].mod = 0.10
Local_Feature["Set Time Scale"].value = 0.00

Local_Feature["Moon Cycle"] = menu.add_feature("Moon Cycle", "value_f", Local_Parents["Misc"], function(f)
    while f.on do
        lib.natives.ENABLE_MOON_CYCLE_OVERRIDE(f.value)
        system.wait()
    end
    if not f.on then
        lib.natives.DISABLE_MOON_CYCLE_OVERRIDE()
    end
end)
Local_Feature["Moon Cycle"].max = 1.00
Local_Feature["Moon Cycle"].min = 0.00
Local_Feature["Moon Cycle"].mod = 0.10
Local_Feature["Moon Cycle"].value = 0.00

Local_Feature["Set Game High Priority"] = menu.add_feature("Set Game High Priority", "toggle", Local_Parents["Misc"], function(f)
    while f.on do
        lib.natives.SET_SCRIPT_HIGH_PRIO(true)
        system.wait()
    end
    if not f.on then
        lib.natives.SET_SCRIPT_HIGH_PRIO(false)
    end
end)

Local_Feature["FPS Limiter"] = menu.add_feature("FPS Limiter", "value_i", Local_Parents["Misc"], function(f)
    while f.on do
        local timer <const> = utils.time_ms() + (1000 / f.value)
        system.wait()
        while timer > utils.time_ms() do end
    end
end)
Local_Feature["FPS Limiter"].min = 5
Local_Feature["FPS Limiter"].max = 240
Local_Feature["FPS Limiter"].mod = 5
Local_Feature["FPS Limiter"].value = 60

Local_Feature["Give All Achievements"] = menu.add_feature("Give All Achievements", "action", Local_Parents["Misc"], function(f)
    for i = 1, 77 do
        lib.natives.GIVE_ACHIEVEMENT_TO_PLAYER(i)
    end
end)

Local_Feature["Pause Screen Movement"] = menu.add_feature("Pause Screen Movement", "toggle", Local_Parents["Misc"], function(f)
    if f.on then
        lib.natives.TOGGLE_PAUSED_RENDERPHASES(false)
    end
    if not f.on then
        lib.natives.TOGGLE_PAUSED_RENDERPHASES(true)
    end
end)

Local_Feature["Pause Game"] = menu.add_feature("Pause Game", "toggle", Local_Parents["Misc"], function(f)
    if f.on then
        lib.natives.SET_GAME_PAUSED(true)
    end
    if not f.on then
        lib.natives.SET_GAME_PAUSED(false)
    end
end)

Local_Feature["Snow Footstep"] = menu.add_feature("Snow Footstep", "toggle", Local_Parents["Misc"], function(f)
    lib.natives.USE_SNOW_FOOT_VFX_WHEN_UNSHELTERED(f.on)
end)

Local_Feature["Unbrick Account"] = menu.add_feature("Unbrick Account", "action", Local_Parents["Misc"], function(f)
    stats.stat_set_int(gameplay.get_hash_key("MPPLY_LAST_MP_CHAR"), 0, true)
end)

Local_Feature["FPS Booster"] = menu.add_feature("FPS Booster", "value_str", Local_Parents["Misc"], function(f)
    local frame_count
    Threads["Frame Count"] = menu.create_thread(function()
        while f.on do
            frame_count = math.ceil(1 / gameplay.get_frame_time())
            system.wait(500)
        end
    end)
    system.wait()
    while f.on do
        if f.value == 0 then
            local time <const> = utils.time_ms() + 5000
            if frame_count < 70 and frame_count > 50 then
                while frame_count < 60 and frame_count > 50 and f.on do
                    lib.natives.OVERRIDE_LODSCALE_THIS_FRAME(0.7)
                    system.wait()
                end
                while time > utils.time_ms() do
                    lib.natives.OVERRIDE_LODSCALE_THIS_FRAME(0.7)
                    system.wait()
                end
            end
            if frame_count < 50 and frame_count > 40 then
                while frame_count < 60 and frame_count > 40 and f.on do
                    lib.natives.OVERRIDE_LODSCALE_THIS_FRAME(0.5)
                    system.wait()
                end
                while time > utils.time_ms() do
                    lib.natives.OVERRIDE_LODSCALE_THIS_FRAME(0.5)
                    system.wait()
                end
            end
            if frame_count < 40 then
                while frame_count < 70 and f.on do
                    lib.natives.OVERRIDE_LODSCALE_THIS_FRAME(0.3)
                    system.wait()
                end
                while time > utils.time_ms() do
                    lib.natives.OVERRIDE_LODSCALE_THIS_FRAME(0.3)
                    system.wait()
                end
            end
            system.wait(5000)
        elseif f.value == 1 then
            lib.natives.OVERRIDE_LODSCALE_THIS_FRAME(0.7)
        elseif f.value == 2 then
            lib.natives.OVERRIDE_LODSCALE_THIS_FRAME(0.5)
        elseif f.value == 3 then
            lib.natives.OVERRIDE_LODSCALE_THIS_FRAME(0.3)
        end
        system.wait()
    end
    if not f.on then
        menu.delete_thread(Threads["Frame Count"])
    end
end)
Local_Feature["FPS Booster"]:set_str_data({"Auto", "Soft", "Medium", "Hard"})

Local_Feature["Screenshot Mode"] = menu.add_feature("Screenshot Mode", "toggle", Local_Parents["Misc"], function(f)
    local toggle_overlay <const> = menu.get_feature_by_hierarchy_key("local.settings.info_overlay.toggle_overlay").on == true
    while f.on do
        for i = 1, 22 do
            ui.hide_hud_component_this_frame(i)
        end
        ui.hide_hud_and_radar_this_frame()
        lib.natives.THEFEED_HIDE_THIS_FRAME()
        menu.clear_all_notifications()
        menu.get_feature_by_hierarchy_key("local.settings.info_overlay.toggle_overlay").on = false
        system.wait()
    end
    if not f.on and toggle_overlay then
        menu.get_feature_by_hierarchy_key("local.settings.info_overlay.toggle_overlay").on = true
    end
end)

Local_Parents["Settings"] = menu.add_feature("Settings", "parent", Local_Parents["Local Prents"]).id

Local_Parents["Player Feature"] = menu.add_feature("Player Feature", "parent", Local_Parents["Settings"]).id

Local_Feature["Running Time Control Vehicle"] = menu.add_feature("Running Time Control Vehicle", "action_value_i", Local_Parents["Player Feature"], function(f)
    local input_stat, input_val = input.get("Running Time Control Vehicle from " .. f.min .. " to " .. f.max, "", 7, 3)
    if input_stat == 1 then
        return HANDLER_CONTINUE
    end
    if input_stat == 2 then
        lua_notify_alert("Input canceled.", f.name)
        return HANDLER_POP
    end
    input_val = tonumber(input_val)
    if input_val > f.max then
        f.value = f.max
    elseif input_val < f.min then
        f.value = f.min
    else
        f.value = input_val
    end
end)
Local_Feature["Running Time Control Vehicle"].max = 3000000
Local_Feature["Running Time Control Vehicle"].min = 1
Local_Feature["Running Time Control Vehicle"].mod = 1
Local_Feature["Running Time Control Vehicle"].value = 1000

Local_Parents["Start-up Sound"] = menu.add_feature("Start-up Sound", "parent", Local_Parents["Settings"]).id

function Disable_Start_up_Sound_Feature()
    Local_Feature["Start-up Pin Bad Sound"].on = false
    Local_Feature["Start-up Power Down Sound"].on = false
    Local_Feature["Start-up Hack Success Sound"].on = false
    Local_Feature["Start-up Tennis Point Won Sound"].on = false
    Local_Feature["Start-up Air Defenses Disabled Sound"].on = false
    Local_Feature["Start-up Timer Stop Sound"].on = false
    Local_Feature["Start-up 3 2 1 Sound"].on = false
    Local_Feature["Start-up Bomb Disarmed Sound"].on = false
    Local_Feature["Start-up 1st Person Transition Sound"].on = false
    Local_Feature["Start-up Base Jump Passed Sound"].on = false
    Local_Feature["Start-up Turn Sound"].on = false
    Local_Feature["Start-up Success Sound"].on = false
    Local_Feature["Start-up Start Sound"].on = false
    Local_Feature["Start-up Pin Good Sound"].on = false
    Local_Feature["Start-up Parcel Vehicle Lost Sound"].on = false
    Local_Feature["Start-up Out Of Area Sound"].on = false
    Local_Feature["Start-up Other Text Sound"].on = false
    Local_Feature["Start-up OOB Start Sound"].on = false
end

Local_Feature["Start-up Pin Bad Sound"] = menu.add_feature("Pin Bad", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Pin_Bad", player.player_ped(), "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up Parcel Vehicle Lost Sound"] = menu.add_feature("Parcel Vehicle Lost", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Parcel_Vehicle_Lost", player.player_ped(), "GTAO_FM_Events_Soundset", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up Bomb Disarmed Sound"] = menu.add_feature("Bomb Disarmed", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Bomb_Disarmed", player.player_ped(), "GTAO_Speed_Convoy_Soundset", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up 1st Person Transition Sound"] = menu.add_feature("1st Person Transition", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "1st_Person_Transition", player.player_ped(), "PLAYER_SWITCH_CUSTOM_SOUNDSET", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up Base Jump Passed Sound"] = menu.add_feature("Base Jump Passed", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "BASE_JUMP_PASSED", player.player_ped(), "HUD_AWARDS", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up Start Sound"] = menu.add_feature("Start", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Start", player.player_ped(), "DLC_HEIST_HACKING_SNAKE_SOUNDS", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up Pin Good Sound"] = menu.add_feature("Pin Good", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Pin_Good", player.player_ped(), "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up Turn Sound"] = menu.add_feature("Turn", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Turn", player.player_ped(), "DLC_HEIST_HACKING_SNAKE_SOUNDS", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up Power Down Sound"] = menu.add_feature("Power Down", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Power_Down", player.player_ped(), "DLC_HEIST_HACKING_SNAKE_SOUNDS", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up Hack Success Sound"] = menu.add_feature("Hack Success", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Hack_Success", player.player_ped(), "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up Tennis Point Won Sound"] = menu.add_feature("Tennis Point Won", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "TENNIS_POINT_WON", player.player_ped(), "HUD_AWARDS", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up Air Defenses Disabled Sound"] = menu.add_feature("Air Defenses Disabled", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Air_Defenses_Disabled", player.player_ped(), "DLC_sum20_Business_Battle_AC_Sounds", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up Out Of Area Sound"] = menu.add_feature("Out Of Area", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Out_Of_Area", player.player_ped(), "DLC_Lowrider_Relay_Race_Sounds", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up Other Text Sound"] = menu.add_feature("Other Text", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "OTHER_TEXT", player.player_ped(), "HUD_AWARDS", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up OOB Start Sound"] = menu.add_feature("OOB Start", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "OOB_Start", player.player_ped(), "GTAO_FM_Events_Soundset", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up 3 2 1 Sound"] = menu.add_feature("3 2 1", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "3_2_1", player.player_ped(), "HUD_MINI_GAME_SOUNDSET", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up Timer Stop Sound"] = menu.add_feature("Timer Stop", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "TIMER_STOP", player.player_ped(), "HUD_MINI_GAME_SOUNDSET", false)
    while f.on do system.wait() end
end)

Local_Feature["Start-up Success Sound"] = menu.add_feature("Success", "toggle", Local_Parents["Start-up Sound"], function(f)
    Disable_Start_up_Sound_Feature()
    f.on = true
    lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Success", player.player_ped(), "DLC_HEIST_HACKING_SNAKE_SOUNDS", false)
    while f.on do system.wait() end
end)

Local_Parents["Ending Sound"] = menu.add_feature("Ending Sound", "parent", Local_Parents["Settings"], function()
    Ending_Sound_Load = true
end).id

function Disable_Ending_Sound_Feature()
    Local_Feature["Ending Pin Bad Sound"].on = false
    Local_Feature["Ending Power Down Sound"].on = false
    Local_Feature["Ending Hack Success Sound"].on = false
    Local_Feature["Ending Tennis Point Won Sound"].on = false
    Local_Feature["Ending Air Defenses Disabled Sound"].on = false
    Local_Feature["Ending Timer Stop Sound"].on = false
    Local_Feature["Ending 3 2 1 Sound"].on = false
    Local_Feature["Ending Bomb Disarmed Sound"].on = false
    Local_Feature["Ending 1st Person Transition Sound"].on = false
    Local_Feature["Ending Base Jump Passed Sound"].on = false
    Local_Feature["Ending Turn Sound"].on = false
    Local_Feature["Ending Success Sound"].on = false
    Local_Feature["Ending Start Sound"].on = false
    Local_Feature["Ending Pin Good Sound"].on = false
    Local_Feature["Ending Parcel Vehicle Lost Sound"].on = false
    Local_Feature["Ending Out Of Area Sound"].on = false
    Local_Feature["Ending Other Text Sound"].on = false
    Local_Feature["Ending OOB Start Sound"].on = false
end

Local_Feature["Ending Pin Bad Sound"] = menu.add_feature("Pin Bad", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Pin_Bad", player.player_ped(), "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending Parcel Vehicle Lost Sound"] = menu.add_feature("Parcel Vehicle Lost", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Parcel_Vehicle_Lost", player.player_ped(), "GTAO_FM_Events_Soundset", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending Bomb Disarmed Sound"] = menu.add_feature("Bomb Disarmed", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Bomb_Disarmed", player.player_ped(), "GTAO_Speed_Convoy_Soundset", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending 1st Person Transition Sound"] = menu.add_feature("1st Person Transition", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "1st_Person_Transition", player.player_ped(), "PLAYER_SWITCH_CUSTOM_SOUNDSET", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending Base Jump Passed Sound"] = menu.add_feature("Base Jump Passed", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "BASE_JUMP_PASSED", player.player_ped(), "HUD_AWARDS", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending Start Sound"] = menu.add_feature("Start", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Start", player.player_ped(), "DLC_HEIST_HACKING_SNAKE_SOUNDS", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending Pin Good Sound"] = menu.add_feature("Pin Good", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Pin_Good", player.player_ped(), "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending Turn Sound"] = menu.add_feature("Turn", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Turn", player.player_ped(), "DLC_HEIST_HACKING_SNAKE_SOUNDS", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending Power Down Sound"] = menu.add_feature("Power Down", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Power_Down", player.player_ped(), "DLC_HEIST_HACKING_SNAKE_SOUNDS", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending Hack Success Sound"] = menu.add_feature("Hack Success", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Hack_Success", player.player_ped(), "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending Tennis Point Won Sound"] = menu.add_feature("Tennis Point Won", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "TENNIS_POINT_WON", player.player_ped(), "HUD_AWARDS", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending Air Defenses Disabled Sound"] = menu.add_feature("Air Defenses Disabled", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Air_Defenses_Disabled", player.player_ped(), "DLC_sum20_Business_Battle_AC_Sounds", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending Out Of Area Sound"] = menu.add_feature("Out Of Area", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Out_Of_Area", player.player_ped(), "DLC_Lowrider_Relay_Race_Sounds", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending Other Text Sound"] = menu.add_feature("Other Text", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "OTHER_TEXT", player.player_ped(), "HUD_AWARDS", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending OOB Start Sound"] = menu.add_feature("OOB Start", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "OOB_Start", player.player_ped(), "GTAO_FM_Events_Soundset", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending 3 2 1 Sound"] = menu.add_feature("3 2 1", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "3_2_1", player.player_ped(), "HUD_MINI_GAME_SOUNDSET", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending Timer Stop Sound"] = menu.add_feature("Timer Stop", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "TIMER_STOP", player.player_ped(), "HUD_MINI_GAME_SOUNDSET", false)
    end
    while f.on do system.wait() end
end)

Local_Feature["Ending Success Sound"] = menu.add_feature("Success", "toggle", Local_Parents["Ending Sound"], function(f)
    Disable_Ending_Sound_Feature()
    f.on = true
    if Ending_Sound_Load then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Success", player.player_ped(), "DLC_HEIST_HACKING_SNAKE_SOUNDS", false)
    end
    while f.on do system.wait() end
end)

Local_Parents["Feature Types"] = menu.add_feature("Feature Types", "parent", Local_Parents["Settings"]).id

Local_Feature["Feature Types toggle"] = menu.add_feature("toggle", "toggle", Local_Parents["Feature Types"], function(f)
    lua_notify(f.on, f.name)
    while f.on do
        lua_notify("toggle", "Feature Types")
        system.wait()
    end
end)

Local_Feature["Feature Types action"] = menu.add_feature("action", "action", Local_Parents["Feature Types"], function(f)
    lua_notify(f.on, f.name)
    lua_notify("action", "Feature Types")
end)

Local_Feature["Feature Types value_i"] = menu.add_feature("value_i", "value_i", Local_Parents["Feature Types"], function(f)
    lua_notify(f.value, f.name)
    while f.on do
        lua_notify("value_i = " .. f.value, "Feature Types")
        system.wait()
    end
end)
Local_Feature["Feature Types value_i"].max = 10
Local_Feature["Feature Types value_i"].min = 0
Local_Feature["Feature Types value_i"].mod = 1
Local_Feature["Feature Types value_i"].value = 0

Local_Feature["Feature Types value_f"] = menu.add_feature("value_f", "value_f", Local_Parents["Feature Types"], function(f)
    lua_notify(f.value, f.name)
    while f.on do
        local fix_float
        f.value, fix_float = lib.essentials.fix_float(f.value)
        lua_notify("value_f = " .. fix_float, "Feature Types")
        system.wait()
    end
end)
Local_Feature["Feature Types value_f"].max = 1.00
Local_Feature["Feature Types value_f"].min = 0.00
Local_Feature["Feature Types value_f"].mod = 0.10
Local_Feature["Feature Types value_f"].value = 0.00

Local_Feature["Feature Types slider"] = menu.add_feature("slider", "slider", Local_Parents["Feature Types"], function(f)
    lua_notify(f.value, f.name)
    while f.on do
        local fix_float
        f.value, fix_float = lib.essentials.fix_float(f.value)
        lua_notify("slider = " .. fix_float, "Feature Types")
        system.wait()
    end
end)
Local_Feature["Feature Types slider"].max = 1.00
Local_Feature["Feature Types slider"].min = 0.00
Local_Feature["Feature Types slider"].mod = 0.10
Local_Feature["Feature Types slider"].value = 0.00

Local_Feature["Feature Types value_str"] = menu.add_feature("value_str", "value_str", Local_Parents["Feature Types"], function(f)
    while f.on do
        lua_notify("value_str = " .. f.str_data[f.value + 1], "Feature Types")
        system.wait()
    end
end)
Local_Feature["Feature Types value_str"]:set_str_data({"v1", "v2", "v3"})

Local_Feature["Feature Types action_value_i"] = menu.add_feature("action_value_i", "action_value_i", Local_Parents["Feature Types"], function(f)
    lua_notify("action_value_i = " .. f.value, "Feature Types")
end)
Local_Feature["Feature Types action_value_i"].max = 10
Local_Feature["Feature Types action_value_i"].min = 0
Local_Feature["Feature Types action_value_i"].mod = 1
Local_Feature["Feature Types action_value_i"].value = 0

Local_Feature["Feature Types action_value_f"] = menu.add_feature("action_value_f", "action_value_f", Local_Parents["Feature Types"], function(f)
    local fix_float
    f.value, fix_float = lib.essentials.fix_float(f.value)
    lua_notify("action_value_f = " .. fix_float, "Feature Types")
end)
Local_Feature["Feature Types action_value_f"].max = 1.00
Local_Feature["Feature Types action_value_f"].min = 0.00
Local_Feature["Feature Types action_value_f"].mod = 0.10
Local_Feature["Feature Types action_value_f"].value = 0.00

Local_Feature["Feature Types action_slider"] = menu.add_feature("action_slider", "action_slider", Local_Parents["Feature Types"], function(f)
    lua_notify("action_slider = " .. string.format("%.2f", f.value), "Feature Types")
end)
Local_Feature["Feature Types action_slider"].max = 1.00
Local_Feature["Feature Types action_slider"].min = 0.00
Local_Feature["Feature Types action_slider"].mod = 0.10
Local_Feature["Feature Types action_slider"].value = 0.00

Local_Feature["Feature Types action_value_str"] = menu.add_feature("action_value_str", "action_value_str", Local_Parents["Feature Types"], function(f)
    lua_notify("action_value_str = " .. f.str_data[f.value + 1], "Feature Types")
end)
Local_Feature["Feature Types action_value_str"]:set_str_data({"v1", "v2", "v3"})

Local_Feature["Feature Types autoaction_value_i"] = menu.add_feature("autoaction_value_i", "autoaction_value_i", Local_Parents["Feature Types"], function(f)
    lua_notify("autoaction_value_i = " .. f.value, "Feature Types")
end)
Local_Feature["Feature Types autoaction_value_i"].max = 10
Local_Feature["Feature Types autoaction_value_i"].min = 0
Local_Feature["Feature Types autoaction_value_i"].mod = 1
Local_Feature["Feature Types autoaction_value_i"].value = 0

Local_Feature["Feature Types autoaction_value_f"] = menu.add_feature("autoaction_value_f", "autoaction_value_f", Local_Parents["Feature Types"], function(f)
    local fix_float
    f.value, fix_float = lib.essentials.fix_float(f.value)
    lua_notify("autoaction_value_f = " .. fix_float, "Feature Types")
end)
Local_Feature["Feature Types autoaction_value_f"].max = 1.00
Local_Feature["Feature Types autoaction_value_f"].min = 0.00
Local_Feature["Feature Types autoaction_value_f"].mod = 0.10
Local_Feature["Feature Types autoaction_value_f"].value = 0.00

Local_Feature["Feature Types autoaction_slider"] = menu.add_feature("autoaction_slider", "autoaction_slider", Local_Parents["Feature Types"], function(f)
    local fix_float
    f.value, fix_float = lib.essentials.fix_float(f.value)
    lua_notify("autoaction_slider = " .. fix_float, "Feature Types")
end)
Local_Feature["Feature Types autoaction_slider"].max = 1.00
Local_Feature["Feature Types autoaction_slider"].min = 0.00
Local_Feature["Feature Types autoaction_slider"].mod = 0.10
Local_Feature["Feature Types autoaction_slider"].value = 0.00

Local_Feature["Feature Types autoaction_value_str"] = menu.add_feature("autoaction_value_str", "autoaction_value_str", Local_Parents["Feature Types"], function(f)
    lua_notify("autoaction_value_str = " .. f.str_data[f.value + 1], "Feature Types")
end)
Local_Feature["Feature Types autoaction_value_str"]:set_str_data({"v1", "v2", "v3"})

Local_Parents["Profiles"] = menu.add_feature("Profiles", "parent", Local_Parents["Settings"]).id

Local_Feature["Save Profiles"] = menu.add_feature("Save", "action", Local_Parents["Profiles"], function(f)
    local file <const> = io.open(Settings_File, "w")
    io.output(file)
    io.write("")
    io.close(file)
    for k, _ in pairs(Local_Feature) do
        local feature <const> = Local_Feature[k]
        local toggle = "nil"
        local value = "nil"
        if lib.essentials.table_contains(Toggle_Feats, feature.type, "right") then
            if feature.on then
                toggle = "true"
            else
                toggle = "false"
            end
        end
        if lib.essentials.table_contains(Value_Feats, feature.type, "right") then
            value = feature.value
        end
        if toggle ~= "nil" or value ~= "nil" then
            local file <const> = io.open(Settings_File, "a")
            io.output(file)
            io.write(k .. "|" .. toggle .. "|" .. value .. "\n")
            io.close(file)
        end
    end
    lua_notify("Successfully save settings.", f.name)
end)

Local_Feature["Load Profiles"] = menu.add_feature("Load", "action", Local_Parents["Profiles"], function(f)
    if utils.file_exists(Settings_File) and io.open(Settings_File, "r"):read("*a") ~= "" then
        local file <const> = io.open(Settings_File, "r")
        if file then
            for line in file:lines() do
                local name, toggle, value <const> = line:match("([^|]+)|([^|]+)|([^|]+)")
                local feature <const> = Local_Feature[name]
                if feature ~= nil then
                    if toggle ~= "nil" then
                        if toggle == "true" then
                            feature.on = true
                        else
                            feature.on = false
                        end
                    end
                    if value ~= "nil" then
                        feature.value = value
                    end
                end
            end
            file:close()
        end
        lua_notify("Successfully load settings.", f.name)
    else
        lua_notify_alert("Save your settings before.", f.name)
    end
end)

Local_Feature["Reset Profiles"] = menu.add_feature("Reset", "action", Local_Parents["Profiles"], function(f)
    local file <const> = io.open(Settings_File, "w")
    io.output(file)
    io.write("")
    io.close(file)
    for k, _ in pairs(Local_Feature) do
        Local_Feature[k].on = false
    end
    lua_notify("Successfully reset settings.", f.name)
end)

if Update_Available then
    Local_Feature["Update Lua"] = menu.add_feature(Jaune .. "Update Lua", "action", Local_Parents["Local Prents"], function(f)
        update_lua(anarchy_body, lib_body)
        lua_notify("The update is complete, you can now restart the lua.", f.name)
        menu.exit()
    end)
end

Local_Feature["Discord Server"] = menu.add_feature(Jaune .. "Discord Server", "action", Local_Parents["Local Prents"], function(f)
    utils.to_clipboard("https://discord.gg/GfmmeQNc93")
    lua_notify("The Discord link has been copied to your clipboard.\nDiscord: " .. Jaune .. "https://discord.gg/GfmmeQNc93", f.name)
end)

if utils.file_exists(Settings_File) and io.open(Settings_File, "r"):read("*a") ~= "" then
    local file <const> = io.open(Settings_File, "r")
    if file then
        for line in file:lines() do
            local name, toggle, value <const> = line:match("([^|]+)|([^|]+)|([^|]+)")
            local feature <const> = Local_Feature[name]
            if feature ~= nil then
                if toggle ~= "nil" then
                    if toggle == "true" then
                        feature.on = true
                    else
                        feature.on = false
                    end
                end
                if value ~= "nil" then
                    feature.value = value
                end
            end
        end
        file:close()
    end
end

event.add_event_listener("exit", function()
    for i, Entity in ipairs(anarchy_spawned_entity) do
		if entity.is_an_entity(Entity) then
			ui.remove_blip(ui.get_blip_from_entity(Entity))
			if network.get_entity_net_owner(Entity) == player.player_id() then
				if entity.is_entity_attached(Entity) then
					entity.detach_entity(Entity)
				end
				if not entity.is_entity_attached(Entity) and (not entity.is_entity_a_ped(Entity) or not ped.is_ped_a_player(Entity)) then
					entity.set_entity_as_mission_entity(Entity, false, true)
					entity.delete_entity(Entity)
				end
			end
		end
	end
    if ped.is_ped_in_any_vehicle(player.player_ped()) then
        local veh <const> = ped.get_vehicle_ped_is_using(player.player_ped())
        local seat <const> = lib.entity.get_seat_ped_is_in(player.player_ped())
        ped.clear_ped_tasks_immediately(player.player_ped())
        ped.set_ped_into_vehicle(player.player_ped(), veh, seat)
    else
        ped.clear_ped_tasks_immediately(player.player_ped())
    end
    lib.natives.TERRAINGRID_ACTIVATE(false)
    for _, folderName in ipairs(folderOrder) do
        local featureList <const> = lib.table.timecycle[folderName]
        for _, updatedFeatureName in ipairs(featureList) do
            local originalFeatureName <const> = originalFeatureNames[updatedFeatureName]
            for _, weather in pairs(lib.table.weather) do
                for frame = 0, 12 do
                    for region = 1, 2 do
                        local hash <const> = gameplay.get_hash_key(weather)
                        timecycle.set_timecycle_keyframe_var(hash, region, frame, originalFeatureName, keyframe_saves[hash][frame][originalFeatureName])
                    end
                end
            end
        end
    end
    if Local_Feature["Ending Pin Bad Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Pin_Bad", player.player_ped(), "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", false)
    end
    if Local_Feature["Ending Parcel Vehicle Lost Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Parcel_Vehicle_Lost", player.player_ped(), "GTAO_FM_Events_Soundset", false)
    end
    if Local_Feature["Ending Bomb Disarmed Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Bomb_Disarmed", player.player_ped(), "GTAO_Speed_Convoy_Soundset", false)
    end
    if Local_Feature["Ending 1st Person Transition Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "1st_Person_Transition", player.player_ped(), "PLAYER_SWITCH_CUSTOM_SOUNDSET", false)
    end
    if Local_Feature["Ending Base Jump Passed Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "BASE_JUMP_PASSED", player.player_ped(), "HUD_AWARDS", false)
    end
    if Local_Feature["Ending Start Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Start", player.player_ped(), "DLC_HEIST_HACKING_SNAKE_SOUNDS", false)
    end
    if Local_Feature["Ending Pin Good Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Pin_Good", player.player_ped(), "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", false)
    end
    if Local_Feature["Ending Turn Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Turn", player.player_ped(), "DLC_HEIST_HACKING_SNAKE_SOUNDS", false)
    end
    if Local_Feature["Ending Power Down Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Power_Down", player.player_ped(), "DLC_HEIST_HACKING_SNAKE_SOUNDS", false)
    end
    if Local_Feature["Ending Hack Success Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Hack_Success", player.player_ped(), "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", false)
    end
    if Local_Feature["Ending Tennis Point Won Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "TENNIS_POINT_WON", player.player_ped(), "HUD_AWARDS", false)
    end
    if Local_Feature["Ending Air Defenses Disabled Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Air_Defenses_Disabled", player.player_ped(), "DLC_sum20_Business_Battle_AC_Sounds", false)
    end
    if Local_Feature["Ending Out Of Area Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Out_Of_Area", player.player_ped(), "DLC_Lowrider_Relay_Race_Sounds", false)
    end
    if Local_Feature["Ending Other Text Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "OTHER_TEXT", player.player_ped(), "HUD_AWARDS", false)
    end
    if Local_Feature["Ending OOB Start Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "OOB_Start", player.player_ped(), "GTAO_FM_Events_Soundset", false)
    end
    if Local_Feature["Ending 3 2 1 Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "3_2_1", player.player_ped(), "HUD_MINI_GAME_SOUNDSET", false)
    end
    if Local_Feature["Ending Timer Stop Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "TIMER_STOP", player.player_ped(), "HUD_MINI_GAME_SOUNDSET", false)
    end
    if Local_Feature["Ending Success Sound"].on then
        lib.natives.PLAY_SOUND_FROM_ENTITY(-1, "Success", player.player_ped(), "DLC_HEIST_HACKING_SNAKE_SOUNDS", false)
    end
    lua_notify("Anarchy has been deleted.", notify_default)
end)

lua_notify("Version: " .. Jaune .. lua_version .. BleuClair .. "\nUpdated on: " .. Jaune .. lua_update_date .. BleuClair .. "\nDev: " .. Jaune .. "[3arc] Smiley" .. BleuClair .. "\n\nAnarchy is correctly loaded.", notify_default)

end)
