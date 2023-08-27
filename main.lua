-- Import Modules
local enet = require("enet")
local socket = require("socket")
local GameScene = require("scenes/game")

function love.load()
    -- Set up ENet host
    local server_ip, server_port = "127.0.0.1", 12345
    client = enet.host_create()
    peer = client:connect(server_ip .. ":" .. server_port)
    client:service(100)

    -- TODO: Make another scene ;)
    scene = GameScene
    scene.load()
end

function love.mousepressed(x, y, mouseButton, istouch)
    scene.mousepressed(x, y, mouseButton, istouch)
end

function love.mousereleased(x, y, mouseButton)
    scene.mousereleased(x, y, mouseButton)
 end

function love.update(dt)
    scene.update(dt)
end

function love.draw()
    scene.draw()
end

