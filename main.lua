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
        on_press = love.audio.newSource("assets/click-press.mp3", "static"),
        on_release = love.audio.newSource("assets/click-release.mp3", "static")
    }

    math.randomseed(os.time())
    scene = MainMenu
    scene.load()
end

function love.mousepressed(x, y, mouseButton, istouch)
    sounds["on_press"]:play()
    scene.mousepressed(x, y, mouseButton, istouch)
end

function love.mousereleased(x, y, mouseButton)
    sounds["on_release"]:play()
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
            -- TODO: reflect the state in the client with a message and write a common function
            if GameScene.choice == PAPER then
                print("you won!")
            elseif GameScene.choice == SCISSORS then
                print("you lose!")
            else
                print("tie!")
            end
            GameScene.choice = nil
        end,
        [PAPER] = function()
            if GameScene.choice == SCISSORS then
                print("you won!")
            elseif GameScene.choice == ROCK then
                print("you lost!")
            else
                print("tie!")
            end
            GameScene.choice = nil
        end,
        [SCISSORS] = function()
            if GameScene.choice == ROCK then
                print("you won!")
            elseif GameScene.choice == PAPER then
                print("you lost!")
            else
                print("tie!")
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

function love.draw()
    scene.draw()
end

