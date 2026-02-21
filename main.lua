local Game = require("nodes.game")
local Dump = require("utils.dump")

local game

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    os.execute("cls")

    game = Game.create()
    game:load()

    print(Dump.toString(game, "game"))
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.keypressed(key)
    game:keypressed(key)
end

function love.mousepressed(x, y, button)
    game:mousepressed(x, y, button)

end
