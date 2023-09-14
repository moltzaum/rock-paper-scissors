local Scene = require("scenes/scene")

WaitingForGameScene = {}
setmetatable(WaitingForGameScene, { __index = Scene })

AnimatedSheet = {}

function AnimatedSheet:new(asset, frames, speed, scale)
    local image, quads, spriteWidth, spriteHeight

    image = love.graphics.newImage(asset)
    quads = {}
	spriteWidth, spriteHeight = image:getWidth() / frames, image:getHeight()

    for i = 0, frames-1 do
        obj = love.graphics.newQuad(i * spriteWidth, 0, spriteWidth, spriteHeight, image)
		table.insert(quads, obj)
	end

    obj = {
        x = 0,
        y = 0,
        width = spriteWidth,
        height = spriteHeight,
        scale = scale,
        speed = speed,
        frames = frames,
        image = image,
        quads = quads,
        timer = 0
    }

    setmetatable(obj, self)
    self.__index = self
    return obj
end

function AnimatedSheet:getWidth()
    return self.width * self.scale
end

function AnimatedSheet:getHeight()
    return self.height * self.scale
end

function AnimatedSheet:update(dt)
    self.timer = self.timer + dt * self.speed
end

function AnimatedSheet:draw()
    local rotation = 0
    love.graphics.draw(self.image, self.quads[(math.floor(self.timer) % self.frames) + 1], self.x, self.y, rotation, self.scale)
end

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