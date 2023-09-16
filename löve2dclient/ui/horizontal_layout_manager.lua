local HorizontalLayoutManager = {}

function HorizontalLayoutManager:new()
    local self = {
        x = 0,
        y = 0,
        height = 0,
        width = 0,
        objects = {}
    }
    setmetatable(self, { __index = HorizontalLayoutManager })
    return self
end

function HorizontalLayoutManager:addObject(object)
    if self.height < object:getHeight() then
        self.height = object:getHeight()
    end
    if next(self.objects) == nil then
        self.width = self.width + object:getWidth()
    else
        self.width = self.width + object:getWidth() + self.objects[#self.objects].padding["right"]
    end
    table.insert(self.objects, object)
end

function HorizontalLayoutManager:getHeight()
    return self.height * scale
end

function HorizontalLayoutManager:getWidth()
    return self.width * scale
end

function HorizontalLayoutManager:layout()
    local x, y = self.x, self.y
    -- The HorizontalLayoutManager spaces elements apart using a padding defined on the object. A
    -- more sophisticated algorithm would look at both neighboring objects, external objects,
    -- potentially scale or wrap the elements, and respect boundaries defined for dimenions on the
    -- layout manager itself allowing for dynamic scaling. Each constraint is simple, but can form
    -- powerful expressions in an idealized UI manager.
    for _, object in ipairs(self.objects) do
        object.x = x
        object.y = y
        x = x + object:getWidth() * scale + object.padding["right"] * scale
    end
end

function HorizontalLayoutManager:draw()
    for name, element in pairs(self.objects) do
        element:draw()
    end
end

return HorizontalLayoutManager