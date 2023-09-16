local AnimatedSheet = {}

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

return AnimatedSheet
