--[[
    Spring creator function.
    Usage: spring(goal, stiffness, damping)
]]

local DEFAULT_STIFFNESS = 170
local DEFAULT_DAMPING = 26

return function(value, stiffness, damping)
    return {
        value = value,
        stiffness = stiffness or DEFAULT_STIFFNESS,
        damping = damping or DEFAULT_DAMPING,
    }
end