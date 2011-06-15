local cf = imon.cf.scripts.buffcancel
if (not cf.enabled) then return end

local time_stop = GetTime()

local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function()
	if (InCombatLockdown()) then return end
	
	if (GetUnitSpeed("player") == 0) then
		
		if (not time_stop) then
			time_stop = GetTime()
		end
		
		for _,buff in pairs(cf.cancel) do
			if (UnitBuff("player", buff)) then
				if (time_stop + cf.delay <= GetTime()) then
					CancelUnitBuff("player", buff)
					time_stop = nil
				end
			end
		end
	elseif (time_stop) then
		time_stop = nil
	end
end)