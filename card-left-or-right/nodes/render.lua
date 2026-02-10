-- nodes/render.lua
local Render = {}

function Render:draw(position)
    love.graphics.circle("fill", position.x, position.y, 20)
end

return Render