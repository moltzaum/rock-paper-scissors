local Button = {}
local CircleButton = {}
local RectangleButton = {}

-- Static Helper Function
-- This function creates a placeholder recangle canvas with fixed dimensions of 140x100
function Button.createButtonImage(text, font, r, g, b, a)
    local canvas

    local function roundRectangle(x, y, width, height, radius)
        love.graphics.rectangle("fill", x + radius, y + radius, width - (radius * 2), height - radius * 2)
        love.graphics.rectangle("fill", x + radius, y, width - (radius * 2), radius)
        love.graphics.rectangle("fill", x + radius, y + height - radius, width - (radius * 2), radius)
        love.graphics.rectangle("fill", x, y + radius, radius, height - (radius * 2))
        love.graphics.rectangle("fill", x + (width - radius), y + radius, radius, height - (radius * 2))
        love.graphics.arc("fill", x + radius, y + radius, radius, math.rad(-180), math.rad(-90))
        love.graphics.arc("fill", x + width - radius , y + radius, radius, math.rad(-90), math.rad(0))
        love.graphics.arc("fill", x + radius, y + height - radius, radius, math.rad(-180), math.rad(-270))
        love.graphics.arc("fill", x + width - radius , y + height - radius, radius, math.rad(0), math.rad(90))
    end

    canvas = love.graphics.newCanvas(140, 100)
    love.graphics.setCanvas(canvas)
    love.graphics.setColor(r, g, b, a)
    roundRectangle(0, 0, 140, 100, 10)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(text,
        (canvas:getWidth() - font:getWidth(text)) / 2,
        (canvas:getHeight() - font:getHeight()) / 2)
    love.graphics.setCanvas()

    return canvas
end

function Button:new(buttonImg, buttonPressedImg)
    -- It is worth noting that the "buttonImg" may not be an image at all. The only requirement is
    -- that it can be drawn by love.graphics.draw. Refer to the documentation for details.
    local obj = {
        x = 0,
        y = 0,
        buttonImg = buttonImg,
        buttonPressedImg = buttonPressedImg,
        display = buttonImg
    }

    local padding = {
        right = obj.display:getWidth() * 0.20,
        left = obj.display:getWidth() * 0.20,
        top = obj.display:getWidth() * 0.20,
        bottom = obj.display:getWidth() * 0.20
    }

    obj.padding = padding
    setmetatable(obj, { __index = self })
    return obj
end

function Button:getWidth()
    return self.display:getWidth()
end

function Button:getHeight()
    return self.display:getHeight()
end

function Button:press()
    self.display = self.buttonPressedImg
end

function Button:release()
    self.display = self.buttonImg
end

function Button:draw()
    love.graphics.draw(self.display, self.x, self.y, 0, scale, scale)
end

-- inherit everything from the base button class
setmetatable(CircleButton, { __index = Button })
setmetatable(RectangleButton, { __index = Button })

function CircleButton:radius()
    return self.display:getWidth() / 2 * scale
end

function CircleButton:origin()
    return self.x + self:radius(), self.y + self:radius()
end

function CircleButton:intersects(x1, y1)
    local x2, y2 = self:origin()
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2) <= self:radius()
end

function CircleButton:draw()
    local x, y = self:origin()
    local radius = self:radius()
    love.graphics.draw(self.display, self.x, self.y, 0, scale, scale)
    love.graphics.circle("line", x, y, radius)
end

function RectangleButton:intersects(x1, y1)
    local x2, y2 = self.x, self.y
    return x1 >= x2 and x1 <= x2 + self:getWidth() and
           y1 >= y2 and y1 <= y2 + self:getHeight()
end

Button.CircleButton = CircleButton
Button.RectangleButton = RectangleButton

return Button
