--[[
    Euler method spring solver.
]]

local PRECISION = 1e-2

return function(position, velocity, goal, stiffness, damping, dt)
    local distance = position - goal
    -- F = -kx
    local springForce = -stiffness * distance
    local dampForce = -damping * velocity

    -- Objects are assumed to have a mass of 1, so force = acceleration
    local acceleration = springForce + dampForce
    local newVelocity = velocity + acceleration * dt
    local newPosition = position + newVelocity * dt

    if math.abs(newPosition - goal) < PRECISION and math.abs(newVelocity - velocity) < PRECISION then
        return goal, 0
    else
        return newPosition, newVelocity
    end
end
