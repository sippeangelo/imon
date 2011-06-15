local cf = imon.cf.scripts.rolecheck
if (not cf.enabled) then return end

SLASH_ROLECHECK1 = "/rolecheck"
SlashCmdList.ROLECHECK = InitiateRolePoll

local f = CreateFrame("Frame")
f:RegisterEvent("ROLE_POLL_BEGIN")
f:SetScript("OnEvent", function(self, event, ...)
	if (event == "ROLE_POLL_BEGIN") then
		local canBeTank, canBeHealer, canBeDPS = UnitGetAvailableRoles("player")
		
		if (cf.nodoubettes) then
			StaticPopupSpecial_Hide(RolePollPopup)
		elseif (cf.dpsauto) then
			if (not canBeTank and not canBeHealer and canBeDPS) then
				UnitSetRole("player", "DAMAGER")
				StaticPopupSpecial_Hide(RolePollPopup)
			end
		end
	end
end)

