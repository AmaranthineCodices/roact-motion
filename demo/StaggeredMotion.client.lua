local SQUARES = 4

local Roact = require(game.ReplicatedStorage.Roact)
local e = Roact.createElement
local RoactMotion = require(game.ReplicatedStorage.RoactMotion)

local DemoComponent = Roact.Component:extend("DemoComponent")

function DemoComponent:init()
    self.state = {
        mouseX = 0,
        mouseY = 0,
    }
end

function DemoComponent:render()
    return e(RoactMotion.StaggeredMotion, {
        styles = function(previous)
            local newStyles = {}

            if not previous then
                for i = 1, SQUARES do
                    newStyles[i] = {
                        x = 0,
                        y = 0,
                    }
                end
            else
                newStyles[1] = {
                    x = RoactMotion.spring(self.state.mouseX, 120, 12),
                    y = RoactMotion.spring(self.state.mouseY, 120, 12),
                }

                for i = 2, SQUARES do
                    newStyles[i] = {
                        x = previous[i - 1].x,
                        y = previous[i - 1].y,
                    }
                end
            end

            return newStyles
        end,
        render = function(style)
            local squares = {}

            for i = 1, SQUARES do
                squares[i] = e("Frame", {
                    Size = UDim2.new(0, 50 - i * 10, 0, 50 - i * 10),
                    Position = UDim2.new(0, style[i].x, 0, style[i].y),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.new(i / SQUARES, i / SQUARES, i / SQUARES),
                    BorderSizePixel = 0,
                    ZIndex = i,
                })
            end

            return e("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
            }, squares)
        end,
    })
end

function DemoComponent:didMount()
    local mouse = game.Players.LocalPlayer:GetMouse()

    mouse.Move:Connect(function()
        self:setState({
            mouseX = mouse.X,
            mouseY = mouse.Y,
        })
    end)
end

local tree = e("ScreenGui", {}, {
    e(DemoComponent)
})

Roact.reify(tree, game.Players.LocalPlayer:WaitForChild("PlayerGui"))
