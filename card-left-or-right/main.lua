-- main.lua
local Input				= require("nodes.input")
local Movement 		= require("nodes.movement")
local Render			= require("nodes.render")

function love.load()
	inputNode			= Input:new()
	movementNode	= Movement:new()
end

function love.update(dt)
	inputNode:update()
	movementNode:update(dt, inputNode)
end

function love.draw()
	Render:draw(movementNode)
end