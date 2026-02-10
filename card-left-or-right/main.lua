local Input = require("nodes.input")
local Movement = require("nodes.movement")

function love.load()
    inputNode = Input:new()
    movementNode = Movement:new()
end

function love.update(dt)
    inputNode:update()
    movementNode:update(dt, inputNode)
end

function love.draw()
    love.graphics.circle("fill", movementNode.x, movementNode.y, 20)
end