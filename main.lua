-- Import Modules
local enet = require("enet")
local socket = require("socket")

local sounds
GameScene = require("scenes/game")
MainMenu = require("scenes/main_menu")

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

function love.update(dt)
    scene.update(dt)
end

function love.draw()
    scene.draw()
end

