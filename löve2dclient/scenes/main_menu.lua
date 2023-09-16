local RectangleButton = require("ui/rectanglebutton")
local Scene = require("scenes/scene")
local bit = require("bit")
local struct = require("deps/struct")

local MainMenu = {}
setmetatable(MainMenu, { __index = Scene })

function MainMenu.layout()
    MainMenu.playButton.x = (love.graphics.getWidth() - MainMenu.playButton:getWidth()) / 2
    MainMenu.playButton.y = (love.graphics.getHeight() - MainMenu.playButton:getHeight()) / 2
end

function MainMenu.load()
    local background_music

    MainMenu.title = "Rock! Paper! Scissors!"
    MainMenu.titleFont = love.graphics.newFont("assets/JackInput.ttf", 24)
    love.graphics.setFont(MainMenu.titleFont)

    background_music = love.audio.newSource("assets/Stay the Course.mp3", "static")
    background_music:play()

    MainMenu.playButton = MainMenu.createPlayButton()
    MainMenu.layout()
end

function MainMenu.mousepressed(x, y, mouseButton, istouch)
    if MainMenu.playButton:intersects(x, y) then
        MainMenu.playButton:press()
        peer:send(struct.pack('!B', MATCHMAKING_REQ))
    end
end

function MainMenu.mousereleased(x, y, mouseButton)
    MainMenu.playButton:release()
end

function MainMenu.update(dt)
end

function MainMenu.draw()
    local font = MainMenu.titleFont
    local x = (love.graphics.getWidth() - font:getWidth(MainMenu.title)) / 2
    local y = (love.graphics.getHeight() - font:getHeight()) / 2
    love.graphics.print(MainMenu.title, x, y - 130)
    MainMenu.playButton:draw()
end

function MainMenu.createPlayButton()
    local color, r, g, b

    local choices = {
        [1] = 0x4224FE,
        [2] = 0x268554,
        [3] = 0xBE1B20
    }

    color = choices[math.random(1, 3)]
    r = bit.band(bit.rshift(color, 16), 0xFF)
    g = bit.band(bit.rshift(color, 8), 0xFF)
    b = bit.band(color, 0xFF)
    r, g, b = r / 255, g / 255, b / 255

    local buttonImg, buttonPressedImg, font
    font = MainMenu.titleFont
    buttonImg = RectangleButton.createButtonImage("Play", font, r, g, b, 1)
    buttonPressedImg = RectangleButton.createButtonImage("Play", font, r * 0.8, g * 0.8, b * 0.8, 1)

    return RectangleButton:new(buttonImg, buttonPressedImg)
end

return MainMenu

