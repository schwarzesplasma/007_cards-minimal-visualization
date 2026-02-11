local Input    = require("nodes.input")
local Movement = require("nodes.movement")

function love.load()
    love.window.setMode(800, 600)

    inputNode    = Input.create()
    movementNode = Movement.create()
end

function love.update(dt)
    inputNode:update()
    movementNode:update(dt, inputNode)
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", movementNode.x, movementNode.y, 20)
		print(movementNode)
end