-- Author: westor
-- Contact: westor7 @ Discord
-- Github: https://github.com/westor7/FS25_moreYield
--
-- Copyright (c) 2025 westor

moreYield = {}
moreYield.settings = nil
moreYield.settings = moreYieldSettings.new()
local moreYieldUi = moreYieldUI.new(moreYield.settings)

moreYield.other = {
    name = "FS25_moreYield",
    author = "westor",
    version = "1.1.0.0",
    created = "03/02/2025",
    updated = "05/12/2025",
    debug = true 
	-- Set this to "true" to enable debugging messages, is "false" by default to avoid spam in log.txt file.
	-- This is recommended to enable only when there is a problem in the mod.
}

function moreYield.logInfo(infoMessage, ...)	
	if (moreYield.other.debug == true) then Logging.info(string.format("[%s]: " .. infoMessage, moreYield.other.name, ...)) end
end

function moreYield.logWarn(warningMessage, ...)
	if (moreYield.other.debug == true) then Logging.warning(string.format("[%s]: " .. warningMessage, moreYield.other.name, ...)) end
end

function moreYield.logError(errorMessage, ...)
	if (moreYield.other.debug == true) then Logging.error(string.format("[%s]: " .. errorMessage, moreYield.other.name, ...)) end
end

function moreYield:outFormat(data)
    if (type(data) == "number") then return tonumber(string.format("%.1f", data))
	elseif (type(data) == "string") then return tostring(string.format("%.1f", data))
    else return "N/A"
    end
end

function moreYield.prerequisitesPresent(specializations)
    return true
end

function moreYield:mouseEvent(posX, posY, isDown, isUp, button)
end

function moreYield:keyEvent(unicode, sym, modifier, isDown)
end

function moreYield:update(dt)
end

function moreYield:draw(dt)
end

BaseMission.loadMapFinished = Utils.prependedFunction(BaseMission.loadMapFinished, function(...)
    moreYield.logInfo("Initializing mod v%s [%s] (c) 2025 by %s.", moreYield.other.version, moreYield.other.updated, moreYield.other.author)

    moreYieldSettings:Load(moreYield.settings)
    moreYieldUi:injectUiSettings()
	
	moreYield:Init()
    
    moreYield.logInfo("End of mod initalization.")
end)

FSBaseMission.delete = Utils.appendedFunction(FSBaseMission.delete, function(...)
	if (moreYield.settings ~= nil) then
		removeModEventListener(moreYield.settings)
		
		moreYield.settings = nil
	end
end)

ItemSystem.save = Utils.appendedFunction(ItemSystem.save, function(...)
    moreYieldSettings:Save(moreYield.settings)
end)

function moreYield:Init()
    local CropUpdated = 0
    local WindrowUpdated = 0
    local fruitTypes = g_fruitTypeManager.fruitTypes
	
	if not (fruitTypes) or (fruitTypes == nil) or (fruitTypes == "") then
        moreYield.logError("There was a critical error due 'g_fruitTypeManager.fruitTypes' that was 'nil' due 'BaseMission.loadMapFinished' function!")
		
		return
	end
	
    moreYield.logInfo("Start of crops yield updates...")

	for fruitName, fruitTypeTable in pairs(fruitTypes) do       
		local CropName, CropLiters, CropDefLiters, WindrowName, WindrowSupport, WindrowLiters, WindrowDefLiters
		
		for key, value in pairs(fruitTypeTable) do
			if (type(value) ~= "table") and (type(value) ~= "function") then                   
				local item = tostring(key)
				local data = tostring(value)
			
				if (item == "name") then CropName = data end
				if (item == "literPerSqm") then CropLiters = data end
				if (item == "defaultLiterPerSqm") then CropDefLiters = data end
				if (item == "windrowName") then WindrowName = data end
				if (item == "hasWindrow") then WindrowSupport = data end
				if (item == "windrowLiterPerSqm") then WindrowLiters = data end
				if (item == "defaultwindrowLiterPerSqm") then WindrowDefLiters = data end
			end
		end
		
		if (CropName) and (CropLiters) then 
			if not (CropDefLiters) then 
				CropDefLiters = CropLiters
				
				g_fruitTypeManager.fruitTypes[fruitName].defaultLiterPerSqm = CropDefLiters
			end

			local CropNewLiters = CropDefLiters * moreYield.settings.CropMultiplier
			local CropOldLiters = CropLiters
			
			g_fruitTypeManager.fruitTypes[fruitName].literPerSqm = CropNewLiters
			
			CropUpdated = CropUpdated + 1
		
			moreYield.logInfo("%s crop yield literpersqm status updated. - Default: %s - Old: %s - New: %s - Multiplier: %s", CropName, moreYield:outFormat(CropDefLiters), moreYield:outFormat(CropOldLiters), moreYield:outFormat(CropNewLiters), moreYield:outFormat(moreYield.settings.CropMultiplier))
		end
		
		if (WindrowName) and (WindrowSupport) and (WindrowLiters) then
			if not (WindrowDefLiters) then  
				WindrowDefLiters = WindrowLiters
				
				g_fruitTypeManager.fruitTypes[fruitName].defaultwindrowLiterPerSqm = WindrowDefLiters
			end
		
			local WindrowNewLiters = WindrowDefLiters * moreYield.settings.WindrowMultiplier
			local WindrowOldLiters = WindrowLiters
			
			g_fruitTypeManager.fruitTypes[fruitName].windrowLiterPerSqm = WindrowNewLiters
			
			WindrowUpdated = WindrowUpdated + 1
			
			moreYield.logInfo("%s crop yield windrowliterpersqm status updated. - Windrow: %s - Default: %s - Old: %s - New: %s - Multiplier: %s", CropName, WindrowName, moreYield:outFormat(WindrowDefLiters), moreYield:outFormat(WindrowOldLiters), moreYield:outFormat(WindrowNewLiters), moreYield:outFormat(moreYield.settings.WindrowMultiplier))
		end

	end
	
	moreYield.logInfo("End of crops and windrow yield updates. - Crop(s) Updated: %s - Windrow(s) Updated: %s", CropUpdated, WindrowUpdated)
end

addModEventListener(moreYield)