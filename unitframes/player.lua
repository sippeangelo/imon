local oUF = imonoUF
local cf = imon.cf
local LSM = LibStub:GetLibrary("LibSharedMedia-3.0")

-- Register textures
LSM:Register(LSM.MediaType.STATUSBAR, "Minimalist", [[Interface\Addons\imon\media\statusbar\Minimalist]])

-- Texture of most bars 
local BAR_TEXTURE = LSM:Fetch("statusbar", "Minimalist")
local BAR_WIDTH = cf.unitframes.width
local HEALTH_HEIGHT = cf.unitframes.health.height
local POWER_HEIGHT = cf.unitframes.power.height
local CASTBAR_HEIGHT = cf.unitframes.castbar.height

local GLOW_TEXTURE = [[Interface\Addons\imon\media\glowTex]]

local XP_COLOR = {0, 0.4, 1, 1}

local unit_lowesthp = {}

local font = CreateFont("imon_text")
font:SetFont(LSM:Fetch("font", "Arial Narrow"), 14)
font:SetShadowColor(0, 0, 0, 1)
font:SetShadowOffset(1, -1)	

-- Healprediction time test
local f = CreateFrame("Frame", "imon_Actionbars", UIParent)
local casttime = f:CreateFontString(nil, "OVERLAY", "imon_text")
casttime:SetPoint("LEFT", UIParent, "LEFT", 4, 0)
f.Time = casttime

f:RegisterEvent("UNIT_SPELLCAST_START")
f:RegisterEvent("UNIT_TARGET")
f:SetScript("OnEvent", function(self, event, ...)
	if (event == "UNIT_SPELLCAST_START") then
		local unitid, spell, rank = ...
		local name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unitid)
		
		local text = UnitName(unitid) .. " casting " .. spell .. " (" .. endTime - startTime .. ")"
		local target = UnitName(unitid .. "target")
		if (target) then
			text = text .. " on " .. target
		end
		--print(text)

		--self.Time:SetText(name .. ": " .. endTime - startTime)
	end
	
	if (event == "UNIT_TARGET") then
		local unit = ...
		--print(unit .. " target change")
	end
end)

local BAR_BACKDROP = {
	bgFile = GLOW_TEXTURE, edgeSize = 3,
	insets = {top = 0, left = -5, bottom = 0, right = -5},
}

imon.oUF.UpdatePowerStatus = function(self)
	local lastElement = {"TOPLEFT", self.Power, "TOPLEFT"}
	local icons = {
		"Combat",
		"Resting",
		"PvP",
	}
	
	-- Combat icon
	--[[local combat = powBar:CreateTexture(nil, "OVERLAY")
	combat:SetSize(POWER_HEIGHT, POWER_HEIGHT)
	combat:SetPoint("TOPLEFT", powBar, "TOPLEFT", 0, 0)
	self.Combat = combat
	
	local pvp = powBar:CreateTexture(nil, "OVERLAY")
	pvp:SetSize(35, 35)
	pvp:SetPoint("TOPLEFT", combat, "TOPRIGHT", 0, 0)
	self.PvP = pvp]]--
	
	for k,v in pairs(icons) do
		local e = self[v]
		if (e and e:IsVisible()) then
			e:SetPoint(unpack(lastElement))
			lastElement = {"TOPLEFT", e, "TOPRIGHT"}
		end
	end	
end

-- Unit menu
imon.oUF.menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)
	
	-- Swap menus in vehicle
	if self == oUF_player and cunit=="Vehicle" then cunit = "Player" end
	if self == oUF_pet and cunit=="Player" then cunit = "Pet" end

	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

-- Shared unit frame styles
imon.oUF.Shared = function(self, unit)
	BAR_WIDTH = cf.unitframes.width
	HEALTH_HEIGHT = cf.unitframes.health.height
	POWER_HEIGHT = cf.unitframes.power.height
	CASTBAR_HEIGHT = cf.unitframes.castbar.height

	if (unit == "pet") then
		BAR_WIDTH = cf.unitframes.width / 2
		HEALTH_HEIGHT = cf.unitframes.health.height / 2
		POWER_HEIGHT = cf.unitframes.power.height / 2
		CASTBAR_HEIGHT = cf.unitframes.castbar.height / 2
	end
	
	if (unit == "focus" or unit == "targettarget") then
		HEALTH_HEIGHT = cf.unitframes.health.height * 2/3
		POWER_HEIGHT = cf.unitframes.power.height * 2/3
		CASTBAR_HEIGHT = cf.unitframes.castbar.height * 2/3	
	end
	
	if (unit == "focus") then
		local difference = POWER_HEIGHT - CASTBAR_HEIGHT
		CASTBAR_HEIGHT = HEALTH_HEIGHT + POWER_HEIGHT - 3 * 2
	end

	self.colors.power["MANA"] = { 68/255, 138/255, 231/255 }
	self.menu = imon.oUF.menu
	self:RegisterForClicks("AnyDown")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:SetSize(BAR_WIDTH, HEALTH_HEIGHT + POWER_HEIGHT)

	-------------------------------------------
	-- HEALTH
	-------------------------------------------
	-- Container
	local Health = CreateFrame("Frame", nil, self)
	Health:SetSize(BAR_WIDTH, HEALTH_HEIGHT)
	Health:SetPoint("TOP", self, "TOP", 0, 0)
	
		-- Bar
		local bar = CreateFrame("StatusBar", nil, Health)
		bar:SetStatusBarTexture(BAR_TEXTURE)
		bar:SetAllPoints()
		--bar:SetPoint("TOP", Health, "TOP", 0, 0)
		--bar:SetSize(BAR_WIDTH, HEALTH_HEIGHT)
		bar.frequentUpdates = true
		bar.colorTapped = true
		bar.colorClass = true
		bar.colorReaction = true
		bar.colorDisconnected = true
		
		-- Min HP marker
		if (unit == "target" and cf.unitframes.health.minhp) then
			-- Thingy
			local thingy_b = CreateFrame("Frame", nil, Health)
			thingy_b:SetSize(BAR_WIDTH, HEALTH_HEIGHT)
			thingy_b.width = thingy_b:GetWidth()
			thingy_b:SetPoint("LEFT", Health, "LEFT")
			
			local thingy = bar:CreateTexture(nil, "OVERLAY")
			thingy:SetHeight(Health:GetHeight())
			thingy:SetWidth(4)
			thingy:SetPoint("CENTER", thingy_b, "RIGHT")
			thingy:SetTexture(BAR_TEXTURE)
			thingy:SetVertexColor(1, 0, 0, 0.8)
			thingy:Hide()
			
			thingy_b:SetScript("OnUpdate", function(self)
				-- Since GUIDs might change, filter by unit name
				-- This is only mainly for raid bosses anyway
				local guid = UnitName(unit)
				
				if (not unit_lowesthp[guid]) then
					unit_lowesthp[guid] = {}
					unit_lowesthp[guid]["lowest"] = UnitHealth(unit)
					unit_lowesthp[guid]["time"] = time()
				end
				
				if (UnitHealth(unit) < unit_lowesthp[guid]["lowest"]) then
					unit_lowesthp[guid]["lowest"] = UnitHealth(unit)
					unit_lowesthp[guid]["time"] = time()
				end
				
				if (unit_lowesthp[guid]["lowest"] < UnitHealthMax(unit) and UnitHealth(unit) > 0) then
					thingy:Show()
				else
					thingy:Hide()
				end
			
				local percent = unit_lowesthp[guid]["lowest"] / UnitHealthMax(unit) 
				self:SetWidth(thingy_b.width * percent)
			end)			
			
			local thingy_frame = CreateFrame("Frame", nil, Health)
			thingy_frame:SetAllPoints(thingy)
			
			-- Mouseover show and tooltip
			thingy_frame:SetScript("OnEnter", function(self)
				local guid = UnitName(unit)
				
				if (unit_lowesthp[guid]) then
					GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)

					GameTooltip:AddLine("Lowest HP: " .. math.floor(unit_lowesthp[guid]["lowest"] / UnitHealthMax(unit) * 100 + 0.5) .. "%")
					local at = date("%H:%M:%S", unit_lowesthp[guid]["time"])
					GameTooltip:AddLine("At " .. at)

					GameTooltip:Show()
				end
			end)
			thingy_frame:SetScript("OnLeave", function(self) 	
				GameTooltip_Hide()
			end)
		end

			
		-- Background
		local background = bar:CreateTexture(nil, "BORDER")
		background:SetAllPoints()
		background:SetTexture(BAR_TEXTURE)
		bar.bg = background
		bar.bg.multiplier = 0.4
		
		-- Name text
		local name = bar:CreateFontString(nil, "OVERLAY")
		name:SetFontObject("imon_text")
		name:SetJustifyH("LEFT")
		name:SetPoint("LEFT", bar, "LEFT", 4, 0)
		name.frequentUpdates = 0.1
		self:Tag(name, "[imon:name]")
		
		-- Health text
		local text = bar:CreateFontString(nil, "OVERLAY")
		text:SetFontObject("imon_text")
		text:SetJustifyH("RIGHT")
		text:SetPoint("RIGHT", bar, "RIGHT", -4, 0)
		text.frequentUpdates = true
		self:Tag(text, "[imon:health]")
		
	self.Health = bar
	
	-------------------------------------------
	-- QUICK MARK
	-------------------------------------------
	if (unit == "target" or unit == "player") then
		-- Container
		local Quickmark = CreateFrame("Frame", nil, self)
		Quickmark:SetSize(BAR_WIDTH, HEALTH_HEIGHT)
		Quickmark:SetPoint("TOPLEFT", Health, "TOPLEFT")
		Quickmark:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT")
		Quickmark:SetFrameLevel(Health:GetFrameLevel() + 5)
		Quickmark:Hide()
		
		--[[
		Quickmark:SetScript("OnEnter", function(self) 
			self:SetAlpha(1)
		end)
		Quickmark:SetScript("OnLeave", function(self) 
			self:SetAlpha(0)
		end)
		]]--
		
		Quickmark:SetScript("OnMouseUp", function(self, button)
			if (button == "RightButton") then
				SetRaidTarget(unit, 0)
			end
			
			self:Hide()
		end)
		
			-- Background
			local background = Quickmark:CreateTexture(nil, "BORDER")
			background:SetAllPoints()
			background:SetTexture(0, 0, 0, 0.5)
			
			local piece = BAR_WIDTH / 8
			
			local RaidIcons = {}
			
			for i=1,8 do
				local iconframe = CreateFrame("Frame", nil, Quickmark)
				iconframe:SetSize(32, 32)
				iconframe:SetPoint("CENTER", Quickmark, "LEFT", (piece / 2) * (i-1) + (piece / 2) * i, 0)
					local icon = iconframe:CreateTexture(nil, "OVERLAY")
					icon:SetAllPoints()
					icon:SetTexture[[Interface\TargetingFrame\UI-RaidTargetingIcons]]
					SetRaidTargetIconTexture(icon, 9-i)
				
				iconframe:SetScript("OnMouseUp", function(self, button)
					if (button == "LeftButton") then
						SetRaidTarget(unit, 9-i)
					elseif (button == "RightButton") then
						SetRaidTarget(unit, 0)
					end
					
					Quickmark:Hide()
				end)
				iconframe:SetScript("OnEnter", function(self) 
					--Quickmark:SetAlpha(1)
					self:SetSize(36, 36)
				end)
				iconframe:SetScript("OnLeave", function(self) 
					--Quickmark:SetAlpha(0)
					self:SetSize(32, 32)
				end)
			end
			
		self.Quickmark = Quickmark
	end	
	
	-------------------------------------------
	-- RAID MARKERS
	-------------------------------------------
	if (unit == "player" or unit == "target") then
		-- Container
		local RaidMarkers = CreateFrame("Frame", nil, self)
		RaidMarkers:SetSize(32, 32)
		RaidMarkers:SetPoint("CENTER", Health, "CENTER", 0, 0)
		RaidMarkers:SetFrameLevel(Health:GetFrameLevel() + 1)
		
		self:SetScript("OnMouseUp", function(self, button)
			if (button == "MiddleButton") then
				self.Quickmark:Show()
			end
		end)

			local icon = RaidMarkers:CreateTexture(nil, "OVERLAY")
			icon:SetAllPoints()
			
		self.RaidIcon = icon
	end

	
	-------------------------------------------
	-- SOUL SHARDS
	-------------------------------------------
	--[[
	if (unit == "player") then
		-- Container
		local SoulShards = CreateFrame("Frame", nil, self)
		SoulShards:SetSize(BAR_WIDTH, 5)
		SoulShards:SetPoint("BOTTOM", Health, "BOTTOM", 0, 0)
		SoulShards:SetFrameLevel(Health:GetFrameLevel() + 2)
		
		self.SoulShards = SoulShards
		
		self.SoulShards[1] = SoulShards:CreateTexture(nil, "BORDER")
		self.SoulShards[1]:SetSize(BAR_WIDTH / 3, 5)
		self.SoulShards[1]:SetPoint("LEFT", SoulShards, "LEFT")
		self.SoulShards[1]:SetTexture(BAR_TEXTURE)
		
		self.SoulShards[2] = SoulShards:CreateTexture(nil, "BORDER")
		self.SoulShards[2]:SetSize(BAR_WIDTH / 3, 5)
		self.SoulShards[2]:SetPoint("LEFT", self.SoulShards[1], "RIGHT")
		self.SoulShards[2]:SetTexture(BAR_TEXTURE)

		self.SoulShards[3] = SoulShards:CreateTexture(nil, "BORDER")
		self.SoulShards[3]:SetSize(BAR_WIDTH / 3, 5)
		self.SoulShards[3]:SetPoint("LEFT", self.SoulShards[2], "RIGHT")
		self.SoulShards[3]:SetTexture(BAR_TEXTURE)
	end
	]]--
	
	-------------------------------------------
	-- COMBO POINTS
	-------------------------------------------
	-- Container
	local ComboPoints = CreateFrame("Frame", nil, self)
	ComboPoints:SetSize(BAR_WIDTH, 5)
	ComboPoints:SetPoint("BOTTOM", Health, "BOTTOM", 0, 0)
	ComboPoints:SetFrameLevel(Health:GetFrameLevel() + 1)
	ComboPoints:Hide()
	
	ComboPoints.unit = unit

	ComboPoints:RegisterEvent("UNIT_COMBO_POINTS")
	ComboPoints:RegisterEvent("PLAYER_TARGET_CHANGED")
	ComboPoints:RegisterEvent("PLAYER_REGEN_ENABLED")
	
	ComboPoints:SetScript("OnEvent", function(self, event, ...)
		if (event == "UNIT_COMBO_POINTS" or event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_REGEN_ENABLED") then
			local combopoints = GetComboPoints("player", "target")
			
			-- Only update combopoints on the player frame when
			-- they change, so you can see combo points on last
			-- target when switching targets.
			if (self.unit == "player") then
				if (event == "UNIT_COMBO_POINTS") then
					self.bar:SetValue(combopoints)
				end
			else
				self.bar:SetValue(combopoints)
			end
			
			if (combopoints > 0 and not self:IsVisible()) then
				self:Show()
			elseif (self:IsVisible() and not InCombatLockdown()) then
				self:Hide()
			end
			
			for i=1,4 do
				if (i < self.bar:GetValue()) then
					self.barmarkers[i]:SetVertexColor(0, 0, 0)
				else
					self.barmarkers[i]:SetVertexColor(1, 1, 1)
				end
			end
		end
	end)
	
	local bar = CreateFrame("StatusBar", nil, ComboPoints)
	bar:SetStatusBarTexture(BAR_TEXTURE)
	bar:SetAllPoints()
	bar:SetMinMaxValues(0, 5)
	bar:SetStatusBarColor(1, 1, 1)
	ComboPoints.bar = bar	

	-- Background
	local background = bar:CreateTexture(nil, "BORDER")
	background:SetAllPoints()
	background:SetTexture(BAR_TEXTURE)
	background:SetVertexColor(1 * 0.4, 0, 0)

	local barmarkers = {}
	for i=1,4 do
		barmarkers[i] = bar:CreateTexture(nil, "OVERLAY")
		--barmarker:SetAllPoints()
		barmarkers[i]:SetSize(1, 5)
		barmarkers[i]:SetPoint("TOPLEFT", bar, "TOPLEFT", BAR_WIDTH / 5 * i, 0)
		barmarkers[i]:SetTexture(BAR_TEXTURE)
		barmarkers[i]:SetVertexColor(1, 1, 1)
	end
	ComboPoints.barmarkers = barmarkers
	
	-------------------------------------------
	-- POWER
	-------------------------------------------
	-- Container
	local Power = CreateFrame("Frame", nil, self)
	Power:SetSize(BAR_WIDTH, POWER_HEIGHT)
	Power:SetPoint("TOP", Health, "BOTTOM", 0, 0)
		
		-- Bar
		local bar = CreateFrame("StatusBar", nil, Power)
		bar:SetStatusBarTexture(BAR_TEXTURE)
		--bar:SetBackdropColor(0, 0, 0, 0.9)
		bar:SetAllPoints()
		bar.frequentUpdates = true
		bar.colorPower = true
		bar.colorDisconnected = true
		
		-- Background
		local background = bar:CreateTexture(nil, "BORDER")
		background:SetAllPoints()
		background:SetTexture(BAR_TEXTURE)
		bar.bg = background
		bar.bg.multiplier = 0.4
		
		-- Power text
		local text = bar:CreateFontString(nil, "OVERLAY")
		text:SetFontObject("imon_text")
		--text:SetJustifyH("RIGHT")
		text:SetPoint("RIGHT", bar, "RIGHT", -4, 0)
		text.frequentUpdates = 0.1
		self:Tag(text, "[imon:power]")	
	
		-- Info text
		if (unit == "target") then
			local info = bar:CreateFontString(nil, "Overlay")
			info:SetFontObject("imon_text")
			info:SetPoint("LEFT", bar, "LEFT", 4, 0)
			self:Tag(info, "[imon:info]")
		elseif (unit == "player") then
			local info = bar:CreateFontString(nil, "Overlay")
			info:SetFontObject("imon_text")
			info:SetPoint("LEFT", bar, "LEFT", 4, 0)
			self:Tag(info, "[imon:specialpower]")		
		end
		
	self.Power = bar	
	
	-- XP bar on mouseover
	if ((unit == "player" and UnitLevel("player") ~= MAX_PLAYER_LEVEL) or (unit == "pet" and UnitLevel(unit) == UnitLevel("player"))) then
		-- Container
		local XP = CreateFrame("Frame", nil, self)
		XP:SetSize(BAR_WIDTH, POWER_HEIGHT)
		XP:SetPoint("TOP", Health, "BOTTOM", 0, 0)
		
		-- Bar
		local bar = CreateFrame("StatusBar", nil, XP)
		bar:SetStatusBarTexture(BAR_TEXTURE)
		bar:SetAllPoints()
		bar:SetFrameLevel(self.Power:GetFrameLevel() + 2)
		bar:SetStatusBarColor(unpack(XP_COLOR))
		bar:SetAlpha(0)
		
		-- Mouseover show and tooltip
		bar:SetScript("OnEnter", function(self) 
			self:SetAlpha(1) 
			
			local unit = self:GetParent():GetParent().unit
			
			local min, max
			
			if (unit == "pet") then
				min, max = GetPetExperience()
			else
				min, max = UnitXP(unit), UnitXPMax(unit)
			end
			
			local exhaustion = unit == "player" and GetXPExhaustion() or 0			
			
			local perxp = math.floor(min / max * 100 + 0.5)
			local perxp_remaining = math.floor((max - min) / max * 100 + 0.5)
			local perxp_rested = math.floor(exhaustion / max * 100 + 0.5)

			local bars = unit == "pet" and 6 or 20

			GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 5)
			--GameTooltip:AddLine(string.format('XP: %d / %d (%d%% - %d bars)', min, max, min/max * 100, bars))
			--GameTooltip:AddLine(string.format('Remaining: %d (%d%% - %d bars)', max - min, (max - min) / max * 100, bars * (max - min) / max))
			
			GameTooltip:AddLine(format("XP: %d / %d (%d%% - %d bars)", min, max, perxp, floor(bars * (min/max))))
			if (exhaustion > 0) then
				GameTooltip:AddLine(format("Rested: %d (%d%% - %d bars)", exhaustion, perxp_rested, floor(bars * (exhaustion / max))))
			end
			GameTooltip:AddLine(format("Remaining: %d (%d%% - %d bars)", max - min, perxp_remaining, ceil(bars * (max - min) / max)))

			if(self.rested) then
				GameTooltip:AddLine(string.format('|cff0090ffRested: +%d (%d%%)', self.rested, self.rested / max * 100))
			end

			GameTooltip:Show()				
		end)
		bar:SetScript("OnLeave", function(self) 
			self:SetAlpha(0) 
			GameTooltip_Hide()
		end)
		
		bar.Rested = CreateFrame("StatusBar", nil, bar)
		bar.Rested:SetAllPoints()
		bar.Rested:SetStatusBarTexture(BAR_TEXTURE)
		bar.Rested:SetStatusBarColor(XP_COLOR[1] * 1.5, XP_COLOR[2] * 1.5, XP_COLOR[3] * 1.5, XP_COLOR[4])

		local val = bar:CreateFontString(nil, "OVERLAY")
		val:SetAllPoints()
		val:SetFontObject("imon_text")
		self:Tag(val, "[imon:xp]")				
		
		local background = bar.Rested:CreateTexture(nil, "BACKGROUND")
		background:SetAllPoints()
		background:SetTexture(BAR_TEXTURE)
		background:SetVertexColor(XP_COLOR[1] * 0.4, XP_COLOR[2] * 0.4, XP_COLOR[3] * 0.4, XP_COLOR[4])

		-- Show where the "bars" of the normal xp bar would be
		for i=1,19 do
			local barmarker = bar:CreateTexture(nil, "OVERLAY")
			--barmarker:SetAllPoints()
			barmarker:SetSize(1, POWER_HEIGHT)
			barmarker:SetPoint("TOPLEFT", bar, "TOPLEFT", BAR_WIDTH / 20 * i, 0)
			barmarker:SetTexture(BAR_TEXTURE)
			local alpha = 0.1
			if (i % 5 == 0) then
				alpha = 0.4
			end
			barmarker:SetVertexColor(1, 1, 1, alpha)
		end
		
		self.Experience = bar
	end
	
	-------------------------------------------
	-- CASTBAR
	-------------------------------------------	
	-- Container
	local Castbar = CreateFrame("Frame", nil, self)
	Castbar:SetSize(BAR_WIDTH, CASTBAR_HEIGHT)
	if (unit == "focus") then
		Castbar:SetPoint("BOTTOM", Power, "BOTTOM", 0, 3)
	else
		Castbar:SetPoint("BOTTOM", Power, "BOTTOM", 0, 0)
	end
	Castbar:SetFrameLevel(Power:GetFrameLevel() + 1)
	
		-- Bar
		local bar = CreateFrame("StatusBar", nil, Castbar)
		bar:SetHeight(CASTBAR_HEIGHT)
		bar:SetStatusBarTexture(BAR_TEXTURE)
		
			-- Spell icon
			local icon = bar:CreateTexture(nil, "OVERLAY", nil, 7)
			icon:SetSize(CASTBAR_HEIGHT, CASTBAR_HEIGHT)
			icon:SetPoint("TOPLEFT", Castbar, "TOPLEFT", 0, 0)
			icon:SetTexCoord(.08, .92, .08, .92)
			bar.Icon = icon
		
		bar:SetPoint("TOPLEFT", icon, "TOPRIGHT")
		bar:SetPoint("RIGHT", Castbar, "RIGHT")
		
		-- Background
		local background = bar:CreateTexture(nil, "BORDER")
		background:SetPoint("TOPLEFT", icon, "TOPLEFT")
		background:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
		background:SetTexture(BAR_TEXTURE)
		background:SetVertexColor(1 * 0.4, 1 * 0.4, 1 * 0.4)
		bar.bg = background
		
		-- Spark
		local spark = bar:CreateTexture(nil, "OVERLAY")
		spark:SetSize(20, CASTBAR_HEIGHT * 2)
		spark:SetBlendMode("ADD")
		bar.Spark = spark
		
		-- Safezone and ping display
		if (unit == "player") then
			-- Add safezone
			local safezone = bar:CreateTexture(nil, "OVERLAY")
			safezone:SetTexture(BAR_TEXTURE)
			safezone:SetVertexColor(1, 0, 0, 0.7)
			bar.SafeZone = safezone
			
			-- Add ping text
			local ping = bar:CreateFontString(nil, "OVERLAY", "imon_text")
			ping:SetPoint("CENTER", safezone, "BOTTOM", 0, 0)
			ping:SetFont(LSM:Fetch("font", "Arial Narrow"), 9)
			ping:SetTextColor(1, 1, 1, 0.7)
			ping:SetText("")
			bar.Ping = ping
		end
		
		-- Add spell text
		local text = bar:CreateFontString(nil, "OVERLAY", "imon_text")
		text:SetPoint("LEFT", bar, "LEFT", 5, 0)
		bar.Text = text
		
		-- Add cast time
		local time = bar:CreateFontString(nil, "OVERLAY", "imon_text")
		time:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
		bar.CustomTimeText = function(self, duration)
			if (self.casting) then
				self.Time:SetFormattedText("%.1f", self.max - duration)
			elseif (self.channeling) then
				self.Time:SetFormattedText("%.1f", duration)
			end
		end
		bar.CustomDelayText = function(self, duration)
			if (self.casting) then
				self.Time:SetFormattedText("%.1f |cffff0000+%.1f|r", self.max - duration, self.delay)
			elseif (self.channeling) then
				self.Time:SetFormattedText("%.1f |cffff0000-%.1f|r", duration, self.delay)
			end
		end	
		bar.Time = time
		
	self.Castbar = bar
	
	-------------------------------------------
	-- SWING TIMER
	-------------------------------------------
	-- Container
	local Swing = CreateFrame("Frame", nil, self)
	Swing:SetSize(BAR_WIDTH, 1)
	Swing:SetPoint("BOTTOM", Castbar, "BOTTOM", 0, 0)
	Swing:SetFrameLevel(Castbar:GetFrameLevel() + 1)
	
		-- Bar
		local bar = CreateFrame("Frame", nil, Swing)
		bar:SetAllPoints()
		bar.texture = BAR_TEXTURE
		bar.color = {1, 1, 1, 0.8}
		bar.colorBG = {0, 0, 0, 0}
		
	self.Swing = bar
	
	-------------------------------------------
	-- ALTERNATE POWER
	-------------------------------------------
	if (unit == "player") then	
	
	-- Container
	local AltPower = CreateFrame("Frame", nil, self)
	AltPower:SetSize(BAR_WIDTH, BAR_WIDTH / 20)
	AltPower:SetPoint("TOP", Power, "BOTTOM", 0, 0)
	
		-- Bar
		local bar = CreateFrame("StatusBar", nil, AltPower)
		bar:SetStatusBarTexture(BAR_TEXTURE)
		bar:SetAllPoints()

		-- Background
		local background = bar:CreateTexture(nil, "BORDER")
		background:SetAllPoints()
		background:SetTexture(BAR_TEXTURE)
		bar.bg = background
		bar.bg.multiplier = 0.4
		
		-- Power text
		local text = bar:CreateFontString(nil, "OVERLAY")
		text:SetFontObject("imon_text")
		--text:SetJustifyH("RIGHT")
		text:SetPoint("RIGHT", bar, "RIGHT", -4, 0)
		text.frequentUpdates = 0.1
		self:Tag(text, "[imon:altpower]")
		
	self.AltPowerBar = bar
	
	end
	
	-------------------------------------------
	-- AURAS
	-------------------------------------------	
	-- Container
	local Auras = CreateFrame("Frame", nil, self)
	Auras:SetSize(BAR_WIDTH, BAR_WIDTH / 20)
	Auras:SetPoint("TOP", Power, "BOTTOM", 0, 0)
	
	if (unit == "target" or unit == "focus") then
		local auras = CreateFrame("Frame", nil, Auras)
		--auras:SetPoint("TOPLEFT", Auras, "BOTTOMLEFT", 0, 0)
		--auras:SetSize(BAR_WIDTH, BAR_WIDTH / 20)
		auras:SetAllPoints()
		auras.size = BAR_WIDTH / 20
		auras["growth-y"] = "DOWN"
		auras.numTotal = 20
		auras.PostCreateIcon = function(auras, button)
			-- UGLY BORDERS
			
			if (button.icon) then
				button.icon:SetTexCoord(.08, .92, .08, .92)
			end
			if (button.cd) then
				button.cd:SetReverse(true)
			end
		end
		
		self.Auras = auras
	end
	
	
	---
	-- DEATH KNIGHT RUNES
	---
end

oUF:RegisterStyle("imon", imon.oUF.Shared)
oUF:SetActiveStyle("imon")

-- Spawn frame stuff?
local player = oUF:Spawn("player", "oUF_player")

--player:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 458, 225)
player:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 458, 245)
--player:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 100, 225)

imon.player = {}
imon.player.frame = player
imon.player.point = function(x, y)
	imon.player.frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
end

local focus = oUF:Spawn("focus", "oUF_focus")
focus:SetPoint("TOPLEFT", player, "BOTTOMLEFT", 0, -20)

local target = oUF:Spawn("target", "oUF_target")
--target:SetPoint("TOPRIGHT", UIParent, "BOTTOMRIGHT", -458, 225)
target:SetPoint("TOPRIGHT", UIParent, "BOTTOMRIGHT", -458, 245)

local targettarget = oUF:Spawn("targettarget", "oUF_targettarget")
targettarget:SetPoint("TOPLEFT", target, "BOTTOMLEFT", 0, -20)

local pet = oUF:Spawn("pet", "oUF_pet")
pet:SetPoint("TOP", UIParent, "BOTTOM", 0, 225)