local M = {}

local _servo_left, _servo_right

local _directions = {
    ["pivot.left"]={left=15, right=-70},
    ["pivot.right"]={left=70, right=-15},
    ["rotate.right"]={left=25, right=25},
    ["rotate.left"]={left=-25, right=-25},
    ["sit.still"]={left=0, right=0},
    ["backward"]={left=-25, right=25},
    ["backward.left"]={left=-20, right=45},
    ["backward.right"]={left=-45, right=20},
    ["forward.slow"]={left=15, right=-15},
    ["forward.fast"]={left=90, right=-90}
}

function M.init(pin_left,pin_right)
    _servo_left = pin_left
    _servo_right = pin_right
    pwm.setup(_servo_left,333,502)
    pwm.setup(_servo_right,333,502)
    _servo_write(_servo_left,90)
    _servo_write(_servo_right,90)
end

function _servo_write(pin,speed)
    if DEBUG ~= 1 then
        pwm.setduty(pin,185+3.515*speed)
    else
        print("[DEBUG] pin="..pin..", speed="..speed)
    end
end


function _move(left,right)
    _servo_write(_servo_left,90+left)
    _servo_write(_servo_right,90+right)
end

function M.move(direction)
    print("Moving:"..direction)
    local d = _directions[direction]
    if d then
        _move(d.left,d.right)
    end
end

function M.random(direction)
    _servo_write(_servo_left,node.random(1,180))
    _servo_write(_servo_right,node.random(1,180))
end

return M
