local cf = imon.cf.scripts.readycheck
if (not cf.enabled) then return end

local f = CreateFrame("Frame")
f:RegisterEvent("READY_CHECK")
f:SetScript("OnEvent", function(self, event, ...)
	if (event == "READY_CHECK") then
		if (InCombatLockdown() and cf.combatautodecline) then
			ConfirmReadyCheck(false)
		elseif (cf.autoaccept) then
			ConfirmReadyCheck(true)
		elseif (cf.randompos) then
			-- Random X & Y on the screen
			local x = math.random(0, GetScreenWidth())
			local y = math.random(0, GetScreenHeight())
			
			local anchor
			if (x < GetScreenWidth() / 2) then
				if (y < GetScreenHeight() / 2) then
					anchor = "TOPLEFT"
				else
					anchor = "BOTTOMLEFT"
				end
			else
				if (y < GetScreenHeight() / 2) then
					anchor = "TOPRIGHT"
				else
					anchor = "BOTTOMRIGHT"
				end		
			end

			ReadyCheckFrame:ClearAllPoints()
			ReadyCheckFrame:SetPoint(anchor, UIParent, "TOPLEFT", x, -y)
		end
	end
end)