-- Author: westor
-- Contact: westor7 @ Discord
-- Github: https://github.com/westor7/FS25_moreYield
--
-- Copyright (c) 2025 westor

moreYieldUI = {}
local moreYieldUI_mt = Class(moreYieldUI)

function moreYieldUI.new()
    local self = setmetatable({}, moreYieldUI_mt)

    self.controls = {}
    self.loadedConfig = nil
    self.isInitialized = false

    return self
end

function moreYieldUI:injectUiSettings(loadedConfig)
    self.loadedConfig = loadedConfig

    if self.isInitialized then return end
    self.isInitialized = true

    local settingsPage = g_gui.screenControllers[InGameMenu].pageSettings

    local controlProperties = {
		{ name = "Multiplier", min = 1.5, max = 100, step = 0.5, autoBind = true, nillable = false }
	}

    UIHelper.createControlsDynamically(settingsPage, "myi_setting_title", self, controlProperties, "myi_")

    UIHelper.setupAutoBindControls(self, self.loadedConfig, moreYieldUI.onSettingsChange)

    self:updateUiElements()

    InGameMenuSettingsFrame.onFrameOpen = Utils.appendedFunction(InGameMenuSettingsFrame.onFrameOpen, function()
        self:updateUiElements(true)
    end)
end

function moreYieldUI:onSettingsChange(control)
    self:updateUiElements()

    moreYield.settings.Multiplier = self.loadedConfig.Multiplier
    moreYield:Init()
end

function moreYieldUI:updateUiElements(skipAutoBindControls)
    if not skipAutoBindControls then
        self.populateAutoBindControls()
    end
end