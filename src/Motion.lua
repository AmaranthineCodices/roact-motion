local RunService = game:GetService("RunService")

local Roact = require(script.Parent.Parent.Roact)

local merge = require(script.Parent.merge)
local SpringHelper = require(script.Parent.SpringHelper)
local stepSpring = require(script.Parent.stepSpring)
local Config = require(script.Parent.Config)

local Motion = Roact.PureComponent:extend("Motion")

function Motion:init(props)
    -- If the Motion is asleep it does not update
    -- Start the motion in this state; we'll change it later if necessary.
    self.asleep = true
    -- Used for rate-limiting spring steps
    self.accumulator = 0
    -- Set up the values table with the initial values (if given) or 0
    local values = {}
    -- Velocities are initialized to 0
    local velocities = {}

    for key, _ in pairs(props.style) do
        velocities[key] = 0
        values[key] = 0
    end

    -- If initial values are specified, use them
    if props.initialValues then
        for key, value in pairs(props.initialValues) do
            values[key] = value
        end
    end

    -- Wake up the Motion if necessary
    for key, value in pairs(values) do
        -- If the current value differs from the goal value the Motion is not
        -- at rest initially, and should not start off asleep.
        if value ~= SpringHelper.getValue(props.style[key]) then
            self.asleep = false
            break
        end
    end

    self.state = {
        values = values,
        velocities = velocities,
    }
end

function Motion:render()
    return self.props.render(self.state.values)
end

function Motion:didMount()
    self._renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
        -- If the component is asleep, do nothing.
        if self.asleep then return end

        if deltaTime > Config.maximumFrameTime then
            warn(("Frame delta time is %f seconds (expected less than %f seconds) - the framerate has dropped."):format(
                deltaTime,
                Config.maximumFrameTime
            ))

            deltaTime = Config.maximumFrameTime
        end

        self.accumulator = self.accumulator + deltaTime

        local newValues = merge(self.state.values)
        local newVelocities = merge(self.state.velocities)

        while self.accumulator > Config.stepInterval do
            local reachedGoals = true

            for key, target in pairs(self.props.style) do
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
                        Config.stepInterval
                    )
                end

                if newValue ~= SpringHelper.getValue(target) or newVelocity ~= 0 then
                    reachedGoals = false
                end

                newValues[key] = newValue
                newVelocities[key] = newVelocity
            end

            self.accumulator = self.accumulator - Config.stepInterval

            if reachedGoals then
                self.asleep = true
                break
            end
        end

        self:setState({
            velocities = newVelocities,
            values = newValues,
        })

        if self.asleep and self.props.onResting then
            self.props.onResting(newValues)
        end
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
        -- Make sure there's actually work to do here!
        for key, target in pairs(self.props.style) do
            local currentValue = self.state.values[key]

            if currentValue ~= SpringHelper.getValue(target) then
                self.asleep = false
                break
            end
        end
    end
end

return Motion
