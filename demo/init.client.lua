local Roact = require(game.ReplicatedStorage.Roact)
local e = Roact.createElement
local RoactMotion = require(game.ReplicatedStorage.RoactMotion)

local DemoComponent = Roact.PureComponent:extend("DemoComponent")

function DemoComponent:init()
    self.state = {
        goalRotation = 0,
    }
end

function DemoComponent:render()
    print(self.state.goalRotation)
    return e(RoactMotion.Motion, {
        style = {
            Rotation = RoactMotion.spring(self.state.goalRotation, 170, 10),
        },
        render = function(style)
            return e("Frame", {
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Rotation = style.Rotation,
                Size = UDim2.new(0, 100, 0, 100),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
            })
        end,
    })
end

function DemoComponent:didMount()
    spawn(function()
        while true do
            wait(3)
            print("Spinning")
            self:setState({
                goalRotation = math.random(-360, 360),
            })
        end
    end)
end

local tree = e("ScreenGui", {}, {
    e(DemoComponent)
})

Roact.reify(tree, game.Players.LocalPlayer:WaitForChild("PlayerGui"))
