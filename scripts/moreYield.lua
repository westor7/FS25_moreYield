-- Author: westor
-- Contact: westor7 @ Discord
--
-- Copyright (c) 2025 westor

moreYield = {}
moreYield.settings = {}
moreYield.name = g_currentModName or "FS25_moreYield"
moreYield.version = "1.0.0.1"
moreYield.debug = false -- for debugging purposes only
moreYield.dir = g_currentModDirectory
moreYield.init = false
moreYield.types = { -- all supported filltypes
	"WHEAT", 
	"BARLEY",
	"CANOLA",
	"OAT", 
	"MAIZE", 
	"SUNFLOWER",
	"SOYBEAN", 
	"COTTON",
	"SORGHUM",
	"GRAPE", 
	"OLIVE",
	"POPLAR",
	"GRASS",
	"MEADOW",
	"RICE",
	"RICELONGGRAIN",
	"PEA",
	"POTATO",
	"CARROT",
	"PARSNIP",
	"BEETROOT", 
	"SPINACH", 
	"GREENBEAN", 
	"SUGARBEET",
	"SUGARCANE"
}

function moreYield.prerequisitesPresent(specializations)
    return true
end

function moreYield:loadMap()
	Logging.info("[%s]: Initializing mod v".. moreYield.version .. " (c) 2025 by westor.", moreYield.name)
	
	if g_dedicatedServer or g_currentMission.missionDynamicInfo.isMultiplayer or not g_server or not g_currentMission:getIsServer() then
		Logging.error("[%s]: Error, Cannot use this mod because this mod is working only for singleplayer!", moreYield.name)

		return
    end
	
	InGameMenu.onMenuOpened = Utils.appendedFunction(InGameMenu.onMenuOpened, moreYield.initUi)
	
	FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, moreYield.saveSettings)
	
	moreYield:loadSettings()

	moreYield:Init()
end

function moreYield:mouseEvent(posX, posY, isDown, isUp, button)
end

function moreYield:keyEvent(unicode, sym, modifier, isDown)
end

function moreYield:update(dt)
end

function moreYield:draw(dt)
end

function moreYield:defSettings()
	moreYield.settings.Multiplier = 1.5
	moreYield.settings.Multiplier_OLD = 1.5
end

function moreYield:Init()
	local total = table.getn(moreYield.types)
	local updated = 0

	Logging.info("[%s]: Start of crops yield updates. - Total: ".. tostring(total) .."", moreYield.name)

	for index, validFruit in pairs(g_fruitTypeManager.fruitTypes) do
		
		for _, fruitTypeName in ipairs(moreYield.types) do
			local fruitType = g_fruitTypeManager:getFruitTypeByName(fruitTypeName)

			if fruitType ~= nil and fruitType == validFruit then
				local def_liters = g_fruitTypeManager.fruitTypes[index].defaultLiterPerSqm
				local old_liters = g_fruitTypeManager.fruitTypes[index].literPerSqm
				
				if not def_liters then
					g_fruitTypeManager.fruitTypes[index].defaultLiterPerSqm = old_liters
					
					def_liters = old_liters
				end
				
				local new_liters = def_liters * moreYield.settings.Multiplier
				
				g_fruitTypeManager.fruitTypes[index].literPerSqm = new_liters
				
				Logging.info("[%s]: Yield status updated. - Crop: ".. tostring(fruitTypeName) .." - Default Literspersqm: ".. tostring(def_liters) .." - Old Literspersqm: ".. tostring(old_liters) .." - New Literspersqm: ".. tostring(new_liters) .." - Multiplier: ".. tostring(moreYield.settings.Multiplier) .."", moreYield.name)
					
				updated = updated + 1
			end
			
		end

	end

	Logging.info("[%s]: End of crops yield updates. - Updated: ".. tostring(updated) .." - Total: ".. tostring(total) .."", moreYield.name)

end

function moreYield:saveSettings()
	Logging.info("[%s]: Trying to save settings..", moreYield.name)

	local modSettingsDir = getUserProfileAppPath() .. "modSettings"
	local fileName = "moreYield.xml"
	local createXmlFile = modSettingsDir .. "/" .. fileName

	local xmlFile = createXMLFile("moreYield", createXmlFile, "moreYield")
	
	setXMLFloat(xmlFile, "moreYield.yield#Multiplier",moreYield.settings.Multiplier)
	
	saveXMLFile(xmlFile)
	delete(xmlFile)
	
	Logging.info("[%s]: Settings have been saved.", moreYield.name)
end

function moreYield:loadSettings()
	Logging.info("[%s]: Trying to load settings..", moreYield.name)
	
	local modSettingsDir = getUserProfileAppPath() .. "modSettings"
	local fileName = "moreYield.xml"
	local fileNamePath = modSettingsDir .. "/" .. fileName
	
	if fileExists(fileNamePath) then
		Logging.info("[%s]: File founded, loading now the settings..", moreYield.name)
		
		local xmlFile = loadXMLFile("moreYield", fileNamePath)
		
		if xmlFile == 0 then
			Logging.warning("[%s]: Could not read the data from XML file, maybe the XML file is empty or corrupted, using the default!", moreYield.name)
			
			moreYield:defSettings()
			
			Logging.info("[%s]: Settings have been loaded.", moreYield.name)
			
			return
		end

		local Multiplier = getXMLFloat(xmlFile, "moreYield.yield#Multiplier")

		if Multiplier == nil or Multiplier == 0 then
			Logging.warning("[%s]: Could not parse the correct 'Multiplier' value from the XML file, maybe it is corrupted, using the default!", moreYield.name)
			
			Multiplier = 1.5
		end

		if Multiplier < 1.5 then
			Logging.warning("[%s]: Could not retrieve the correct 'Multiplier' digital number value because it is lower than '1.5' from the XML file or it is corrupted, using the default!", moreYield.name)
			
			Multiplier = 1.5
		end
		
		if Multiplier > 100 then
			Logging.warning("[%s]: Could not retrieve the correct 'Multiplier' digital number value because it is higher than '100' from the XML file or it is corrupted, using the default!", moreYield.name)
			
			Multiplier = 1.5
		end
		
		moreYield.settings.Multiplier = Multiplier
		moreYield.settings.Multiplier_OLD = Multiplier
		
		delete(xmlFile)
					
		Logging.info("[%s]: Settings have been loaded.", moreYield.name)
	else
		moreYield:defSettings()

		Logging.info("[%s]: NOT any File founded!, using the default settings.", moreYield.name)
	end
end

function moreYield:initUi()
	if not moreYield.init then
		local uiSettingsmoreYield = moreYieldUI.new(moreYield.settings,moreYield.debug)
		
		uiSettingsmoreYield:registerSettings()
		
		moreYield.init = true
	end
end

addModEventListener(moreYield)