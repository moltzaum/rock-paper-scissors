-- Import Modules
local HorizontalLayoutManager = require("ui/horizontal_layout_manager")
local Scene = require("scenes/scene")
local struct = require("deps/struct")
local Button = require("ui/button")
local RectangleButton = Button.RectangleButton
local CircleButton = Button.CircleButton

local GameScene = {}
setmetatable(GameScene, { __index = Scene })

-- I suppose I want this similar enough to the menu play button, so generalize the function?
function GameScene.createContinueButton(font)
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

    local buttonImg, buttonPressedImg
    love.graphics.setFont(font)
    buttonImg = RectangleButton.createButtonImage("continue?", font, r, g, b, 1)
    buttonPressedImg = RectangleButton.createButtonImage("continue?", font, r * 0.8, g * 0.8, b * 0.8, 1)
    return RectangleButton:new(buttonImg, buttonPressedImg)
end

function GameScene.createCanvas(r, g, b, a)
    local canvas
    canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setCanvas(canvas)
    love.graphics.setColor(r, g, b, a)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setCanvas()
    return canvas
end

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
    -- TODO: try to remove this as a global variable eventually
    scale = 0.5

    local rock_paper_scissors = HorizontalLayoutManager:new(100, 100)
    rock_paper_scissors:addObject(buttons["rock"])
    rock_paper_scissors:addObject(buttons["paper"])
    rock_paper_scissors:addObject(buttons["scissors"])

    -- center on x and y axis, then set internal objects with layout
    local offset = -100
    rock_paper_scissors.x = (love.graphics.getWidth() - rock_paper_scissors:getWidth()) / 2
    rock_paper_scissors.y = (love.graphics.getHeight() - rock_paper_scissors:getHeight() + offset) / 2
    rock_paper_scissors:layout()

    GameScene.gameResultFont = love.graphics.newFont("assets/JackInput.ttf", 24)
    GameScene.continueFont = love.graphics.newFont("assets/gomarice_game_continue.ttf", 24)

    local canvas = GameScene.createCanvas(0, 0, 0, 0.5)
    local button = GameScene.createContinueButton(GameScene.continueFont)
    button.x = (love.graphics.getWidth() - button:getWidth()) / 2
    button.y = (love.graphics.getHeight() - button:getHeight()) / 2

    GameScene.rock_paper_scissors = rock_paper_scissors
    GameScene.continueButton = button
    GameScene.continueBG = canvas
    GameScene.buttons = buttons
end

function GameScene.mousepressed(x, y, mouseButton, istouch)
    if GameScene.gameWinText then
        local button = GameScene.continueButton
        if button:intersects(x, y) then
            button:press()
            GameScene.gameWinText = nil
        end
        return
    end
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
    -- releasing unconditionally seems to be better than adding conditional logic
    GameScene.continueButton:release()
    for _, button in pairs(GameScene.buttons) do
            button:release()
    end
end

function GameScene.update(dt)
end

function GameScene.draw()
    scale = 0.5
    GameScene.rock_paper_scissors:draw()
    if GameScene.gameWinText then
        local offset = 130
        scale = 1
        love.graphics.draw(GameScene.continueBG)
        love.graphics.setFont(GameScene.gameResultFont)
        love.graphics.print(GameScene.gameWinText,
            (love.graphics.getWidth() - GameScene.gameResultFont:getWidth(GameScene.gameWinText)) / 2,
            (love.graphics.getHeight() - GameScene.gameResultFont:getHeight()) / 2 + offset)
        GameScene.continueButton:draw()
    end
end

return GameScene