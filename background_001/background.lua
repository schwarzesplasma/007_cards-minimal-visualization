-- background.lua
-- Reusable animated layered-noise background module for Love2D.

local Background = {}
Background.__index = Background

local PRESETS = {
    organic_clouds = {
        noiseScale = 7.2,
        morphSpeed = 0.18,
        driftSpeed = 0.035,
        driftAngle = 28.0,
        warpScale = 2.0,
        warpStrength = 0.16,
        warpSpeed = 0.18,
        fbmStrength = 0.36,
        fbmScale = 5.8,
        fbmSpeed = 0.14,
        fbmOctaves = 5,
        fbmGain = 0.52,
        fbmLacunarity = 2.1,
        noiseColor = {0.82, 0.9, 1.0, 1.0},
        layer2 = {
            enabled = true,
            noiseScale = 11.0,
            driftSpeed = -0.02,
            driftAngle = 210.0,
            blend = 0.42,
        },
    },
    soft_mist = {
        noiseScale = 1.5,
        morphSpeed = 0.1,
        driftSpeed = 0.02,
        driftAngle = 10.0,
        warpScale = 1.7,
        warpStrength = 0.1,
        warpSpeed = 0.12,
        fbmStrength = 0.24,
        fbmScale = 4.2,
        fbmSpeed = 0.08,
        fbmOctaves = 4,
        fbmGain = 0.55,
        fbmLacunarity = 1.9,
        noiseColor = {0.9, 0.95, 1.0, 1.0},
        layer2 = {
            enabled = true,
            noiseScale = 1.5,
            driftSpeed = -0.01,
            driftAngle = 200.0,
            blend = 0.3,
        },
    },
    storm_flow = {
        noiseScale = 8.5,
        morphSpeed = 0.26,
        driftSpeed = 0.08,
        driftAngle = 50.0,
        warpScale = 2.4,
        warpStrength = 0.22,
        warpSpeed = 0.28,
        fbmStrength = 0.52,
        fbmScale = 7.8,
        fbmSpeed = 0.2,
        fbmOctaves = 5,
        fbmGain = 0.48,
        fbmLacunarity = 2.35,
        noiseColor = {0.7, 0.82, 0.95, 1.0},
        layer2 = {
            enabled = true,
            noiseScale = 13.0,
            driftSpeed = -0.04,
            driftAngle = 225.0,
            blend = 0.5,
        },
    },
}

local function loadShaderCode(path)
    local code, err = love.filesystem.read(path)
    if not code then
        error("Failed to load shader '" .. path .. "': " .. tostring(err))
    end

    return code
end

local function makeSeedOffset(seed)
    local rng = love.math.newRandomGenerator(seed)
    return rng:random() * 64.0, rng:random() * 64.0
end

local function clamp(value, minimum, maximum)
    if value < minimum then
        return minimum
    end

    if value > maximum then
        return maximum
    end

    return value
end

local function toDriftDir(angleDegrees)
    local angleRadians = math.rad(angleDegrees)
    return math.cos(angleRadians), math.sin(angleRadians)
end

local function valueOrDefault(value, defaultValue)
    if value == nil then
        return defaultValue
    end

    return value
end

local function copyTable(value)
    if type(value) ~= "table" then
        return value
    end

    local out = {}
    for k, v in pairs(value) do
        out[k] = copyTable(v)
    end

    return out
end

local function mergeInto(dst, src)
    if type(src) ~= "table" then
        return dst
    end

    for k, v in pairs(src) do
        if type(v) == "table" and type(dst[k]) == "table" then
            mergeInto(dst[k], v)
        else
            dst[k] = copyTable(v)
        end
    end

    return dst
end

local function resolveConfigWithPreset(config)
    local resolved = {}

    if config.preset ~= nil and PRESETS[config.preset] ~= nil then
        mergeInto(resolved, PRESETS[config.preset])
    end

    mergeInto(resolved, config)
    return resolved
end

function Background.getPresetNames()
    return {"organic_clouds", "soft_mist", "storm_flow"}
end

function Background.new(config)
    config = resolveConfigWithPreset(config or {})

    local width = config.width or love.graphics.getWidth()
    local height = config.height or love.graphics.getHeight()
    local seed = config.seed or os.time()
    local seedX, seedY = makeSeedOffset(seed)
    local mainMorphSpeed = config.morphSpeed

    if mainMorphSpeed == nil then
        mainMorphSpeed = config.noiseSpeed
    end

    mainMorphSpeed = mainMorphSpeed or 0.35

    local mainDriftSpeed = config.driftSpeed or 0.0
    local mainDriftAngle = config.driftAngle or 0.0
    local mainDriftDirX, mainDriftDirY = toDriftDir(mainDriftAngle)

    local layer2Config = config.layer2
    local layer2Enabled = layer2Config ~= nil
    local layer2Scale = valueOrDefault(config.noiseScale, 8.0)
    local layer2MorphSpeed = mainMorphSpeed
    local layer2DriftSpeed = mainDriftSpeed
    local layer2DriftAngle = mainDriftAngle
    local layer2Blend = 0.5

    if layer2Config ~= nil then
        if layer2Config.enabled ~= nil then
            layer2Enabled = layer2Config.enabled
        end

        layer2Scale = valueOrDefault(layer2Config.noiseScale, layer2Scale)
        layer2MorphSpeed = layer2Config.morphSpeed
        if layer2MorphSpeed == nil then
            layer2MorphSpeed = layer2Config.noiseSpeed
        end

        if layer2MorphSpeed == nil then
            layer2MorphSpeed = mainMorphSpeed
        end

        layer2DriftSpeed = valueOrDefault(layer2Config.driftSpeed, mainDriftSpeed)
        layer2DriftAngle = valueOrDefault(layer2Config.driftAngle, mainDriftAngle)
        layer2Blend = clamp(valueOrDefault(layer2Config.blend, layer2Blend), 0.0, 1.0)
    end

    local layer2DriftDirX, layer2DriftDirY = toDriftDir(layer2DriftAngle)

    local self = setmetatable({
        width = width,
        height = height,
        seed = seed,
        seedOffsetX = seedX,
        seedOffsetY = seedY,
        noiseScale = config.noiseScale or 8.0,
        morphSpeed = mainMorphSpeed,
        driftSpeed = mainDriftSpeed,
        driftAngle = mainDriftAngle,
        driftDirX = mainDriftDirX,
        driftDirY = mainDriftDirY,
        lowColor = config.lowColor or {0.08, 0.10, 0.14, 1.0},
        highColor = config.highColor or {0.35, 0.42, 0.55, 1.0},
        noiseColor = config.noiseColor or config.tintColor or {1.0, 1.0, 1.0, 1.0},
        warpScale = config.warpScale or 2.0,
        warpStrength = config.warpStrength or 0.12,
        warpSpeed = config.warpSpeed or 0.3,
        fbmStrength = config.fbmStrength or 0.0,
        fbmScale = config.fbmScale or 6.0,
        fbmSpeed = config.fbmSpeed or 0.25,
        fbmOctaves = math.floor(clamp(config.fbmOctaves or 4, 1, 8)),
        fbmGain = config.fbmGain or 0.5,
        fbmLacunarity = config.fbmLacunarity or 2.0,
        layer2Enabled = layer2Enabled,
        layer2NoiseScale = layer2Scale,
        layer2MorphSpeed = layer2MorphSpeed,
        layer2DriftSpeed = layer2DriftSpeed,
        layer2DriftAngle = layer2DriftAngle,
        layer2DriftDirX = layer2DriftDirX,
        layer2DriftDirY = layer2DriftDirY,
        layer2Blend = layer2Blend,
        time = 0,
        shaderPath = "noise.glsl",
        shader = love.graphics.newShader(loadShaderCode("noise.glsl")),
    }, Background)

    self:_syncShader()
    return self
end

function Background:_syncShader()
    self.shader:send("u_resolution", {self.width, self.height})
    self.shader:send("u_seedOffset", {self.seedOffsetX, self.seedOffsetY})
    self.shader:send("u_time", math.fmod(self.time, 1024.0))
    self.shader:send("u_noiseScale1", self.noiseScale)
    self.shader:send("u_morphSpeed1", self.morphSpeed)
    self.shader:send("u_driftSpeed1", self.driftSpeed)
    self.shader:send("u_driftDir1", {self.driftDirX, self.driftDirY})
    self.shader:send("u_layer2Enabled", self.layer2Enabled and 1.0 or 0.0)
    self.shader:send("u_noiseScale2", self.layer2NoiseScale)
    self.shader:send("u_morphSpeed2", self.layer2MorphSpeed)
    self.shader:send("u_driftSpeed2", self.layer2DriftSpeed)
    self.shader:send("u_driftDir2", {self.layer2DriftDirX, self.layer2DriftDirY})
    self.shader:send("u_layer2Blend", self.layer2Blend)
    self.shader:send("u_warpScale", self.warpScale)
    self.shader:send("u_warpStrength", self.warpStrength)
    self.shader:send("u_warpSpeed", self.warpSpeed)
    self.shader:send("u_fbmStrength", clamp(self.fbmStrength, 0.0, 1.0))
    self.shader:send("u_fbmScale", self.fbmScale)
    self.shader:send("u_fbmSpeed", self.fbmSpeed)
    self.shader:send("u_fbmOctaves", self.fbmOctaves)
    self.shader:send("u_fbmGain", self.fbmGain)
    self.shader:send("u_fbmLacunarity", self.fbmLacunarity)
    self.shader:send("u_noiseColor", self.noiseColor)
    self.shader:send("u_lowColor", self.lowColor)
    self.shader:send("u_highColor", self.highColor)
end

function Background:applyPreset(name)
    local preset = PRESETS[name]
    if preset == nil then
        return false, "Unknown preset: " .. tostring(name)
    end

    local cfg = copyTable(preset)
    cfg.noiseColor = cfg.noiseColor or self.noiseColor

    self.noiseScale = cfg.noiseScale
    self.morphSpeed = cfg.morphSpeed
    self.driftSpeed = cfg.driftSpeed
    self.driftAngle = cfg.driftAngle
    self.driftDirX, self.driftDirY = toDriftDir(self.driftAngle)

    self.warpScale = cfg.warpScale
    self.warpStrength = cfg.warpStrength
    self.warpSpeed = cfg.warpSpeed

    self.fbmStrength = cfg.fbmStrength
    self.fbmScale = cfg.fbmScale
    self.fbmSpeed = cfg.fbmSpeed
    self.fbmOctaves = math.floor(clamp(cfg.fbmOctaves, 1, 8))
    self.fbmGain = cfg.fbmGain
    self.fbmLacunarity = cfg.fbmLacunarity

    self.noiseColor = cfg.noiseColor

    self.layer2Enabled = cfg.layer2 ~= nil and (cfg.layer2.enabled ~= false)
    if cfg.layer2 ~= nil then
        self.layer2NoiseScale = valueOrDefault(cfg.layer2.noiseScale, self.noiseScale)
        self.layer2MorphSpeed = valueOrDefault(cfg.layer2.morphSpeed, self.morphSpeed)
        self.layer2DriftSpeed = valueOrDefault(cfg.layer2.driftSpeed, self.driftSpeed)
        self.layer2DriftAngle = valueOrDefault(cfg.layer2.driftAngle, self.driftAngle)
        self.layer2DriftDirX, self.layer2DriftDirY = toDriftDir(self.layer2DriftAngle)
        self.layer2Blend = clamp(valueOrDefault(cfg.layer2.blend, 0.5), 0.0, 1.0)
    else
        self.layer2NoiseScale = self.noiseScale
        self.layer2MorphSpeed = self.morphSpeed
        self.layer2DriftSpeed = self.driftSpeed
        self.layer2DriftAngle = self.driftAngle
        self.layer2DriftDirX, self.layer2DriftDirY = self.driftDirX, self.driftDirY
        self.layer2Blend = 0.5
    end

    self:_syncShader()
    return true
end

function Background:reloadShader()
    local okCode, codeOrErr = pcall(loadShaderCode, self.shaderPath)
    if not okCode then
        return false, codeOrErr
    end

    local okShader, shaderOrErr = pcall(love.graphics.newShader, codeOrErr)
    if not okShader then
        return false, shaderOrErr
    end

    self.shader = shaderOrErr
    self:_syncShader()
    return true
end

function Background:regenerate(newSeed)
    if newSeed ~= nil then
        self.seed = newSeed
    end

    self.seedOffsetX, self.seedOffsetY = makeSeedOffset(self.seed)
    self:_syncShader()
end

function Background:resize(width, height)
    self.width = width
    self.height = height
    self:_syncShader()
end

function Background:update(dt)
    self.time = self.time + dt
    self.shader:send("u_time", math.fmod(self.time, 1024.0))
end

function Background:draw(x, y)
    local dx = x or 0
    local dy = y or 0

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setShader(self.shader)
    love.graphics.rectangle("fill", dx, dy, self.width, self.height)
    love.graphics.setShader()
end

return Background
