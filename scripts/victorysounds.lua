if (not DBM) then return end
local cf = imon.cf.scripts.victorysounds
if (not cf.enabled) then return end

DBM.EndCombat_Original = DBM.EndCombat

function DBM:EndCombat(mod, wipe)
	StopMusic()
	
	if (wipe and cf.wipe.enabled and table.getn(cf.wipe.sounds) > 0) then
		PlaySoundFile("Interface\\AddOns\\imon\\media\\audio\\victorysounds\\wipe\\" .. cf.wipe.sounds[random(1, table.getn(cf.wipe.sounds))], "Master")
	elseif (cf.victory.enabled and table.getn(cf.victory.sounds) > 0) then
		PlaySoundFile("Interface\\AddOns\\imon\\media\\audio\\victorysounds\\victory\\" .. cf.victory.sounds[random(1, table.getn(cf.victory.sounds))], "Master")
	end
	
	DBM:EndCombat_Original(mod, wipe)
end