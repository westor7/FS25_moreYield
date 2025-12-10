-- Author: westor
-- Contact: westor7 @ Discord
-- Github: https://github.com/westor7/FS25_moreYield
--
-- Copyright (c) 2025 westor

moreYieldUI = {}
local moreYieldUI_mt = Class(moreYieldUI)

function moreYieldUI.new(settings)
	local self = setmetatable({}, moreYieldUI_mt)
	
	InGameMenuSettingsFrame.onFrameOpen = Utils.prependedFunction(InGameMenuSettingsFrame.onFrameOpen, function()
		self:onFrameOpen()
    end)
	
	InGameMenuSettingsFrame.onFrameClose = Utils.prependedFunction(InGameMenuSettingsFrame.onFrameClose, function()
		self:onFrameClose()
    end)

	self.controls = {}
	self.settings = settings
	self.isInitialized = false

	return self
end

function moreYieldUI:onFrameOpen()
	self:updateUiElements(true)
	
	moreYield.settings.OldCropMultiplier = moreYield.settings.CropMultiplier
	moreYield.settings.OldWindrowMultiplier = moreYield.settings.WindrowMultiplier
end

function moreYieldUI:onFrameClose()
	if (g_currentMission ~= nil) then 
	
		if (moreYield.settings.CropMultiplier ~= moreYield.settings.OldCropMultiplier) then
			moreYield.logInfo("Crop multiplier has been changed from settings panel. - Old: %s - New: %s", moreYield:outFormat(moreYield.settings.OldCropMultiplier), moreYield:outFormat(moreYield.settings.CropMultiplier))
			
			g_currentMission:showBlinkingWarning(g_i18n:getText("myi_crop_blink_warn"), 5000)
			
			local doInit = true
		end

		if (moreYield.settings.WindrowMultiplier ~= moreYield.settings.OldWindrowMultiplier) then
			moreYield.logInfo("Windrow multiplier has been changed from settings panel. - Old: %s - New: %s", moreYield:outFormat(moreYield.settings.OldWindrowMultiplier), moreYield:outFormat(moreYield.settings.WindrowMultiplier))
			
			g_currentMission:showBlinkingWarning(g_i18n:getText("myi_windrow_blink_warn"), 5000)
			
			local doInit = true
		end
		
	end
	
	if (doInit) then moreYield:Init() end
		
	moreYield.settings.OldCropMultiplier = 0
	moreYield.settings.OldWindrowMultiplier = 0
end

function moreYieldUI:injectUiSettings()
	if (g_dedicatedServer) then return end
	if (self.isInitialized) then return end

	self.isInitialized = true
	
	local settingsPage = g_gui.screenControllers[InGameMenu].pageSettings
	
	local controlProperties = {
		{ name = "CropMultiplier", min = 1, max = 100, step = 0.1, autoBind = true, nillable = false },
		{ name = "WindrowMultiplier", min = 1, max = 100, step = 0.1, autoBind = true, nillable = false }
	}
	
	UIHelper.createControlsDynamically(settingsPage, "myi_setting_title", self, controlProperties, "myi_")
	UIHelper.setupAutoBindControls(self, self.settings, moreYieldUI.onSettingsChange)
	
	self:updateUiElements()
end

function moreYieldUI:onSettingsChange()
    self:updateUiElements()
	self.settings:publishNewSettings()
end

function moreYieldUI:updateUiElements(skipAutoBindControls)
    if not (skipAutoBindControls) then self.populateAutoBindControls() end
	
	local isAdmin = g_currentMission:getIsServer() or g_currentMission.isMasterUser

	for _, control in ipairs(self.controls) do control:setDisabled(not isAdmin)	end
	
    local settingsPage = g_gui.screenControllers[InGameMenu].pageSettings
	
    settingsPage.gameSettingsLayout:invalidateLayout()
end