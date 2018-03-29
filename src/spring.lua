--[[
    Spring creator function.
    Usage: spring(goal, stiffness, damping)
]]

local Config = require(script.Parent.Config)

return function(value, stiffness, damping)
    return {
        value = value,
        stiffness = stiffness or Config.defaultStiffness,
        damping = damping or Config.defaultDamping,
    }
end