local RunService = game:GetService("RunService")

local Roact = require(script.Parent.Parent.Roact)

local merge = require(script.Parent.merge)
local SpringHelper = require(script.Parent.SpringHelper)
local stepSpring = require(script.Parent.stepSpring)
local Config = require(script.Parent.Config)

local StaggeredMotion = Roact.PureComponent:extend("StaggeredMotion")

function StaggeredMotion:init(props)
    -- If the Motion is asleep it does not update
    self.asleep = false
    -- Used for rate-limiting spring steps
    self.accumulator = 0
    -- Set up the values table with the initial values (if given) or 0
    local values = {}
    -- Velocities are initialized to 0
    local velocities = {}

    local styles = props.styles()

    for index, style in ipairs(styles) do
        velocities[index] = {}
        values[index] = {}

        for key, _ in pairs(style) do
            velocities[index][key] = 0
            values[index][key] = 0
        end
    end

    -- If initial values are specified, use them
    if props.initialValues then
        for index, initials in pairs(props.initialValues) do
            for key, initialValue in pairs(initials) do
                values[index][key] = initialValue
            end
        end
    end

    self.state = {
        values = values,
        velocities = velocities,
        targets = styles,
    }
end

function StaggeredMotion:render()
    return self.props.render(self.state.values)
end

function StaggeredMotion:didMount()
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

            for index, targets in ipairs(self.state.targets) do
                for key, target in pairs(targets) do
                    local currentValue = newValues[index][key]
                    local currentVelocity = newVelocities[index][key]

                    local newValue, newVelocity

                    if typeof(target) == "number" then
                        newValue = target
                        newVelocity = 0
                    else
                        newValue, newVelocity = stepSpring(
                            currentValue,
                            currentVelocity,
                            target.value,
                            target.stiffness,
                            target.damping,
                            Config.stepInterval
                        )
                    end

                    if newValue ~= SpringHelper.getValue(target) or newVelocity ~= 0 then
                        reachedGoals = false
                    end

                    newValues[index][key] = newValue
                    newVelocities[index][key] = newVelocity
                end
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
            targets = self.props.styles(newValues),
        })
    end)
end

function StaggeredMotion:willUnmount()
    self._renderConnection:Disconnect()
end

function StaggeredMotion:didUpdate(lastProps, lastState)
    -- This work is performed in didUpdate because you cannot set state in willUpdate.
    -- This means that animations will be a frame behind, but that's okay.

    -- If the styles are different, an animation needs to be performed.
    if lastProps.styles ~= self.props.styles then
        -- Wake up the Motion so that it can animate.
        self.asleep = false
    end
end

return StaggeredMotion
