--  █████  ██   ██      ██████  █████  ███    ███ ███████ ██████   █████
-- ██   ██  ██ ██      ██      ██   ██ ████  ████ ██      ██   ██ ██   ██
-- ███████   ███       ██      ███████ ██ ████ ██ █████   ██████  ███████
-- ██   ██  ██ ██      ██      ██   ██ ██  ██  ██ ██      ██   ██ ██   ██
-- ██   ██ ██   ██      ██████ ██   ██ ██      ██ ███████ ██   ██ ██   ██
-- 
-- MIT License, See License.txt
--
-- Provides a two chat commands, that can contain any number of
-- camera commands that are run in order of listing. Any new command
-- command will overwrite the currently running one.
--
-- /camera {command,time,val,val,val} {command,time,val,val,val}
-- /camera_loop {command,time,val,val,val} {command,time,val,val,val}
--
-- Where: 
--   command: Command name
--      time: Time for command to last, in seconds
--       val: Any number valu
--
-- Available Commands:
--
-- {pos,time,x,y,z} - Set player position
-- {look,time,x,y,z} - Set look spot
-- {fov,time,fov} - Set FOV instantaneously
-- {line,time,x,y,z,speed}
-- {line_look,time,x,y,z,x2,y2,z2,speed}
-- {circle,time,x,y,z,speed}
-- {circle_look,time,x,y,z,x2,y2,z2,speed}

ax_camera = {}
local function getEyeOffset(player)
    local camera_mode = player:get_camera().mode
    if camera_mode == "any" then
        camera_mode = "first"
    end
    local eye_pos = vector.zero()
    eye_pos.y = eye_pos.y + player:get_properties().eye_height
    local first, third, third_front = player:get_eye_offset()
    local lookup = {
        first = first,
        third = third,
        third_front = third_front
    }
    eye_pos = vector.add(eye_pos, vector.divide(lookup[camera_mode], 10)) -- eye offsets are in block space (10x), transform them back to metric
    return eye_pos
end
ax_camera.commandNumArgs = {
    pos = 4,
    look = 4,
    fov = 2,
}
ax_camera.commands = {
    pos = function(player,dtime,x,y,z)
        player:set_pos(vector.new(x,y,z))
    end,
    look = function(player,dtime,x,y,z)
        local look_dir = vector.direction(vector.add(player:get_pos(), getEyeOffset(player)), vector.new(x,y,z))
        local pitch = -math.asin(look_dir.y)
        local yaw = math.atan2(-look_dir.x, look_dir.z)
        player:set_look_horizontal(yaw)
        player:set_look_vertical(pitch)
    end,
    fov = function(player,dtime,fov)
        player:set_fov(fov)
    end
}
ax_camera.players = {}

function parseParams(params)
    local commands = {}
    local command_pattern = "^%s*%w+%s*$"
    local value_pattern = "^%s*[+-]?%d*%.?%d+%s*$"

    for command_group in params:gmatch("{([^}]+)}") do
        local parts = {}
        for part in command_group:gmatch("([^,]+)") do
            table.insert(parts, part)
        end

        -- A valid group must have at least a command and a time
        if #parts >= 2 then
            local command_name = parts[1]:match(command_pattern)
            if command_name and ax_camera.commands[command_name] then
                local command_info = {
                    command = command_name,
                    args = {}
                }
                local all_values_valid = true
                for i = 2, #parts do
                    local numeric_val_str = parts[i]:match(value_pattern)
                    if numeric_val_str then
                        table.insert(command_info.args, tonumber(numeric_val_str))
                    else
                        all_values_valid = false
                        break
                    end
                end

                if all_values_valid then
                    local numArgs = ax_camera.commandNumArgs[command_info.command]
                    if #command_info.args == numArgs then
                        table.insert(commands, command_info)
                    else
                        return nil, "Invalid number of args for command "..command_info.command
                                     ..", expected "..numArgs.." , command group: " .. command_group
                    end
                else
                    return nil, "Invalid numeric value in group: " .. command_group
                end
            else
                return nil, "Invalid command name in group: " .. command_group
            end
        else
            return nil, "Group has insufficient arguments: " .. command_group
        end
    end

    return commands
end

ax_camera.camera = function(player, params)
    if player ~= nil and type(params) == "string" then
        local commands, error = parseParams(params)
        local player_name = player:get_player_name()
        if error ~= nil then
            core.chat_send_player(player_name, error)
            return
        end
        if commands ~= nil and #commands > 0 then
            ax_camera.players[player_name] = {
                commands = commands,
                mode = "one_shot",
                index = 1,
                timeRemaining = commands[1][1],
            }
        end
        -- for i=1,#commands,1 do
        --     local command = commands[i]
        --     local commandName = command.command
        --     local numArgs = ax_camera.commandNumArgs[commandName]
        --     local dtime = 0
        --     ax_camera.commands[commandName](player, dtime, unpack(command.args,2,numArgs))
        -- end
    end
end

core.register_chatcommand("camera", 
{
    params = "{pos|look|fov,seconds,val,val,val}{}{}{}",
    description = "Camera Control API, groups of {} are executed in order until completion",
    privs = {},
    func = function(name, params)
        ax_camera.camera(core.get_player_by_name(name), params)
    end
})

core.register_globalstep(function(dtime)
    for player in ax_camera.players do
        if player.timeRemaining - dtime <= 0 then
            if #player.commands > index then
                index = index + 1
                -- execute all zero time commands
                while player.commands[index][1] <= 0 do
                    ax_camera.commands[commandName](player, dtime, unpack(command.args,2,numArgs))
                end
            end
        end
    end
end)

