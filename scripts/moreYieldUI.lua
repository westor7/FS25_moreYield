-- Author: westor
-- Contact: westor7 @ Discord
--
-- Copyright (c) 2025 westor

moreYieldUI = {}

-- Create a meta table to get basic Class-like behavior
local moreYieldUI_mt = Class(moreYieldUI)

---Creates the settings UI object
---@return SettingsUI @The new object
function moreYieldUI.new(settings)
	local self = setmetatable({}, moreYieldUI_mt)

	self.controls = {}
	self.settings = settings

	return self
end

---Register the UI into the base game UI
function moreYieldUI:registerSettings()
	-- Get a reference to the base game general settings page
	local settingsPage = g_gui.screenControllers[InGameMenu].pageSettings
	
	-- Define the UI controls. For each control, a <prefix>_<name>_short and _long key must exist in the i18n values
	local controlProperties = {
		{ name = "Multiplier", min = 1.5, max = 100, step = 0.5, autoBind = true, nillable = false }
	}

	UIHelper.createControlsDynamically(settingsPage, "myi_setting_title", self, controlProperties, "myi_")
	UIHelper.setupAutoBindControls(self, self.settings, moreYieldUI.onSettingsChange)

	-- Apply initial values
	self:updateUiElements()

	-- Update any additional settings whenever the frame gets opened
	InGameMenuSettingsFrame.onFrameOpen = Utils.appendedFunction(InGameMenuSettingsFrame.onFrameOpen, function()
		self:updateUiElements(true) -- We can skip autobind controls here since they are already registered to onFrameOpen
	end)
	
	-- Trigger to update the values when settings frame is closed
	InGameMenuSettingsFrame.onFrameClose = Utils.appendedFunction(InGameMenuSettingsFrame.onFrameClose, function()
		self:onFrameClose();
	end);

end

function moreYieldUI:onSettingsChange()
	self:updateUiElements()
end

---Updates the UI elements to reflect the current settings
---@param skipAutoBindControls boolean|nil @True if controls with the autoBind properties shall not be newly populated
function moreYieldUI:updateUiElements(skipAutoBindControls)
	if not skipAutoBindControls then
		-- Note: This method is created dynamically by UIHelper.setupAutoBindControls
		self.populateAutoBindControls()
	end

	local isAdmin = g_currentMission:getIsServer() or g_currentMission.isMasterUser

	for _, control in ipairs(self.controls) do
		control:setDisabled(not isAdmin)
	end
	
	-- Update the focus manager
	local settingsPage = g_gui.screenControllers[InGameMenu].pageSettings
	settingsPage.generalSettingsLayout:invalidateLayout()
end

function moreYieldUI:onFrameClose()
	if moreYield.settings.Multiplier == moreYield.settings.OldMultiplier then return end
	
	moreYield:Init()

	moreYield.settings.OldMultiplier = moreYield.settings.Multiplier

	g_currentMission:showBlinkingWarning(g_i18n:getText("myi_blink_warn"), 5000)
end