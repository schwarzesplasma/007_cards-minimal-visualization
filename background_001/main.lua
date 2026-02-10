local Background = require("background")

local presets = Background.getPresetNames()
local presetIndex = 1
local background

local function cyclePreset()
    presetIndex = (presetIndex % #presets) + 1
    local preset = presets[presetIndex]
    local ok, err = background:applyPreset(preset)
    if ok then
        print("Applied preset:", preset)
    else
        print("Failed to apply preset:", tostring(err))
    end
end

function love.load()
    love.window.setTitle("Background Generator")
    background = Background.new({
        preset = presets[presetIndex],
        seed = 1337,
    })

    print("Controls: [P] next preset, [R] regenerate seed, [O] reload shader, [Esc] quit")
end

function love.update(dt)
    background:update(dt)
end

function love.draw()
    background:draw(0, 0)
end

function love.resize(w, h)
    background:resize(w, h)
end

function love.keypressed(key)
    if key == "p" then
        cyclePreset()
    elseif key == "r" then
        background:regenerate(os.time())
        print("Regenerated with a new seed")
    elseif key == "o" then
        local ok, err = background:reloadShader()
        if ok then
            print("Shader reloaded")
        else
            print("Shader reload failed:", tostring(err))
        end
    elseif key == "escape" then
        love.event.quit()
    end
end
