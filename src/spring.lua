--[[
    Spring creator function.
    Usage: spring(goal, stiffness, damping)
]]

local Config = require(script.Parent.Config)

return function(value, stiffness, damping)
    if damping <= 0 then
        warn(("damping is %f - this spring will oscillate indefinitely! Traceback:\n%s"):format(
            damping,
            debug.traceback()
        ))
    end

    return {
        value = value,
        stiffness = stiffness or Config.defaultStiffness,
        damping = damping or Config.defaultDamping,
    }
end