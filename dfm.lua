-- name: Debug Free Move
-- description: who needs cheats now\nTranslated by Sprinter#0669 with help from Contributors and Devs

ACT_MY_DEBUG_FREE_MOVE = allocate_mario_action(ACT_GROUP_CUTSCENE)

function mario_update(m)
    local speed = 0
    local posX = 0
    local posY = 0
    local posZ = 0
    local floorHeight = 0
    action = ACT_IDLE

    set_mario_action(m, action, 0)
    set_mario_animation(m, MARIO_ANIM_A_POSE)

    if (m.controller.buttonDown & B_BUTTON) ~= 0 then
        speed = 1
    else
        speed = 3
    end

    posX = m.pos.x
    posY = m.pos.y
    posZ = m.pos.z

    if (m.controller.buttonDown & A_BUTTON) ~= 0 then
        posY = posY + 16.0 * speed
    end

    if (m.controller.buttonDown & Z_TRIG) ~= 0 then
        posY = posY - 16.0 * speed
    end

    if (m.intendedMag > 0) then
        posX = posX + 32.0 * speed * sins(m.intendedYaw)
        posZ = posZ + 32.0 * speed * coss(m.intendedYaw)
    end

    resolve_and_return_wall_collisions(m.pos, 60.0, 50.0)
    floorHeight = find_floor_height(m.pos.x, m.pos.y, m.pos.z)

    if floorHeight > -11000 then
        if m.pos.y < floorHeight then
            posY = floorHeight
        end
        m.pos.x = posX
        m.pos.y = posY
        m.pos.z = posZ 
    end

    m.faceAngle.y = m.intendedYaw
    vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
    vec3s_set(m.marioObj.header.gfx.angle, 0, m.faceAngle.y, 0)

    if (m.controller.buttonDown & B_BUTTON) ~= 0 then
        set_mario_action(m, action, 0)
    end

    if (m.controller.buttonDown & L_TRIG) and m.marioObj.oTimer > 10 then
        if m.pos.y <= m.waterLevel - 100 then
            action = ACT_WATER_IDLE
        end
        set_mario_action(m, action, 0)
    end

end

hook_mario_action(ACT_MY_DEBUG_FREE_MOVE, mario_update)

function on_mario_update(m)
    set_mario_action(m, ACT_MY_DEBUG_FREE_MOVE, 0)
end

hook_event(HOOK_MARIO_UPDATE, on_mario_update)