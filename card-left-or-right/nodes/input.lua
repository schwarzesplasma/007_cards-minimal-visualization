local Input = {}
Input.__index = Input

function Input:new()
    local obj = {
        left = false,
        right = false,
        up = false,
        down = false
    }
    setmetatable(obj, Input)
    return obj
end

function Input:update()
    self.left  = love.keyboard.isDown("a")
    self.right = love.keyboard.isDown("d")
    self.up    = love.keyboard.isDown("w")
    self.down  = love.keyboard.isDown("s")
end

return Input