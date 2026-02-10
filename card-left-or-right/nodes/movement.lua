-- nodes/movement.lua
local Movement = {}
Movement.__index = Movement

function Movement:new()
	Movementlocal obj = {
		}
    return {
        x = 100,
        y = 100,
        speed = 200
    }
end

function Movement:update(dt, input)
    if input.left then self.x = self.x - self.speed * dt end
    if input.right then self.x = self.x + self.speed * dt end
    if input.up then self.y = self.y - self.speed * dt end
    if input.down then self.y = self.y + self.speed * dt end
end

return Movement