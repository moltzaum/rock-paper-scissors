-- Import Modules
local HorizontalLayoutManager = require("ui/horizontal_layout_manager")
local CircleButton = require("ui/circlebutton")
local Scene = require("scenes/scene")
local struct = require("deps/struct")

local GameScene = {}
setmetatable(GameScene, { __index = Scene })

function GameScene.load()
    local images = {
        rock = love.graphics.newImage("assets/rock.png"),
        paper = love.graphics.newImage("assets/paper.png"),
        scissors = love.graphics.newImage("assets/scissors.png"),
        rock_pressed = love.graphics.newImage("assets/rock_pressed.png"),
        paper_pressed = love.graphics.newImage("assets/paper_pressed.png"),
        scissors_pressed = love.graphics.newImage("assets/scissors_pressed.png")
    }

    local buttons = {
        rock = CircleButton:new(images["rock"], images["rock_pressed"]),
        paper = CircleButton:new(images["paper"], images["paper_pressed"]),
        scissors = CircleButton:new(images["scissors"], images["scissors_pressed"])
    }

    -- Used by the HorizontalLayoutManager
    scale = 0.5

    rock_paper_scissors = HorizontalLayoutManager:new(100, 100)
    rock_paper_scissors:addObject(buttons["rock"])
    rock_paper_scissors:addObject(buttons["paper"])
    rock_paper_scissors:addObject(buttons["scissors"])
    rock_paper_scissors:layout()

    GameScene.buttons = buttons
end

function GameScene.mousepressed(x, y, mouseButton, istouch)
    for name, button in pairs(GameScene.buttons) do
        if button:intersects(x, y) then
            case =
            {
                ["rock"] = ROCK,
                ["paper"] = PAPER,
                ["scissors"] = SCISSORS
            }
            GameScene.choice = case[name]
            peer:send(struct.pack('!B 16s', GameScene.choice, GameScene.match_id))
            button:press()
        end
    end
end

function GameScene.mousereleased(x, y, mouseButton)
    for _, button in pairs(GameScene.buttons) do
        if button:intersects(x, y) then
            button:release()
        end
    end
end

function GameScene.update(dt)
end

function GameScene.draw()
    rock_paper_scissors:draw()
end

return GameScene