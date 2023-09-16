local Scene = require("scenes/scene")
local AnimatedSheet = require("ui/animatedsheet")

WaitingForGameScene = {}
setmetatable(WaitingForGameScene, { __index = Scene })

function WaitingForGameScene.load()
    local speed, scale = 25, 0.50
    local waitingAnimation = AnimatedSheet:new("assets/walking-finger-spritesheet.png", 28, speed, scale)
    waitingAnimation.x = (love.graphics.getWidth() - waitingAnimation:getWidth()) / 2
    waitingAnimation.y = (love.graphics.getHeight() - waitingAnimation:getHeight()) / 2
    waitingAnimation.y = waitingAnimation.y - (love.graphics.getHeight() / 2) * 0.33

    WaitingForGameScene.waitingAnimation = waitingAnimation
    WaitingForGameScene.text = "Waiting for match"
    WaitingForGameScene.textFont = love.graphics.newFont("assets/Thin Design.ttf", 48)
    love.graphics.setFont(WaitingForGameScene.textFont)
end

function WaitingForGameScene.update(dt)
    WaitingForGameScene.waitingAnimation:update(dt)
end

function WaitingForGameScene.draw()
    local text, font = WaitingForGameScene.text, WaitingForGameScene.textFont
    local offset = 30
    WaitingForGameScene.waitingAnimation:draw()
    love.graphics.print(text,
        (love.graphics.getWidth() - font:getWidth(text)) / 2,
        (love.graphics.getHeight() - font:getHeight()) / 2 + offset)
end

return WaitingForGameScene