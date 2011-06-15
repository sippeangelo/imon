local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_LOOT")
f:SetScript("OnEvent", function(self, event, ...)
	local message, sender, language, channelString, target, flags, unknown1, channelNumber, channelName, unknown2, counter = ...
	
	local itemID = string.match(message, "|Hitem:(%d+):.*:.*:.*:.*:.*:.*:.*|h.*|h")
	local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(itemID)
	
	if (quality == 5) then
		PlaySoundFile("Interface\\AddOns\\imon\\media\\audio\\lootwhore\\legendary.mp3", "Master")
		if (sender == nil or sender == "") then
			print("|cFFFFFF00You are legendary!|r")
		else
			print("|cFFFFFF00" .. sender .. " is now legendary!|r")
		end
	end
end)