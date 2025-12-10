-- Author: westor
-- Contact: westor7 @ Discord
-- Github: https://github.com/westor7/FS25_moreYield
--
-- Copyright (c) 2025 westor

moreYieldSettingsChangeEvent = {}
local moreYieldSettingsChangeEvent_mt = Class(moreYieldSettingsChangeEvent, Event)

InitEventClass(moreYieldSettingsChangeEvent, "moreYieldSettingsChangeEvent")

function moreYieldSettingsChangeEvent.emptyNew()
	return Event.new(moreYieldSettingsChangeEvent_mt)
end

function moreYieldSettingsChangeEvent.new()
	local self = moreYieldSettingsChangeEvent.emptyNew()
	return self
end

function moreYieldSettingsChangeEvent:readStream(streamId, connection)
	moreYield.settings:onReadStream(streamId, connection)

	local eventWasSentByServer = connection:getIsServer()
	if not (eventWasSentByServer) then 
		g_server:broadcastEvent(moreYieldSettingsChangeEvent.new(moreYield.settings), nil, connection, nil)
	end
end

function moreYieldSettingsChangeEvent:writeStream(streamId, connection)
	moreYield.settings:onWriteStream(streamId, connection)
end