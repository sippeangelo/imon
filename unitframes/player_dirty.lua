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
	self.colors.power["MANA"] = { 68/255, 138/255, 231/255 }
	self.menu = imon.oUF.menu
	self:RegisterForClicks("AnyDown")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:SetSize(BAR_WIDTH, HEALTH_HEIGHT + POWER_HEIGHT)

	-- Health bar
	local hpBar = CreateFrame("StatusBar", nil, self)
	hpBar:SetStatusBarTexture(BAR_TEXTURE)
	hpBar:SetSize(BAR_WIDTH, HEALTH_HEIGHT)
	hpBar:SetPoint("TOP", self, "TOP", 0, 0)
	
	hpBar.frequentUpdates = true
	hpBar.colorClass = true
	hpBar.colorReaction = true
	hpBar.colorDisconnected = true
	
	self.Health = hpBar
	
	-- Heal prediction
	local hpBar_p = CreateFrame("StatusBar", nil, self.Health)
	--hpBar_p:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
	--hpBar_p:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
	hpBar_p:SetFrameLevel(hpBar:GetFrameLevel())
	hpBar_p:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	hpBar_p:SetStatusBarTexture(BAR_TEXTURE)
	hpBar_p:SetSize(BAR_WIDTH, HEALTH_HEIGHT)
	hpBar_p:SetStatusBarColor(0, 1, 0, 1)
	
	-- Resize heal prediction bar depending on cast percentage
	hpBar_p:SetScript("OnUpdate", function(self)
		local name, _, _, _, startTime, endTime, _, _, _ = UnitCastingInfo("player")
		if (name ~= nil) then
			local curTime = GetTime() * 1000
			local percent = (curTime - startTime) / (endTime - startTime)
			hpBar_p:SetHeight(HEALTH_HEIGHT * percent)
		else
			hpBar_p:SetHeight(HEALTH_HEIGHT)
		end
	end)	
	
	self.HealPrediction = {
		-- status bar to show my incoming heals 
		myBar = hpBar_p,

		-- amount of overflow past the end of the health bar
		maxOverflow = 1.00,
	}
	
	local hpBG = hpBar:CreateTexture(nil, "BORDER")
	hpBG:SetAllPoints()
	hpBG:SetTexture(BAR_TEXTURE)	
	hpBar.bg = hpBG
	hpBar.bg.multiplier = 0.4

	-- Portrait
	--[[local portrait = CreateFrame("PlayerModel", "ip", self)
	portrait:SetSize(BAR_WIDTH, CASTBAR_HEIGHT)
	portrait:SetPoint("TOP", hpBar, "BOTTOM", 0, 0)
	self.Portrait = portrait]]--
	
	-- Power bar
	local powBar = CreateFrame("StatusBar", nil, self)
	powBar:SetStatusBarTexture(BAR_TEXTURE)
	powBar:SetSize(BAR_WIDTH, POWER_HEIGHT)
	powBar:SetPoint("TOP", hpBar, "BOTTOM", 0, 0)
	powBar:SetFrameLevel(hpBar:GetFrameLevel() + 1)
	
	powBar:SetBackdropColor(0, 0, 0, 0.9)
	
	powBar.frequentUpdates = true
	powBar.colorPower = true
	powBar.colorDisconnected = true
	
	self.Power = powBar
	
		--
		-- POWER BAR ICONS
		--
		local lastElement = {"TOPLEFT", powBar, "TOPLEFT"}
		local icons = {
			["Combat"] = UnitAffectingCombat("player"),
			["Resting"] = IsResting(),
			["PvP"] = UnitIsPVPFreeForAll("player") or UnitIsPVP("player"),
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
			local e = powBar:CreateTexture(nil, "OVERLAY")
			e:SetSize(POWER_HEIGHT, POWER_HEIGHT)
			e:SetPoint(unpack(lastElement))
			self[k] = e
			
			lastElement = {"TOPLEFT", e, "TOPRIGHT"}
		end
		self:SetScript("OnUpdate", imon.oUF.UpdatePowerStatus)
	
	local powBG = powBar:CreateTexture(nil, "BORDER")
	powBG:SetAllPoints()
	powBG:SetTexture(BAR_TEXTURE)	
	powBar.bg = powBG
	powBar.bg.multiplier = 0.4

	
	-- Castbar
	local castbar = CreateFrame("StatusBar", nil, self)
	
	local cicon = castbar:CreateTexture(nil, "OVERLAY")
		cicon:SetSize(CASTBAR_HEIGHT, CASTBAR_HEIGHT)
		cicon:SetPoint("TOPLEFT", hpBar, "BOTTOMLEFT", 0, 0)
		cicon:SetTexCoord(.08, .92, .08, .92)
	
	--castbar:SetSize(BAR_WIDTH, CASTBAR_HEIGHT)
	castbar:SetHeight(CASTBAR_HEIGHT)
	castbar:SetPoint("TOPLEFT", cicon, "TOPRIGHT")
	castbar:SetPoint("RIGHT", hpBar, "RIGHT")
	castbar:SetStatusBarTexture(BAR_TEXTURE)
	castbar:SetFrameLevel(powBar:GetFrameLevel() + 1)
	castbar:SetBackdropColor(0, 0, 0, 0.9)
	
	-- Move the power bar up so you can see power while casting
	castbar.PostCastStart = function(self, unit, spellname, spellrank, castid)
		local owner = self.__owner
		if (owner.Power) then
			owner.Power:SetPoint("TOP", owner.Health, "BOTTOM", 0, 4)
		end
		
		if (owner.Experience) then
			owner.Experience:Hide()
		end
		
		if (self.Ping) then
			local _, _, ms = GetNetStats()
			if (ms > 0) then
				self.Ping:SetFormattedText("%dms", ms)
			end
		end
	end
	castbar.PostCastStop = function(self, unit, spellname, spellrank, castid)
		local owner = self.__owner
		if (owner.Power) then
			owner.Power:SetPoint("TOP", owner.Health, "BOTTOM", 0, 0)
		end
		
		if (owner.Experience) then
			owner.Experience:Show()
		end	
	end
	castbar.CustomTimeText = function(self, duration)
		if (self.casting) then
			self.Time:SetFormattedText("%.1f", self.max - duration)
		elseif (self.channeling) then
			self.Time:SetFormattedText("%.1f", duration)
		end
	end
	castbar.CustomDelayText = function(self, duration)
		if (self.casting) then
			self.Time:SetFormattedText("%.1f |cffff0000+%.1f|r", self.max - duration, self.delay)
		elseif (self.channeling) then
			self.Time:SetFormattedText("%.1f |cffff0000-%.1f|r", duration, self.delay)
		end
	end	
	self.Castbar = castbar
	
		local cspark = castbar:CreateTexture(nil, "OVERLAY")
		cspark:SetSize(20, CASTBAR_HEIGHT * 2)
		cspark:SetBlendMode("ADD")
		self.Castbar.Spark = cspark
		
		-- Add cast time
		local ctime = castbar:CreateFontString(nil, "OVERLAY", "imon_text")
		ctime:SetPoint("RIGHT", castbar, "RIGHT", -5, 0)
		self.Castbar.Time = ctime
		
		-- Add spell icon
		self.Castbar.Icon = cicon
		
		-- Add spell text
		local ctext = castbar:CreateFontString(nil, "OVERLAY", "imon_text")
		ctext:SetPoint("LEFT", castbar, "LEFT", 5, 0)
		self.Castbar.Text = ctext
		
		-- Add a background
		local cbg = castbar:CreateTexture(nil, "BACKGROUND")
		cbg:SetPoint("TOPLEFT", cicon, "TOPLEFT")
		cbg:SetPoint("BOTTOMRIGHT", castbar, "BOTTOMRIGHT")
		cbg:SetTexture(BAR_TEXTURE)
		cbg:SetVertexColor(1 * 0.4, 1 * 0.4, 1 * 0.4)
		self.Castbar.bg = cbg
		
		if (unit ~= "target") then
			-- Add safezone
			local csafezone = castbar:CreateTexture(nil, "OVERLAY")
			csafezone:SetTexture(BAR_TEXTURE)
			csafezone:SetVertexColor(1, 0, 0, 0.7)
			self.Castbar.SafeZone = csafezone
			
			-- Add ping text
			local cping = castbar:CreateFontString(nil, "OVERLAY", "imon_text")
			cping:SetPoint("CENTER", csafezone, "BOTTOM", 0, 0)
			cping:SetFont(LSM:Fetch("font", "Arial Narrow"), 9)
			cping:SetTextColor(1, 1, 1, 0.7)
			cping:SetText("")
			self.Castbar.Ping = cping
		end
	
	-- Raid markers
	if (unit == "target") then
		local rm = hpBar:CreateTexture(nil, "OVERLAY")
		rm:SetSize(32, 32)
		rm:SetPoint("CENTER", self, "TOP", 0, 0)
		self.RaidIcon = rm
	end
	
	-- XP bar on mouseover
	if ((unit == "player" and UnitLevel("player") ~= MAX_PLAYER_LEVEL) or (unit == "pet" and UnitLevel(unit) == UnitLevel("player"))) then
		local xpBar = CreateFrame("StatusBar", "XPBAAR", self)
		xpBar:SetSize(BAR_WIDTH, POWER_HEIGHT)
		xpBar:SetPoint("TOP", powBar, "TOP", 0, 0)
		xpBar:SetFrameLevel(powBar:GetFrameLevel() + 2)
		xpBar:SetStatusBarTexture(BAR_TEXTURE)
		xpBar:SetStatusBarColor(unpack(XP_COLOR))
		
		-- Mouseover show and tooltip
		xpBar:SetScript("OnEnter", function(self) 
			self:SetAlpha(1) 
			
			local unit = self:GetParent().unit
			
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
		xpBar:SetScript("OnLeave", function(self) 
			self:SetAlpha(0) 
			GameTooltip_Hide()
		end)
		
		xpBar.Rested = CreateFrame("StatusBar", nil, xpBar)
		xpBar.Rested:SetAllPoints()
		xpBar.Rested:SetStatusBarTexture(BAR_TEXTURE)
		xpBar.Rested:SetStatusBarColor(XP_COLOR[1] * 1.5, XP_COLOR[2] * 1.5, XP_COLOR[3] * 1.5, XP_COLOR[4])
		
		local val = xpBar:CreateFontString(nil, "OVERLAY")
		val:SetAllPoints()
		val:SetFontObject("imon_text")
		self:Tag(val, "[imon:xp]")
		
		local xpBG = xpBar.Rested:CreateTexture(nil, "BACKGROUND")
		xpBG:SetAllPoints()
		xpBG:SetTexture(BAR_TEXTURE)
		xpBG:SetVertexColor(XP_COLOR[1] * 0.4, XP_COLOR[2] * 0.4, XP_COLOR[3] * 0.4, XP_COLOR[4])
		
		-- Show where the "bars" of the normal xp bar would be
		for i=1,19 do
			local barmarker = xpBar:CreateTexture(nil, "OVERLAY")
			--barmarker:SetAllPoints()
			barmarker:SetSize(1, POWER_HEIGHT)
			barmarker:SetPoint("TOPLEFT", xpBar, "TOPLEFT", BAR_WIDTH / 20 * i, 0)
			barmarker:SetTexture(BAR_TEXTURE)
			local alpha = 0.1
			if (i % 5 == 0) then
				alpha = 0.4
			end
			barmarker:SetVertexColor(1, 1, 1, alpha)
		end
		
		self.Experience = xpBar
	end
	
	--if (UnitLevel(unit) ~= MAX_PLAYER_LEVEL) then
		--[[local Experience = CreateFrame("StatusBar", nil, self)
		Experience:SetStatusBarTexture(BAR_TEXTURE)
		Experience:SetStatusBarColor(0, 0.4, 1, 1)
		Experience:SetBackdrop(BAR_BACKDROP)
		Experience:SetBackdropColor(.1, .1, .1, 1)
		Experience:SetSize(BAR_WIDTH, POWER_HEIGHT)
		Experience:SetPoint("TOP", hpBar, "BOTTOM", 0, 0)
		Experience:SetFrameLevel(10)
		--Experience:SetAlpha(0)
		Experience:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
		Experience:SetScript("OnLeave", function(self) self:SetAlpha(0) end)
		--Experience.Tooltip = true]]--
		
		--[[Experience.Rested = CreateFrame('StatusBar', nil, self)
		Experience.Rested:SetParent(Experience)
		Experience.Rested:SetAllPoints(Experience)
		local Resting = Experience:CreateTexture(nil, "OVERLAY")
		Resting:SetHeight(28)
		Resting:SetWidth(28)
		if TukuiDB.myclass == "SHAMAN" or TukuiDB.myclass == "DEATHKNIGHT" or TukuiDB.myclass == "PALADIN" or TukuiDB.myclass == "WARLOCK" or TukuiDB.myclass == "DRUID" then
			Resting:SetPoint("LEFT", -18, 76)
		else
			Resting:SetPoint("LEFT", -18, 68)
		end
		Resting:SetTexture([=[Interface\CharacterFrame\UI-StateIcon]=])
		Resting:SetTexCoord(0, 0.5, 0, 0.421875)
		self.Resting = Resting]]--
		--self.Experience = Experience
	--end
	
	--local exBG = Experience:CreateTexture(nil, "BORDER")
	--exBG:SetAllPoints()
	--exBG:SetTexture(BAR_TEXTURE)	
	--Experience.bg = exBG
	--Experience.bg.multiplier = 0.4
	
	-- Druid Eclipse
	if (unit == "player" and select(2, UnitClass("player")) == "DRUID") then
		local eclipse = CreateFrame("Frame", nil, self)
		eclipse:SetSize(BAR_WIDTH, 4)
		eclipse:SetPoint("BOTTOMLEFT", powBar, "TOPLEFT", 0, 0)
		
		eclipse.PostDirectionChange = function(eb, unit)
			eb.marker:SetTexCoord(unpack(ECLIPSE_MARKER_COORDS[GetEclipseDirection() or "none"]))
		end
		
		local eclipse_lunar = CreateFrame("StatusBar", nil, eclipse)
		eclipse_lunar:SetStatusBarTexture(BAR_TEXTURE)
		eclipse_lunar:SetSize(BAR_WIDTH, 4)
		eclipse_lunar:SetPoint("LEFT", eclipse, "LEFT", 0, 0)
		eclipse_lunar:SetStatusBarColor(0, 0, 1)
		
		local eclipse_solar = CreateFrame("StatusBar", nil, eclipse)
		eclipse_solar:SetStatusBarTexture(BAR_TEXTURE)
		eclipse_solar:SetSize(BAR_WIDTH, 4)
		eclipse_solar:SetPoint("LEFT", eclipse_lunar:GetStatusBarTexture(), "RIGHT", 0, 0)
		eclipse_solar:SetStatusBarColor(1, 3/5, 0)
		--eclipse:SetFrameLevel(hpBar:GetFrameLevel() + 1)
		
		  local marker = eclipse_solar:CreateTexture(nil, "OVERLAY")
		  marker:SetTexture([[Interface\PlayerFrame\UI-DruidEclipse]])
		  marker:SetSize(12, 12)
		  marker:SetTexCoord(unpack(ECLIPSE_MARKER_COORDS[GetEclipseDirection() or "none"]))
		  marker:SetBlendMode("ADD")
		  marker:ClearAllPoints()
		  marker:SetPoint("CENTER", eclipse_lunar:GetStatusBarTexture(), "RIGHT", 0, 0)		
	
		--eclipse:SetBackdropColor(0, 0, 0, 0.9)

		self.EclipseBar = eclipse
		self.EclipseBar.marker = marker
		self.EclipseBar.LunarBar = eclipse_lunar
		self.EclipseBar.SolarBar = eclipse_solar
	end
	
	-- Target auras
	if (unit == "target") then
		local auras = CreateFrame("Frame", nil, self)
		auras:SetPoint("TOPLEFT", hpBar, "BOTTOMLEFT", 0, -POWER_HEIGHT - 4)
		auras:SetSize(BAR_WIDTH, BAR_WIDTH / 20)
		auras.size = 20
		auras["growth-y"] = "DOWN"
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

	-- Unit name text
	local name = hpBar:CreateFontString(nil, "OVERLAY")
	name:SetFontObject("imon_text")
	name:SetJustifyH("LEFT")
	name:SetPoint("LEFT", hpBar, "LEFT", 4, 0)
	
	self:Tag(name, "[imon:name]")
	
	-- Unit health text
	local hpText = hpBar:CreateFontString(nil, "OVERLAY")
	hpText:SetFontObject("imon_text")
	hpText:SetJustifyH("RIGHT")
	hpText:SetPoint("RIGHT", hpBar, "RIGHT", -4, 0)
	
	hpText.frequentUpdates = true
	
	self:Tag(hpText, "[imon:health]")
	
	-- Unit power text
	local powText = powBar:CreateFontString(nil, "OVERLAY")
	powText:SetFontObject("imon_text")
	powText:SetJustifyH("RIGHT")
	powText:SetPoint("RIGHT", powBar, "RIGHT", -4, 0)
	
	powText.frequentUpdates = 0.1
	
	self:Tag(powText, "[imon:power]")	
	
	-- Unit info
	local infoText = powBar:CreateFontString(nil, "Overlay")
	infoText:SetFontObject("imon_text")
	infoText:SetJustifyH("LEFT")
	infoText:SetPoint("LEFT", powBar, "LEFT", 4, 0)
	self:Tag(infoText, "[imon:info]")
end

oUF:RegisterStyle("imon", imon.oUF.Shared)
oUF:SetActiveStyle("imon")

-- Spawn frame stuff?
local player = oUF:Spawn("player", "oUF_player")
--player:SetPoint("CENTER", UIParent, "CENTER", -192, -192)
--player:SetPoint("TOP", UIParent, "TOP", 441, 181)
player:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 458, 225)
	--frame:ClearAllPoints();
	--frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x/frame:GetEffectiveScale(), y/frame:GetEffectiveScale());

imon.player = {}
imon.player.frame = player
imon.player.point = function(x, y)
	imon.player.frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
end

local target = oUF:Spawn("target", "oUF_target")
target:SetPoint("TOPRIGHT", UIParent, "BOTTOMRIGHT", -458, 225)


--------------
-- raid.lua --
--------------

local BAR_WIDTH = 220
local HEALTH_HEIGHT = 34
local POWER_HEIGHT = 9
local SPACING_HEIGHT = 5
local AURA_SIZE = (HEALTH_HEIGHT + POWER_HEIGHT - 1) / 2

imon.oUF.Raid = {}

imon.oUF.Raid.Health_Override = function(self, event, unit, powerType)
	if(self.unit ~= unit or (event == 'UNIT_POWER' and powerType ~= 'HAPPINESS')) then return end
	local health = self.Health
	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	
	local disconnected = not UnitIsConnected(unit)
	health:SetMinMaxValues(0, max)

	if(disconnected) then
		health:SetValue(max)
	else
		health:SetValue(min)
	end

	health.disconnected = disconnected

	local r, g, b, t
	if(not UnitIsConnected(unit)) then
		t = self.colors.disconnected
	else
		-- Start coloring red from 50% hp down
		local percentage = min / (max / 2)
		local _, class = UnitClass(unit)
		if (class) then
			r, g, b = self.ColorGradient(percentage, 1,0,0, unpack(self.colors.class[class]))
		end
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if(b) then
		health:SetStatusBarColor(r, g, b)

		local bg = health.bg
		if(bg) then local mu = bg.multiplier or 1
			bg:SetVertexColor(r * mu, g * mu, b * mu)
		end
	end
end

imon.oUF.SharedParty = function(self, unit)
self.colors.power["MANA"] = { 68/255, 138/255, 231/255 }
	self.menu = imon.oUF.menu
	self:RegisterForClicks("AnyDown")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)
	self:SetSize(BAR_WIDTH, HEALTH_HEIGHT + POWER_HEIGHT + SPACING_HEIGHT)
	
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.6
	}
	
	-- Health bar
	local hpBar = CreateFrame("StatusBar", nil, self)
	hpBar:SetStatusBarTexture(BAR_TEXTURE)
	hpBar:SetSize(BAR_WIDTH, HEALTH_HEIGHT)
	hpBar:SetPoint("TOP", self, "TOP", 0, 0)
	hpBar.frequentUpdates = true
	self.Health = hpBar
	self.Health.Override = imon.oUF.Raid.Health_Override
	--[[self.Health.PostUpdate = function(health, unit, min, max)
		local _, class = UnitClass(unit)
		if (class) then
			r, g, b = self.ColorGradient(min / max, 1,0,0, unpack(self.colors.class[class]))
			health:SetStatusBarColor(r, g, b)

			local bg = health.bg
			if(bg) then local mu = bg.multiplier or 1
				bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end
	end]]--
	
	local hpBG = hpBar:CreateTexture(nil, "BORDER")
	hpBG:SetAllPoints()
	hpBG:SetTexture(BAR_TEXTURE)	
	hpBar.bg = hpBG
	hpBar.bg.multiplier = 0.5
	
	-- Power bar
	local powBar = CreateFrame("StatusBar", nil, self)
	powBar:SetStatusBarTexture(BAR_TEXTURE)
	powBar:SetSize(BAR_WIDTH, POWER_HEIGHT)
	powBar:SetPoint("TOP", hpBar, "BOTTOM", 0, 0)
	--powBar:SetBackdropColor(0, 0, 0, 0.9)
	powBar.frequentUpdates = true
	powBar.colorPower = true
	powBar.colorDisconnected = true
	self.Power = powBar
	
	local powBG = powBar:CreateTexture(nil, "BORDER")
	powBG:SetAllPoints()
	powBG:SetTexture(BAR_TEXTURE)	
	powBar.bg = powBG
	powBar.bg.multiplier = 0.4
	
	-- Debuffs
	local debuffs = CreateFrame("Frame", nil, self)
	debuffs:SetPoint("TOPLEFT", self, "TOPRIGHT", 1, 0)
	debuffs:SetSize((AURA_SIZE) * 3, 100)
	self.Debuffs = debuffs
	self.Debuffs.num = 6
	self.Debuffs.showType = true
	self.Debuffs.initialAnchor = "TOPLEFT"
	self.Debuffs.size = AURA_SIZE
	self.Debuffs.spacing = 1
	self.Debuffs["growth-y"] = "DOWN"
	
	self.Debuffs.PostCreateIcon = function(debuffs, button)
		-- UGLY BORDERS
		button.icon:SetTexCoord(.08, .92, .08, .92)
	end
	
	-- Unit name text
	local name = hpBar:CreateFontString(nil, "OVERLAY")
	name:SetFontObject("imon_text")
	name:SetJustifyH("LEFT")
	name:SetPoint("LEFT", hpBar, "LEFT", 4, 0)
	self:Tag(name, "[imon:name]")
	
	-- Unit health text (deficit)
	local hpText = hpBar:CreateFontString(nil, "OVERLAY")
	hpText:SetFontObject("imon_text")
	hpText:SetFont(LSM:Fetch("font", "Arial Narrow"), 20)
	hpText:SetJustifyH("RIGHT")
	hpText:SetPoint("RIGHT", hpBar, "RIGHT", -4, 0)
	hpText.frequentUpdates = 0.1
	self:Tag(hpText, "[imon:group:health]")	
end

oUF:RegisterStyle("imonRaid", imon.oUF.SharedParty)
oUF:Factory(function(self)
	oUF:SetActiveStyle("imonRaid")
	
	local raid = self:SpawnHeader("oUF_imonRaid", nil, "raid,party", --"custom [@raid26,exists] hide;show"
		"showParty", true, 
		"showPlayer", true, 
		"showRaid", true, 
		"groupFilter", "1,2,3,4,5,6,7,8", 
		"groupingOrder", "1,2,3,4,5,6,7,8", 
		"groupBy", "GROUP", 
		"yOffset", 0
	)
	raid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 20, -175)	
end)
