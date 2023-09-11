local Scene = require("scenes/scene")

WaitingForGameScene = {}
setmetatable(WaitingForGameScene, { __index = Scene })

AnimatedSheet = {}

function AnimatedSheet:new(asset, frames, speed)
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
    return self.width
end

function AnimatedSheet:getHeight()
    return self.height
end

function AnimatedSheet:update(dt)
    self.timer = self.timer + dt * self.speed
end

function AnimatedSheet:draw()
    love.graphics.draw(self.image, self.quads[(math.floor(self.timer) % self.frames) + 1], x, y)
end

function WaitingForGameScene.load()
    local speed = 25
    waitingAnimation = AnimatedSheet:new("assets/walking-finger-spritesheet.png", 28, speed)
end

function WaitingForGameScene.update(dt)
    waitingAnimation:update(dt)
end

function WaitingForGameScene.draw()
    waitingAnimation:draw()
end

return WaitingForGameScene