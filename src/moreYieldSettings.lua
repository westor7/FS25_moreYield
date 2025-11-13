moreYieldSettings = {}
local moreYieldSettings_mt = Class(moreYieldSettings)

function moreYieldSettings.new()
    local self = setmetatable({}, moreYieldSettings_mt)

    self.Multiplier = 1.0

    return self
end

function moreYieldSettings:onSettingsChange(name)
    moreYield:Init()
end
