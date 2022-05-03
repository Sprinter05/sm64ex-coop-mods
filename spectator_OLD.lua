-- name: Spectator_OLD
-- description: SPECTATOR FOR HOST:\n\nChange users with DPAD LEFT\nand DPAD RIGHT\n\nMade by Sprinter#0669\n\nv. 1.1

E_MODEL_MARIO = smlua_model_util_get_id("mario_geo")

local i = network_local_index_from_global(1)
local number = 0
local host = network_local_index_from_global(0)
local Rmax = MAX_PLAYERS

local MM = gMarioStates[0]
local MMH = gMarioStates[host]

function mario_update_local(m)
    local max = network_player_connected_count()

    local nph = gNetworkPlayers[host]
    local npi = gNetworkPlayers[i]

    if (MMH.controller.buttonPressed & L_JPAD) ~= 0 then
        if i > 1 then
            if i <= (Rmax - 1) then
                i = i - 1
            end
        end
    end

    if (MMH.controller.buttonPressed & R_JPAD) ~= 0 then
        if i < (Rmax - 1) then
            if i >= 1 then
                i = i + 1
            end
        end
    end

    if (MMH.action == ACT_START_SLEEPING) then
        set_mario_action(MMH, ACT_WAKING_UP, 0)
    end

    if (MMH.action == ACT_QUICKSAND_DEATH) then
        set_mario_action(MMH, ACT_IDLE, 0)
    end

    obj_set_model_extended(m.marioObj, E_MODEL_NONE)
    gMarioStates[host].marioObj.oIntangibleTimer = -1
    gMarioStates[host].freeze = -1
    MMH.health = 0x880

    network_player_set_description(nph, "Spectator", 169, 169, 169, 255)

    local s = gMarioStates[host]
    local p = gMarioStates[i]

    s.pos.x = p.pos.x
    s.pos.y = p.pos.y
    s.pos.z = p.pos.z

    if npi.currLevelNum ~= nph.currLevelNum then
        number = number + 1
        if number == 45 then
            number = 0
            if MM.playerIndex == host then
                warp_to_level(npi.currLevelNum, npi.currAreaIndex, npi.currActNum)
            end
        end
    end

    if npi.currAreaIndex ~= nph.currAreaIndex then
        number = number + 1
        if number == 45 then
            number = 0
            if MM.playerIndex == host then
                warp_to_level(npi.currLevelNum, npi.currAreaIndex, npi.currActNum)
            end
        end
    end

    if npi.currActNum ~= nph.currActNum then
        number = number + 1
        if number == 45 then
            number = 0
            if MM.playerIndex == host then
                warp_to_level(npi.currLevelNum, npi.currAreaIndex, npi.currActNum)
            end
        end
    end

end

function mario_update(m)
    if m.playerIndex == host then
        mario_update_local(m)
    end
end

function spectated()
    local n = network_local_index_from_global(i)

    djui_hud_set_font(FONT_MENU)
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_color(255, 255, 255, 255)

    local text

    if gNetworkPlayers[n].name == '' then
        text = "EMPTY (" .. i .. " )"
    else
        text = gNetworkPlayers[n].name    
    end

    local xlength = djui_hud_get_screen_width() /2
    local ylength = djui_hud_get_screen_height() /24
    local msglength = djui_hud_measure_text(text) / 2
    local xpos = xlength - msglength
    
    djui_hud_print_text(text, xpos, ylength, 1)

    local text2 = '- SPECTATOR MODE -'

    local xlength2 = djui_hud_get_screen_width() /2
    local ylength2 = djui_hud_get_screen_height()
    local msglength2 = djui_hud_measure_text(text2) / 2 * 0.5
    local xpos2 = xlength2 - msglength2
    local ypos2 = ylength2 - ylength2 /20
    
    djui_hud_print_text(text2, xpos2, ypos2, 0.5)
end

function spectated_update()
    if MM.playerIndex == host then
        spectated()
    end
end

hook_event(HOOK_ON_HUD_RENDER, spectated_update)
hook_event(HOOK_MARIO_UPDATE, mario_update)