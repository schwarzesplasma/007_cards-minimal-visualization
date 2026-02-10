local Input = {}

function Input.create()
    return {
        left  = false,
        right = false,
        up    = false,
        down  = false,

        update = function(self)
            self.left  = love.keyboard.isDown("a")
            self.right = love.keyboard.isDown("d")
            self.up    = love.keyboard.isDown("w")
            self.down  = love.keyboard.isDown("s")
        end
    }
end

return Input