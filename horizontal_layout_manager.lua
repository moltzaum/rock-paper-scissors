local HorizontalLayoutManager = {}

function HorizontalLayoutManager:new(x, y)
    local self = {
        x = x,
        y = y,
        objects = {}
    }
    setmetatable(self, { __index = HorizontalLayoutManager })
    return self
end

function HorizontalLayoutManager:addObject(object)
    table.insert(self.objects, object)
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