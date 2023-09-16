-- Import Modules
local enet = require("enet")
local socket = require("socket")
local struct = require("deps/struct")

-- Scenes
local MainMenu = require("scenes/main_menu")
local GameScene = require("scenes/game")
local WaitingForGameScene = require("scenes/waiting")

local sounds

function love.load()
    -- Set up ENet host
    local server_ip, server_port = "127.0.0.1", 12345
    client = enet.host_create()
    peer = client:connect(server_ip .. ":" .. server_port)
    client:service(100)

    sounds = {
        on_press_sd = love.sound.newSoundData("assets/click-press.mp3"),
        on_release_sd = love.sound.newSoundData("assets/click-release.mp3"),
        rock_win = love.audio.newSource("assets/rock-win.mp3", "static"),
        paper_win = love.audio.newSource("assets/paper-win.mp3", "static"),
        scissors_win = love.audio.newSource("assets/scissors-win.mp3", "static"),
        tie = love.audio.newSource("assets/tie.mp3", "static")
    }
    local click_source = love.audio.newQueueableSource(
        sounds["on_press_sd"]:getSampleRate(),
        sounds["on_press_sd"]:getBitDepth(),
        sounds["on_press_sd"]:getChannelCount(),
        2)
    sounds["click_source"] = click_source

    math.randomseed(os.time())
    scene = MainMenu
    scene.load()
end

function love.mousepressed(x, y, mouseButton, istouch)
    sounds["click_source"]:queue(sounds["on_press_sd"], sounds["on_press_sd"]:getSize() * 0.50)
    sounds["click_source"]:play()
    scene.mousepressed(x, y, mouseButton, istouch)
end

function love.mousereleased(x, y, mouseButton)
    -- Scaling the size down so that there isn't too much lag between sounds played.
    -- The scaling is aligned to the sample size (4 in this case)
    local size = math.floor(sounds["on_release_sd"]:getSize() * 0.30 / 4) * 4
    sounds["click_source"]:queue(sounds["on_release_sd"], size)
    sounds["click_source"]:play()
    scene.mousereleased(x, y, mouseButton)
end

-- Communication Protocol Signals
MATCHMAKING_REQ = 1
MATCHMAKING_ACK = 2
MATCHMAKING_COMP = 3
ROCK, PAPER, SCISSORS = 4, 5, 6

-- It may be preferrable to call client:service in the update function of each scene; such an
-- approach is probably non-negotiable for larger projects, but I like the simplicity of handling
-- all the logic here.
function love.update(dt)
    scene.update(dt)
    case =
    {
        [MATCHMAKING_ACK] = function()
            scene = WaitingForGameScene
            scene.load()
        end,
        [MATCHMAKING_COMP] = function()
            local match_id
            _, GameScene.match_id = struct.unpack('!B 16s', event.data)
            scene = GameScene
            scene.load()
        end,
        [ROCK] = function()
            -- TODO: write a function to do this in a simpler manner
            if GameScene.choice == PAPER then
                GameScene.gameWinText = "You Win!"
                sounds["paper_win"]:play()
            elseif GameScene.choice == SCISSORS then
                GameScene.gameWinText = "You Lost :("
                sounds["rock_win"]:play()
            else
                GameScene.gameWinText = "You got a tie."
                sounds["tie"]:play()
            end
            GameScene.choice = nil
        end,
        [PAPER] = function()
            if GameScene.choice == SCISSORS then
                GameScene.gameWinText = "You Win!"
                sounds["scissors_win"]:play()
            elseif GameScene.choice == ROCK then
                GameScene.gameWinText = "You Lost :("
                sounds["paper_win"]:play()
            else
                GameScene.gameWinText = "You got a tie."
                sounds["tie"]:play()
            end
            GameScene.choice = nil
        end,
        [SCISSORS] = function()
            if GameScene.choice == ROCK then
                GameScene.gameWinText = "You Win!"
                sounds["rock_win"]:play()
            elseif GameScene.choice == PAPER then
                GameScene.gameWinText = "You Lost :("
                sounds["scissors_win"]:play()
            else
                GameScene.gameWinText = "You got a tie."
                sounds["tie"]:play()
            end
            GameScene.choice = nil
        end
    }

    event = client:service(50)
    if event == nil then
        return
    end
    if event.type == "receive" then
        protocol = struct.unpack('!B', event.data)
        case[protocol]()
    end
end

function love.quit()
    peer:disconnect()
    client:flush()
end

function love.draw()
    scene.draw()
end

