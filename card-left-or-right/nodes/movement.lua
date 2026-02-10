local Movement = {}
Movement.__index = Movement

function Movement:new()
    local obj = {
        x = 100,
        y = 100,
        speed = 200
    }
    setmetatable(obj, Movement)
    return obj
end

function Movement:update(dt, input)
    if input.left  then self.x = self.x - self.speed * dt end
    if input.right then self.x = self.x + self.speed * dt end
end

return Movement