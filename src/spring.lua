--[[
    Spring creator function.
    Usage: spring(goal, stiffness, damping)
]]

return function(value, stiffness, damping)
    return {
        Value = value,
        Stiffness = stiffness,
        Damping = damping,
    }
end