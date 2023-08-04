-- Import Modules
socket = require("socket")
Button = require("button")
HorizontalLayoutManager = require("horizontal_layout_manager")

function love.load()
    scale = 0.5

    images = {
        rock = love.graphics.newImage("rock.png"),
        paper = love.graphics.newImage("paper.png"),
        scissors = love.graphics.newImage("scissors.png"),
        rock_pressed = love.graphics.newImage("rock_pressed.png"),
        paper_pressed = love.graphics.newImage("paper_pressed.png"),
        scissors_pressed = love.graphics.newImage("scissors_pressed.png")
    }

    sounds = {
        on_press = love.audio.newSource("click-press.mp3", "static"),
        on_release = love.audio.newSource("click-release.mp3", "static")
    }

    buttons = {
        rock = Button:new(images["rock"], images["rock_pressed"], sounds),
        paper = Button:new(images["paper"], images["paper_pressed"], sounds),
        scissors = Button:new(images["scissors"], images["scissors_pressed"], sounds)
    }

    rock_paper_scissors = HorizontalLayoutManager:new(100, 100)
    rock_paper_scissors:addObject(buttons["rock"])
    rock_paper_scissors:addObject(buttons["paper"])
    rock_paper_scissors:addObject(buttons["scissors"])
    rock_paper_scissors:layout()
end

function love.mousepressed(x, y, mouseButton, istouch)
    for _, button in pairs(buttons) do
        if button:intersects(x, y) then
            button:press()
            button.sounds["on_press"]:play()
        end
    end
end

function love.mousereleased(x, y, mouseButton)
    for _, button in pairs(buttons) do
        if button:intersects(x, y) then
            button:release()
            button.sounds["on_release"]:play()
        end
    end
 end

function love.update(dt)
end

function love.draw()
    rock_paper_scissors:draw()
end

