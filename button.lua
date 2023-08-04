local Button = {}

-- This is a simple button class coded in the shape of a circle
function Button:new(buttonImg, buttonPressedImg, sounds)  
    local self = {
        x = 0,
        y = 0,
        buttonImg = buttonImg,
        buttonPressedImg = buttonPressedImg,
        display = buttonImg,
        sounds = sounds
    }
    local padding = {
        right = self.display:getWidth() * 0.20,
        left = self.display:getWidth() * 0.20,
        top = self.display:getWidth() * 0.20,
        bottom = self.display:getWidth() * 0.20
    }
    self.padding = padding
    setmetatable(self, { __index = Button })
    return self
end

function Button:getWidth()
    return self.display:getWidth()
end

function Button:getHeight()
    return self.display:getHeight()
end

function Button:radius()
    return self.display:getWidth() / 2 * scale
end

function Button:origin()
    return self.x + self:radius(), self.y + self:radius()
end

function Button:intersects(x1, y1)
    local x2, y2 = self:origin()
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2) <= self:radius() 
end

function Button:press()
    self.display = self.buttonPressedImg
    sounds["on_press"]:play()
end

function Button:release()
    self.display = self.buttonImg
    sounds["on_release"]:play()
end

function Button:draw()
    local x, y = self:origin()
    local radius = self:radius()
    love.graphics.draw(self.display, self.x, self.y, 0, scale, scale)
    love.graphics.circle("line", x, y, radius)
end

return Button
