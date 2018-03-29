local RunService = game:GetService("RunService")

local STEP_RATE = 1 / 120

local Roact = require(script.Parent.Parent.Roact)

local merge = require(script.Parent.merge)
local SpringHelper = require(script.Parent.SpringHelper)
local stepSpring = require(script.Parent.stepSpring)

local Motion = Roact.PureComponent:extend("Motion")

function Motion:init(props)
    -- If the Motion is asleep it does not update
    self.asleep = false
    -- Used for rate-limiting spring steps
    self.accumulator = 0
    -- Set up the values table with the initial values (if given) or 0
    local values = {}
    -- Velocities are initialized to 0
    local velocities = {}

    for key, spring in pairs(props.style) do
        velocities[key] = 0
        values[key] = 0
    end

    -- If initial values are specified, use them
    if props.initialValues then
        for key, value in pairs(props.initialValues) do
            values[key] = value
        end
    end

    self.state = {
        values = values,
        velocities = velocities,
        targets = props.style,
    }
end

function Motion:render()
    return self.props.render(self.state.values)
end

function Motion:didMount()
    self._renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
        -- If the component is asleep, do nothing.
        if self.asleep then return end

        self.accumulator = self.accumulator + deltaTime

        local newValues = merge(self.state.values)
        local newVelocities = merge(self.state.velocities)

        while self.accumulator > STEP_RATE do
            local reachedGoals = true

            for key, target in pairs(self.state.targets) do
                local newValue, newVelocity

                if typeof(target) == "number" then
                    newValue = target
                    newVelocity = 0
                else
                    newValue, newVelocity = stepSpring(
                        newValues[key],
                        newVelocities[key],
                        target.value,
                        target.stiffness,
                        target.damping,
                        STEP_RATE
                    )
                end

                if newValue ~= SpringHelper.getValue(target) or newVelocity ~= 0 then
                    reachedGoals = false
                end

                newValues[key] = newValue
                newVelocities[key] = newVelocity

                self.accumulator = self.accumulator - STEP_RATE
            end

            if reachedGoals then
                self.asleep = true
                break
            end
        end

        self:setState({
            velocities = newVelocities,
            values = newValues,
        })
    end)
end

function Motion:willUnmount()
    self._renderConnection:Disconnect()
end

function Motion:didUpdate(lastProps, lastState)
    -- This work is performed in didUpdate because you cannot set state in willUpdate.
    -- This means that animations will be a frame behind, but that's okay.

    -- If the styles are different, an animation needs to be performed.
    if lastProps.style ~= self.props.style then
        -- Kick off a re-render.
        self:setState({
            targets = self.props.style,
        })

        -- Wake up the Motion so that it can animate.
        self.asleep = false
    end
end

return Motion
