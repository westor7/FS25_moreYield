-- Author: westor
-- Contact: westor7 @ Discord
-- Github: https://github.com/westor7/FS25_moreYield
--
-- Copyright (c) 2025 westor

moreYield = {}
moreYield.settings = {}
moreYield.name = g_currentModName or "FS25_moreYield"
moreYield.version = "1.0.2.0"
moreYield.initUI = false

function moreYield.prerequisitesPresent(specializations)
	return true
end

function moreYield:loadMap()
	if g_dedicatedServer or g_currentMission.missionDynamicInfo.isMultiplayer or not g_server or not g_currentMission:getIsServer() then
		Logging.error("[%s]: Error, Cannot use this mod because this mod is working only for singleplayer!", moreYield.name)

		return
	end
			
	Logging.info("[%s]: Initializing mod v%s (c) 2025 by westor.", moreYield.name, moreYield.version)
		
	InGameMenu.onMenuOpened = Utils.appendedFunction(InGameMenu.onMenuOpened, moreYield.initUi)
	
	FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, moreYield.saveSettings)
	
	moreYield:loadSettings()

	moreYield:Init()
	
	Logging.info("[%s]: End of mod initalization.", moreYield.name)
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
	moreYield.settings.Multiplier = 2
	moreYield.settings.OldMultiplier = 2
end

function moreYield:Init()
	local updated = 0
	local types = {
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
			"OILSEEDRADISH",
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
			"SUGARCANE",
			-- NF MARCH CUSTOM FRUITTYPES
			"SPELT",
			"RYE",
			"TRITICALE",
			"SUMMERWHEAT",
			"SUMMERBARLEY",
			"HEMP",
			"LINSEED",
			"ALFALFA",
			"BEANS",
			"PEAS"
		}

	Logging.info("[%s]: Start of crops yield updates. - Total: %s", moreYield.name, table.getn(types))

	for index, validFruit in pairs(g_fruitTypeManager.fruitTypes) do

		for _, fruitTypeName in ipairs(types) do
			local fruitType = g_fruitTypeManager:getFruitTypeByName(fruitTypeName)

			if fruitType ~= nil and fruitType == validFruit then
				local OldMultiplier = 0
				
				if moreYield.settings.OldMultiplier ~= moreYield.settings.Multiplier then OldMultiplier = moreYield.settings.OldMultiplier end
			
				local defLiters = g_fruitTypeManager.fruitTypes[index].defaultLiterPerSqm
				local oldLiters = math.abs(tonumber(string.format("%.6f", g_fruitTypeManager.fruitTypes[index].literPerSqm)))
				
				if not defLiters then
					g_fruitTypeManager.fruitTypes[index].defaultLiterPerSqm = oldLiters
					
					defLiters = oldLiters
				end
				
				local newLiters = math.abs(tonumber(string.format("%.6f", defLiters * moreYield.settings.Multiplier)))
				
				g_fruitTypeManager.fruitTypes[index].literPerSqm = newLiters
				
				Logging.info("[%s]: %s crop yield literpersqm status updated. - Default: %s - Old: %s - New: %s - Old Multiplier: %s - New Multiplier: %s", moreYield.name, fruitTypeName, defLiters, oldLiters, newLiters, OldMultiplier, moreYield.settings.Multiplier)
				
				local supportWindrow = g_fruitTypeManager.fruitTypes[index].hasWindrow
				local windrowName = g_fruitTypeManager.fruitTypes[index].windrowName
				local defwindrowLiters = g_fruitTypeManager.fruitTypes[index].defaultwindrowLiterPerSqm
				local windrowLiters = g_fruitTypeManager.fruitTypes[index].windrowLiterPerSqm
				
				if supportWindrow ~= nil and windrowLiters ~= nil then
					local oldwindrowLiters = math.abs(tonumber(string.format("%.6f", windrowLiters)))
					
					if not defwindrowLiters then 
						g_fruitTypeManager.fruitTypes[index].defaultwindrowLiterPerSqm = oldwindrowLiters
						
						defwindrowLiters = oldwindrowLiters	
					end
					
					local newwindrowLiters = math.abs(tonumber(string.format("%.6f", defwindrowLiters * moreYield.settings.Multiplier)))
					
					g_fruitTypeManager.fruitTypes[index].windrowLiterPerSqm = newwindrowLiters
				
					Logging.info("[%s]: %s crop yield windrowliterpersqm status updated. - Windrow: %s - Default: %s - Old: %s - New: %s - Old Multiplier: %s - New Multiplier: %s", moreYield.name, fruitTypeName, windrowName, defwindrowLiters, oldwindrowLiters, newwindrowLiters, OldMultiplier, moreYield.settings.Multiplier)
				end
				
				updated = updated + 1
			end
			
		end

	end

	Logging.info("[%s]: End of crops yield updates. - Updated: %s - Total: %s", moreYield.name, updated, table.getn(types))

end

function moreYield:saveSettings()
	Logging.info("[%s]: Trying to save settings..", moreYield.name)

	local xmlPath = getUserProfileAppPath() .. "modSettings" .. "/" .. "moreYield.xml"
	local xmlFile = createXMLFile("moreYield", xmlPath, "moreYield")
	
	Logging.info("[%s]: Saving settings to '%s' ..", moreYield.name, xmlPath)
	
	setXMLFloat(xmlFile, "moreYield.yield#Multiplier",moreYield.settings.Multiplier)
	
	saveXMLFile(xmlFile)
	delete(xmlFile)
	
	Logging.info("[%s]: Settings have been saved.", moreYield.name)
end

function moreYield:loadSettings()
	Logging.info("[%s]: Trying to load settings..", moreYield.name)
	
	local xmlPath = getUserProfileAppPath() .. "modSettings" .. "/" .. "moreYield.xml"
	
	Logging.info("[%s]: Loading settings from '%s' ..", moreYield.name, xmlPath)
	
	if fileExists(xmlPath) then
		Logging.info("[%s]: File founded, loading now the settings..", moreYield.name)
		
		local xmlFile = loadXMLFile("moreYield", xmlPath)
		
		if xmlFile == 0 then
			Logging.warning("[%s]: Could not read the data from XML file, maybe the XML file is empty or corrupted, using the default!", moreYield.name)
			
			moreYield:defSettings()
			
			Logging.info("[%s]: Settings have been loaded.", moreYield.name)
			
			return
		end

		local Multiplier = Utils.getNoNil( getXMLFloat(xmlFile, "moreYield.yield#Multiplier"), 2);

		if Multiplier < 1.5 then
			Logging.warning("[%s]: Could not retrieve the correct 'Multiplier' digital number value because it is lower than '1.5' from the XML file or it is corrupted, using the default!", moreYield.name)
			
			Multiplier = 2
		end
		
		if Multiplier > 100 then
			Logging.warning("[%s]: Could not retrieve the correct 'Multiplier' digital number value because it is higher than '100' from the XML file or it is corrupted, using the default!", moreYield.name)
			
			Multiplier = 2
		end
		
		moreYield.settings.Multiplier = Multiplier
		moreYield.settings.OldMultiplier = Multiplier
		
		delete(xmlFile)
					
		Logging.info("[%s]: Settings have been loaded.", moreYield.name)
	else
		moreYield:defSettings()

		Logging.info("[%s]: NOT any file founded!, using the default settings.", moreYield.name)
	end
end

function moreYield:initUi()
	if not moreYield.initUI then
		local uiSettingsmoreYield = moreYieldUI.new(moreYield.settings)
		
		uiSettingsmoreYield:registerSettings()
		
		moreYield.initUI = true
	end
end

addModEventListener(moreYield)