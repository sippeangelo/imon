-- MOVE THIS TO unitframes/hide.lua
CompactRaidFrameManager:UnregisterAllEvents() 
CompactRaidFrameManager:Hide() 
CompactRaidFrameContainer:UnregisterAllEvents() 
CompactRaidFrameContainer:Hide()

if (not imon.cf.actionbars.enabled) then return end

-- Hide blizzard stuff
do
	local elements = {
		MainMenuBar, MainMenuBarArtFrame, BonusActionBarFrame, VehicleMenuBar,
		PossessBarFrame, PetActionBarFrame, 
		ShapeshiftBarLeft, ShapeshiftBarMiddle, ShapeshiftBarRight,
	}

	for _, element in pairs(elements) do
		if (element:GetObjectType() == "Frame") then
			element:UnregisterAllEvents()
		end
		element:Hide()
		element:SetAlpha(0)
	end
	elements = nil
end

do
	local uiManagedFrames = {
		"MultiBarLeft",
		"MultiBarRight",
		"MultiBarBottomLeft",
		"MultiBarBottomRight",
		"ShapeshiftBarFrame",
		"PossessBarFrame",
		"PETACTIONBAR_YPOS",
		"MultiCastActionBarFrame",
		"MULTICASTACTIONBAR_YPOS",
	}
	for _, frame in pairs(uiManagedFrames) do
		UIPARENT_MANAGED_FRAME_POSITIONS[frame] = nil
	end
	uiManagedFrames = nil
end

