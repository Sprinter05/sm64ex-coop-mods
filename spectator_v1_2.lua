-- name: Spectator
-- description: SPECTATOR FOR HOST:\n\nChange users with DPAD LEFT\nand DPAD RIGHT\n\nMade by Sprinter#0669\n\nv. 1.1

E_MODEL_MARIO = smlua_model_util_get_id("mario_geo")
ACT_MY_DEBUG_FREE_MOVE = allocate_mario_action(ACT_GROUP_CUTSCENE)

local i = network_local_index_from_global(1)
local number = 0
local host = network_local_index_from_global(0)
local Rmax = MAX_PLAYERS

local MM = gMarioStates[0]
local MMH = gMarioStates[host]

local free_camera = 1
local hide_hud = 0

function mario_dfm(m)
    local speed = 0
    local posX = 0
    local posY = 0
    local posZ = 0
    local floorHeight = 0
    action = ACT_IDLE

    set_mario_action(MMH, action, 0)
    set_mario_animation(MMH, MARIO_ANIM_A_POSE)

    if (MMH.controller.buttonDown & B_BUTTON) ~= 0 then
        speed = 1
    else
        speed = 3
    end

    posX = MMH.pos.x
    posY = MMH.pos.y
    posZ = MMH.pos.z

    if (MMH.controller.buttonDown & A_BUTTON) ~= 0 then
        posY = posY + 16.0 * speed
    end

    if (MMH.controller.buttonDown & Z_TRIG) ~= 0 then
        posY = posY - 16.0 * speed
    end

    if (MMH.intendedMag > 0) then
        posX = posX + 32.0 * speed * sins(MMH.intendedYaw)
        posZ = posZ + 32.0 * speed * coss(MMH.intendedYaw)
    end

    resolve_and_return_wall_collisions(MMH.pos, 60.0, 50.0)
    floorHeight = find_floor_height(MMH.pos.x, MMH.pos.y, MMH.pos.z)

    if floorHeight > -11000 then
        if MMH.pos.y < floorHeight then
            posY = floorHeight
        end
        MMH.pos.x = posX
        MMH.pos.y = posY
        MMH.pos.z = posZ 
    end

    MMH.faceAngle.y = MMH.intendedYaw
    vec3f_copy(MMH.marioObj.header.gfx.pos, MMH.pos)
    vec3s_set(MMH.marioObj.header.gfx.angle, 0, MMH.faceAngle.y, 0)

    if (MMH.controller.buttonDown & B_BUTTON) ~= 0 then
        set_mario_action(m, action, 0)
    end

    if (MMH.controller.buttonDown & L_TRIG) and MMH.marioObj.oTimer > 10 then
        if MMH.pos.y <= MMH.waterLevel - 100 then
            action = ACT_WATER_IDLE
        end
        set_mario_action(MMH, action, 0)
    end

end

hook_mario_action(ACT_MY_DEBUG_FREE_MOVE, mario_dfm)

function mario_update_local(m)

    local max = network_player_connected_count()

    local nph = gNetworkPlayers[host]
    local npi = gNetworkPlayers[i]

    if (MMH.action == ACT_START_SLEEPING) then
        set_mario_action(MMH, ACT_WAKING_UP, 0)
    end

    if (MMH.action == ACT_QUICKSAND_DEATH) then
        set_mario_action(MMH, ACT_IDLE, 0)
    end

    obj_set_model_extended(MMH.marioObj, E_MODEL_NONE)
    gMarioStates[host].marioObj.oIntangibleTimer = -1
    MMH.health = 0x880

    set_mario_action(MMH, ACT_IDLE, 0)

    if free_camera == 0 then
        gMarioStates[host].freeze = -1
    else
        gMarioStates[host].freeze = 0
    end

    network_player_set_description(nph, "Spectator", 169, 169, 169, 255)

    local s = gMarioStates[host]
    local p = gMarioStates[i]

    if (MMH.controller.buttonPressed & D_JPAD) ~= 0 then
        if free_camera == 1 then
            free_camera = 0
        else
            free_camera = 1
        end
    end

    if (MMH.controller.buttonPressed & U_JPAD) ~= 0 then
        if hide_hud == 0 then
            hide_hud = 1
        else
            hide_hud = 0
        end
    end

    if free_camera == 0 then

    if (MMH.controller.buttonPressed & L_JPAD) ~= 0 then
        if i > 1 and i <= (Rmax - 1) then
            i = i - 1
        end
    end

    if (MMH.controller.buttonPressed & R_JPAD) ~= 0 then
        if i < (Rmax - 1) and i >= 1 then
            i = i + 1
        end
    end

    s.pos.x = p.pos.x
    s.pos.y = p.pos.y
    s.pos.z = p.pos.z

    if npi.currLevelNum ~= nph.currLevelNum or npi.currAreaIndex ~= nph.currAreaIndex or npi.currActNum ~= nph.currActNum then
        number = number + 1
        if number == 35 then
            number = 0
            if MM.playerIndex == host then
                warp_to_level(npi.currLevelNum, npi.currAreaIndex, npi.currActNum)
            end
        end
    end

    else

        set_mario_action(MMH, ACT_MY_DEBUG_FREE_MOVE, 0)

    end

end

function mario_update(m)
    if m.playerIndex == host then
        mario_update_local(m)
    end
end

function spectated()
    if hide_hud == 0 then
        local n = network_local_index_from_global(i)

        djui_hud_set_font(FONT_MENU)
        djui_hud_set_resolution(RESOLUTION_DJUI)
        djui_hud_set_color(255, 255, 255, 255)

        local text

        if free_camera == 1 then
            text = "FREE CAMERA"
        else
            if gNetworkPlayers[n].name == '' then
                text = "EMPTY (" .. i .. " )"
            else
                text = gNetworkPlayers[n].name    
            end
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
end

function spectated_update()
    if MM.playerIndex == host then
        spectated()
    end
end

hook_event(HOOK_ON_HUD_RENDER, spectated_update)
hook_event(HOOK_MARIO_UPDATE, mario_update)
