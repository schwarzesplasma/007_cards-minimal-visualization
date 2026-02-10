local Movement = {}

function Movement.create()
    return {
        x = 400,
        y = 300,
        speed = 200,

        update = function(self, dt, input)
            if input.left  then self.x = self.x - self.speed * dt end
            if input.right then self.x = self.x + self.speed * dt end
            if input.up    then self.y = self.y - self.speed * dt end
            if input.down  then self.y = self.y + self.speed * dt end
        end
    }
end

return Movement