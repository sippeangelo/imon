local oUF = imonoUF
local cf = imon.cf

local timers = {
	offline = {},
	afk = {},
	dead = {},
}

function FormatDuration(number)
	if number >= 60*60 then
		return ("%d:%02d:%02d"):format(number/3600, number/60 % 60, number % 60)
	else
		return ("%d:%02d"):format(number/60 % 60, number % 60)
	end
end

local function ShortenValue(value)
	if(value >= 1e6) then
		return ('%.2fm'):format(value / 1e6):gsub('%.?0+([km])$', '%1')
	elseif(value >= 1e4) then
		return ('%.1fk'):format(value / 1e3):gsub('%.?0+([km])$', '%1')
	else
		return value
	end
end

local function DifficultyColor(unit)
	local level = UnitLevel(unit)
	
	if (level <= 0) then
		return {r = 255, g = 0, b = 0}
	end
	
	local dc = GetQuestDifficultyColor(level)
	-- dc seems to act like a pointer...
	local dr, dg, db = dc.r * 255, dc.g * 255, dc.b * 255
	
	return {r = dr, g = dg, b = db}
end

local function ClassColor(unit)
	local cr, cg, cb = 1, 1, 1
	
	local _, class = UnitClassBase(unit)
	local c = oUF.colors.class[class]
	
	if (c) then
		cr, cg, cb = c[1], c[2], c[3]
	end
	
	return {r = cr * 255, g = cg * 255, b = cb * 255}
end

local function SmartRace(unit)
	if (UnitIsPlayer(unit)) then
		local race = UnitRace(unit)
		return race or UNKNOWN
	else
		return UnitCreatureFamily(unit) or UnitCreatureType(unit) or UNKNOWN
	end
end

local function Status(unit)
	local guid = UnitGUID(unit)

	if (not UnitIsConnected(unit)) then
		if (timers.offline[guid] == nil) then
			timers.offline[guid] = GetTime()
		end
		return ("Offline (%s)"):format(FormatDuration(GetTime() - timers.offline[guid]))
	elseif (timers.offline[guid]) then
		timers.offline[guid] = nil
	end
	
	if (UnitIsFeignDeath(unit)) then
		return "Feign Death"
	end
	
	if (UnitIsDeadOrGhost(unit)) then
		if (timers.dead[guid] == nil) then
			timers.dead[guid] = GetTime()
		end
		
		if (UnitIsDeadOrGhost(unit)) then
			--return ("Dead (%s)"):format(FormatDuration(GetTime() - timers.dead[guid]))
			return "Dead"
		elseif (UnitIsGhost(unit)) then
			--return ("Ghost (%s)"):format(FormatDuration(GetTime() - timers.dead[guid]))
			return "Ghost"
		end
	elseif (timers.dead[guid]) then
		timers.dead[guid] = nil
	end
end

oUF.Tags["imon:status"] = function(unit)
	return Status(unit)
end

oUF.TagEvents["imon:missingbuffs"] = "UNIT_AURA"
oUF.Tags["imon:missingbuffs"] = function(unit)
	local class = select(2, UnitClass("player"))
	local unitclass = select(2, UnitClass(unit))
	
	if (UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) or not UnitIsVisible(unit)) then
		return ""
	end
	
	if (class == "DRUID" and not UnitAura(unit, "Mark of the Wild")) then
		return "MotW"
	end
	
	if (class == "MAGE") then
		if (UnitAura(unit, "Dalaran Brilliance") or UnitAura(unit, "Arcane Brilliance")) then
			return 
		else
			return "AB"
		end
	end
	
	if (class == "PRIEST" and not UnitAura(unit, "Power Word: Fortitude") and not UnitAura(unit, "Blood Pact")) then
		return "PW:F"
	end
	
	if (class == "PALADIN") then
		if (not UnitAura(unit, "Blessing of Kings") and not UnitAura(unit, "Mark of the Wild")) then
			return "BoK"
		elseif (not UnitAura(unit, "Blessing of Might") and select(8, UnitAura(unit, "Blessing of Kings")) ~= "player") then
			return "BoM"
		end
	end
	
	if (class == "WARLOCK") then
		if (not UnitAura("player", "Dark Intent")) then
			if (unitclass == "MAGE" or unitclass == "DRUID" or unitclass == "PRIEST" or unitclass == "HUNTER") then
				return "DI"
			end
		end
	end
end

oUF.TagEvents["imon:name"] = "UNIT_NAME_UPDATE PLAYER_FLAGS_CHANGED"
oUF.Tags["imon:name"] = function(unit)
	local afk = UnitIsAFK(unit)
	local guid = UnitGUID(unit)
	local name = UnitName(unit)
	
	local override = cf["unitframes"]["health"]["name_overrides"][name]
	if (override) then
		name = override 
	end
	
	--[[if (afk) then
		if (timers.afk[guid] == nil) then
			timers.afk[guid] = GetTime()
		end
	elseif (timers.afk[guid]) then
		timers.afk[guid] = nil
	end]]--
	
	if (afk) then
		--return ("%s <Away %s>"):format(name, FormatDuration(GetTime() - timers.afk[guid] + 5 * 60))
		return ("%s <Away>"):format(name)
	else
		return name
	end
end

oUF.TagEvents["imon:health"] = "UNIT_HEALTH UNIT_MAXHEALTH"
oUF.Tags["imon:health"] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	
	if (max > 0) then
		if (min ~= max) then
			return ("%d%% (%s/%s)"):format(min / max * 100, ShortenValue(min), ShortenValue(max))
		else
			return max
		end
	end
end

oUF.TagEvents["imon:group:health"] = "UNIT_HEALTH UNIT_MAXHEALTH"
oUF.Tags["imon:group:health"] = function(unit)
	local status = Status(unit)
	if (status) then
		return status
	end

	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	
	if (max > 0) then
		--[[if (min ~= max) then
			return ("%d%% (%s/%s)"):format(min / max * 100, ShortenValue(min), ShortenValue(max))
		else
			return max
		end]]--
		
			
		-- Color based on percentage of max health
		local pp = min / max
		local col = 255 * pp
		
		if (min ~= max) then
			return ("|cffff%02x%02x%d|r"):format(col, col, min - max)
		end
		
		if (min == max and UnitAura(unit, "Power Word: Shield") or UnitAura(unit, "Divine Aegis")) then
			return "|cff00FF00+|r"
		end
	end
end

oUF.TagEvents["imon:health-percent"] = "UNIT_HEALTH UNIT_MAXHEALTH"
oUF.Tags["imon:health-percent"] = function(unit)
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	
	if (max > 0) then
		return ("%d%%"):format(min / max * 100)
	end
end

oUF.TagEvents["imon:power"] = "UNIT_POWER UNIT_MAXPOWER"
oUF.Tags["imon:power"] = function(unit)
	local min, max, type = UnitPower(unit), UnitPowerMax(unit), select(1, UnitPowerType(unit))
	
	if (max > 0) then
		if (min ~= max) then
			-- Percentages for anything but mana is just annoying
			if (type == 0) then
				return ("%d%% (%d/%d)"):format(min / max * 100, min, max)
			else
				return ("%d/%d"):format(min, max)
			end
		else
			return max
		end
	end
end

oUF.TagEvents["imon:altpower"] = "UNIT_POWER UNIT_MAXPOWER"
oUF.Tags["imon:altpower"] = function(unit)
	local _, min = UnitAlternatePowerInfo(unit)
	local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
	local max = UnitPowerMax(unit, ALTERNATE_POWER_INDEX)
	
	return ("%d/%d"):format(cur, max)
end

oUF.TagEvents["imon:info"] = "UNIT_LEVEL UNIT_CLASSIFICATION_CHANGED"
oUF.Tags["imon:info"] = function(unit)
	local class
	if (UnitIsPlayer(unit)) then
		class = UnitClass(unit)
	end
	
	local race = SmartRace(unit)
	
	local classification = UnitClassification(unit)
	local level = UnitLevel(unit)
	if (level <= 0) then
		level = "??"
	end
	if (classification == "worldboss") then
		level = "B"
	end
	if (classification == "rare") then
		level = level .. "R"
	end
	if (classification == "elite") then
		level = level .. "+"
	end
	if (classification == "rareelite") then
		level = level .. "R+"
	end
	
	local dc = DifficultyColor(unit)
	local cc = ClassColor(unit)
	
	return ("|cff%02x%02x%02x%s|r %s |cff%02x%02x%02x%s|r"):format(dc.r, dc.g, dc.b, level, race or "", cc.r, cc.g, cc.b, class or "")
end

oUF.TagEvents["imon:specialpower"] = "UNIT_POWER"
oUF.Tags["imon:specialpower"] = function(unit)
	local class = select(2, UnitClass(unit))
	
	if (class == "WARLOCK") then
		local power = UnitPower(unit, SPELL_POWER_SOUL_SHARDS)
		
		local text = "shards"
		if (power == 1) then
			text = "shard"
		end
		
		return ("%d %s"):format(power, text)	
	end
	
	if (class == "PALADIN") then
		local power = UnitPower(unit, SPELL_POWER_HOLY_POWER)
		return ("%d power"):format(power, text)
	end
	
end

oUF.TagEvents["imon:xp"] = "PLAYER_XP_UPDATE PLAYER_LEVEL_UP UNIT_PET_EXPERIENCE UPDATE_EXHAUSTION"
oUF.Tags["imon:xp"] = function(unit)
	local min, max
	if (unit == "pet") then
		min, max = GetPetExperience()
	else
		min, max = UnitXP(unit), UnitXPMax(unit)
	end

	local exhaustion = unit == "player" and GetXPExhaustion() or 0			

	local perxp = math.floor(min / max * 100 + 0.5)
	--local perxp_remaining = math.floor((max - min) / max * 100 + 0.5)
	local perxp_rested = math.floor(exhaustion / max * 100 + 0.5)
	
	if (exhaustion > 0) then
		if (perxp_rested < 1) then
			perxp_rested = exhaustion
		else
			perxp_rested = perxp_rested .. "%"
		end
		return ("%d%% |cff00ff00+%s|r"):format(perxp, perxp_rested)
	else
		return ("%d%%"):format(perxp)
	end
end
