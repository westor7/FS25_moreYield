-- Author: westor
-- Contact: westor7 @ Discord
-- Github: https://github.com/westor7/FS25_moreYield
--
-- Copyright (c) 2025 westor

moreYieldSettings = {}
local moreYieldSettings_mt = Class(moreYieldSettings)

function moreYieldSettings.new()
    local self = setmetatable({}, moreYieldSettings_mt)

    self.CropMultiplier = 1.5
	self.WindrowMultiplier = 1.5
	
	self:initializeMultiplayerListeners()

    return self
end

function moreYieldSettings:initializeMultiplayerListeners()
	Player.writeStream = Utils.appendedFunction(Player.writeStream, function(player, streamId, connection)
		self:onWriteStream(streamId, connection)
	end)

	Player.readStream = Utils.appendedFunction(Player.readStream, function(player, streamId, connection)
		self:onReadStream(streamId, connection)
	end)
end

function moreYieldSettings:publishNewSettings()
	if (g_server ~= nil) then
		g_server:broadcastEvent(moreYieldSettingsChangeEvent.new())
	else
		g_client:getServerConnection():sendEvent(moreYieldSettingsChangeEvent.new())
	end
end

function moreYieldSettings:onReadStream(streamId, connection)
	if streamReadBool(streamId) then
		self.CropMultiplier = streamReadFloat32(streamId)
	else
		self.CropMultiplier = 1.5
	end
	
	if streamReadBool(streamId) then
		self.WindrowMultiplier = streamReadFloat32(streamId)
	else
		self.WindrowMultiplier = 1.5
	end
end

function moreYieldSettings:onWriteStream(streamId, connection)
	if streamWriteBool(streamId, self.CropMultiplier ~= nil) then
		streamWriteFloat32(streamId, self.CropMultiplier)
	end
	if streamWriteBool(streamId, self.WindrowMultiplier ~= nil) then
		streamWriteFloat32(streamId, self.WindrowMultiplier)
	end
end

function moreYieldSettings.getXMLFilePath()
    if (g_currentMission.missionInfo) then
        local savegameDirectory = g_currentMission.missionInfo.savegameDirectory
		
        if (savegameDirectory ~= nil) then return ("%s/%s.xml"):format(savegameDirectory, moreYield.other.name) end
    end
	
    return nil
end

function moreYieldSettings.getXMLFilePathIndex()
    if (g_currentMission.missionInfo) then
        local savegameIndex = g_currentMission.missionInfo.savegameIndex

        if (savegameIndex ~= nil) then return ("%d"):format(savegameIndex) end
    end
	
    return nil
end

function moreYieldSettings:Save(settings)
	local xmlPath = moreYieldSettings.getXMLFilePath()
	local xmlPathIndex = moreYieldSettings.getXMLFilePathIndex()
	local xmlFile = createXMLFile("moreYield", xmlPath, "moreYield")
	
	setXMLFloat(xmlFile, "moreYield.data#CropMultiplier", settings.CropMultiplier)
	setXMLFloat(xmlFile, "moreYield.data#WindrowMultiplier", settings.WindrowMultiplier)
	
	saveXMLFile(xmlFile)
	delete(xmlFile)
	
	moreYield.logInfo("Saved settings to XML file. - Folder: savegame%d - File: %s", xmlPathIndex, xmlPath)
end

function moreYieldSettings:Load(settings)
	moreYield.logInfo("Trying to load XML file settings..")

	if not (g_server) then
		moreYield.logInfo("Abort loading any XML file settings due multiplayer client!")
		
		return
	end

	local xmlPath = moreYieldSettings.getXMLFilePath()
	local xmlPathIndex = moreYieldSettings.getXMLFilePathIndex()
	
	if (xmlPath) and (fileExists(xmlPath)) then
		moreYield.logInfo("File founded, loading now the settings... - Folder: savegame%d - File: %s", xmlPathIndex, xmlPath)
		
		local xmlFile = loadXMLFile("moreYield", xmlPath)
		
		if (xmlFile == 0) then
			moreYield.logWarn("Could not read the data from XML file, maybe the XML file is empty or corrupted!")

			return
		end

		local CropMultiplier = Utils.getNoNil( getXMLFloat(xmlFile, "moreYield.data#CropMultiplier"), 1.5)
		local WindrowMultiplier = Utils.getNoNil( getXMLFloat(xmlFile, "moreYield.data#WindrowMultiplier"), 1.5)

		if (CropMultiplier < 1) then
			moreYield.logWarn("Could not retrieve the correct 'CropMultiplier' value because it is lower than '1' from the XML file or it is corrupted, using the default setting instead!")
			
			CropMultiplier = 1.5
		end
		
		if (CropMultiplier > 100) then
			moreYield.logWarn("Could not retrieve the correct 'CropMultiplier' value because it is higher than '100' from the XML file or it is corrupted, using the default setting instead!")
			
			CropMultiplier = 1.5
		end
		
		if (WindrowMultiplier < 1) then
			moreYield.logWarn("Could not retrieve the correct 'WindrowMultiplier' value because it is lower than '1' from the XML file or it is corrupted, using the default setting instead!")
			
			WindrowMultiplier = 1.5
		end
		
		if (WindrowMultiplier > 100) then
			moreYield.logWarn("Could not retrieve the correct 'WindrowMultiplier' value because it is higher than '100' from the XML file or it is corrupted, using the default setting instead!")
			
			WindrowMultiplier = 1.5
		end
		
		settings.CropMultiplier = CropMultiplier
		settings.WindrowMultiplier = WindrowMultiplier
		
		delete(xmlFile)
					
		moreYield.logInfo("XML file settings have been loaded.")
	else		
		settings.CropMultiplier = 1.5
		settings.WindrowMultiplier = 1.5

		moreYield.logInfo("NOT any XML file founded!, using the default settings instead.")
	end
	
	settings:publishNewSettings()
end