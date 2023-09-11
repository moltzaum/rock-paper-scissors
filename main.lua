-- Import Modules
local enet = require("enet")
local socket = require("socket")

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

-- It may be preferrable to call client:service in the update function of each scene; such an
-- approach is probably non-negotiable for larger projects, but I like the simplicity of handling
-- all the logic here.
function love.update(dt)
    scene.update(dt)
    case =
    {
        ["matchmaking received"] = function()
            scene = WaitingForGameScene
            scene.load()
        end,
        ["match found"] = function()
            scene = GameScene
            scene.load()
        end
    }
    event = client:service(50)
    if event == nil then
        return
    end
    if event.type == "receive" then
        case[event.data]()
    end
end

function love.draw()
    scene.draw()
end

