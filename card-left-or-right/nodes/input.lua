-- nodes/input.lua
local Input = {}

function Input:new()
    return {
        left = false,
        right = false,
        up = false,
        down = false
    }
end

function Input:update()
    self.left  = love.keyboard.isDown("a")
    self.right = love.keyboard.isDown("d")
    self.up    = love.keyboard.isDown("w")
    self.down  = love.keyboard.isDown("s")
end

return Input