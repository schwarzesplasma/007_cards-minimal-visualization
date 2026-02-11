local Input						= require("nodes.input")
local Movement 			= require("nodes.movement")
local Dump						= require("nodes.dump")

function love.load()
    love.window.setMode(800, 600)

    inputNode    = Input.create()
end

function love.update(dt)
	inputNode:update()
	movementNode:update(dt, inputNode)
	Dump.table(movementNode, "movementNode")
	Dump.table(movementNode, "inputNode")
	
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", movementNode.x, movementNode.y, 20)
end