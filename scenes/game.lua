-- Import Modules
local HorizontalLayoutManager = require("horizontal_layout_manager")
local Button = require("button")

local GameScene = {}
local Button = require("button")

function GameScene.load()
    local images = {
        rock = love.graphics.newImage("assets/rock.png"),
        paper = love.graphics.newImage("assets/paper.png"),
        scissors = love.graphics.newImage("assets/scissors.png"),
        rock_pressed = love.graphics.newImage("assets/rock_pressed.png"),
        paper_pressed = love.graphics.newImage("assets/paper_pressed.png"),
        scissors_pressed = love.graphics.newImage("assets/scissors_pressed.png")
    }

    local sounds = {
        on_press = love.audio.newSource("assets/click-press.mp3", "static"),
        on_release = love.audio.newSource("assets/click-release.mp3", "static")
    }

    local buttons = {
        rock = Button:new(images["rock"], images["rock_pressed"], sounds),
        paper = Button:new(images["paper"], images["paper_pressed"], sounds),
        scissors = Button:new(images["scissors"], images["scissors_pressed"], sounds)
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
            peer:send(name)
            button:press()
            button.sounds["on_press"]:play()
        end
    end
end

function GameScene.mousereleased(x, y, mouseButton)
    for _, button in pairs(GameScene.buttons) do
        if button:intersects(x, y) then
            button:release()
            button.sounds["on_release"]:play()
        end
    end
end

function GameScene.update(dt)
    -- TODO: have the server send back information and parse data from the server
    client:service(50)
end

function GameScene.draw()
    rock_paper_scissors:draw()
end

return GameScene